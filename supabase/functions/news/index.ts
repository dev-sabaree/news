import { withSupabase } from '@supabase/server';
import { Redis } from '@upstash/redis';
import { Ratelimit } from '@upstash/ratelimit';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

const newsApiBaseUrl = 'https://newsapi.org/v2';
const upstreamTimeoutMs = 10_000;

// ---------------------------
// Redis / Rate limiter
// ---------------------------

const redisUrl = Deno.env.get('UPSTASH_REDIS_REST_URL');
const redisToken = Deno.env.get('UPSTASH_REDIS_REST_TOKEN');

const redis =
  redisUrl && redisToken
    ? new Redis({
        url: redisUrl,
        token: redisToken,
      })
    : null;

const ratelimit = redis
  ? new Ratelimit({
      redis,
      limiter: Ratelimit.slidingWindow(10, '10 s'),
      timeout: 1000,
      analytics: true,
    })
  : null;

export default {
  fetch: withSupabase(
    { auth: 'user' },
    async (req, ctx) => {
      if (req.method === 'OPTIONS') {
        return new Response('ok', {
          headers: corsHeaders,
        });
      }

      if (req.method !== 'GET') {
        return json(
          {
            status: 'error',
            message: 'Method not allowed',
          },
          405,
        );
      }

      // ---------------------------
      // Authentication
      // ---------------------------

      if (!ctx.userClaims) {
        return json(
          {
            status: 'error',
            message: 'Unauthorized',
          },
          401,
        );
      }

      const requestUrl = new URL(req.url);

      // ---------------------------
      // Determine endpoint
      // ---------------------------

      const path = requestUrl.pathname.endsWith(
        '/top-headlines',
      )
        ? '/top-headlines'
        : requestUrl.pathname.endsWith('/everything')
            ? '/everything'
            : '/';

      let endpoint: string;

      if (path === '/top-headlines') {
        endpoint = '/top-headlines';
      } else if (path === '/everything') {
        endpoint = '/everything';
      } else {
        return json(
          {
            status: 'error',
            message: 'Unknown news endpoint',
          },
          404,
        );
      }

      // ---------------------------
      // Request validation
      // ---------------------------

      const rawPage = requestUrl.searchParams.get('page');
      const rawPageSize =
        requestUrl.searchParams.get('pageSize');
      const country =
        requestUrl.searchParams.get('country');
      const query = requestUrl.searchParams.get('q');

      const page = rawPage ? Number(rawPage) : 1;
      const pageSize = rawPageSize
        ? Number(rawPageSize)
        : 20;

      // Page: 1-100
      if (
        !Number.isInteger(page) ||
        page < 1 ||
        page > 100
      ) {
        return json(
          {
            status: 'error',
            message: 'Invalid page',
          },
          400,
        );
      }

      // Page size: 1-20
      if (
        !Number.isInteger(pageSize) ||
        pageSize < 1 ||
        pageSize > 20
      ) {
        return json(
          {
            status: 'error',
            message: 'Invalid pageSize',
          },
          400,
        );
      }

      const params = new URLSearchParams();

      params.set('page', page.toString());
      params.set('pageSize', pageSize.toString());

      // ---------------------------
      // Top headlines validation
      // ---------------------------

      if (endpoint === '/top-headlines') {
        if (!country) {
          return json(
            {
              status: 'error',
              message: 'Country is required',
            },
            400,
          );
        }

        const normalizedCountry = country
          .trim()
          .toLowerCase();

        if (!/^[a-z]{2}$/.test(normalizedCountry)) {
          return json(
            {
              status: 'error',
              message: 'Invalid country',
            },
            400,
          );
        }

        params.set('country', normalizedCountry);
      }

      // ---------------------------
      // Search validation
      // ---------------------------

      if (endpoint === '/everything') {
        if (!query) {
          return json(
            {
              status: 'error',
              message: 'Search query is required',
            },
            400,
          );
        }

        const normalizedQuery = query.trim();

        if (normalizedQuery.length === 0) {
          return json(
            {
              status: 'error',
              message: 'Search query is required',
            },
            400,
          );
        }

        if (normalizedQuery.length > 100) {
          return json(
            {
              status: 'error',
              message: 'Search query is too long',
            },
            400,
          );
        }

        params.set('q', normalizedQuery);
      }

      // Validation runs after authentication and before rate limiting so malformed
      // requests do not consume quota. Valid requests remain subject to the same
      // authenticated per-user limit.
      if (!ratelimit) {
        console.error('Rate limiter is not configured');
        return json({ status: 'error', message: 'Service temporarily unavailable' }, 503);
      }

      try {
        const rateLimitResult = await ratelimit.limit(`user:${ctx.userClaims.id}`);
        if (rateLimitResult.reason === 'timeout') {
          console.error('Rate limiter Redis timeout');
          return json({ status: 'error', message: 'Service temporarily unavailable' }, 503);
        }
        if (!rateLimitResult.success) {
          const retryAfter = Math.max(1, Math.ceil((rateLimitResult.reset - Date.now()) / 1000));
          return json(
            { status: 'error', message: 'Too many requests' },
            429,
            {
              'Retry-After': retryAfter.toString(),
              'X-RateLimit-Limit': rateLimitResult.limit.toString(),
              'X-RateLimit-Remaining': '0',
            },
          );
        }
      } catch (error) {
        console.error('Rate limiter error:', error);
        return json({ status: 'error', message: 'Service temporarily unavailable' }, 503);
      }

      const apiKey = Deno.env.get('NEWS_API_KEY');
      if (!apiKey) {
        console.error('NEWS_API_KEY is not configured');
        return json({ status: 'error', message: 'News service is not configured' }, 500);
      }

      // ---------------------------
      // NewsAPI request
      // ---------------------------

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), upstreamTimeoutMs);

      try {
        const response = await fetch(
          `${newsApiBaseUrl}${endpoint}?${params.toString()}`,
          {
            headers: {
              'X-Api-Key': apiKey,
            },
            signal: controller.signal,
          },
        );

        const body = await response.text();
        return new Response(body, {
          status: response.status,
          headers: {
            ...corsHeaders,
            'Content-Type': response.headers.get('content-type') ?? 'application/json',
          },
        });
      } catch (error) {
        if (error instanceof DOMException && error.name === 'AbortError') {
          return json({ status: 'error', message: 'News service timed out' }, 504);
        }
        console.error('NewsAPI request failed:', error);
        return json({ status: 'error', message: 'News service unavailable' }, 502);
      } finally {
        clearTimeout(timeoutId);
      }
    },
  ),
};

function json(
  body: Record<string, unknown>,
  status: number,
  extraHeaders: Record<string, string> = {},
) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
      ...extraHeaders,
    },
  });
}
