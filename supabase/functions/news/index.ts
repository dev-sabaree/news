const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

const newsApiBaseUrl = 'https://newsapi.org/v2';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'GET') {
    return json({ status: 'error', message: 'Method not allowed' }, 405);
  }

  const apiKey = Deno.env.get('NEWS_API_KEY');
  if (!apiKey) {
    console.error('NEWS_API_KEY is not configured');
    return json({ status: 'error', message: 'News service is not configured' }, 500);
  }

  const requestUrl = new URL(req.url);
  const path = requestUrl.pathname.replace(/.*\/functions\/v1\/news\/?/, '/');

  let endpoint: string;
  if (path === '/top-headlines') {
    endpoint = '/top-headlines';
  } else if (path === '/everything') {
    endpoint = '/everything';
  } else {
    return json({ status: 'error', message: 'Unknown news endpoint' }, 404);
  }

  const allowedParams = ['country', 'page', 'pageSize', 'q'];
  const params = new URLSearchParams();

  for (const name of allowedParams) {
    const value = requestUrl.searchParams.get(name);
    if (value !== null && value.length > 0) {
      params.set(name, value);
    }
  }

  const response = await fetch(
    `${newsApiBaseUrl}${endpoint}?${params.toString()}`,
    {
      headers: {
        'X-Api-Key': apiKey,
      },
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
});

function json(body: Record<string, unknown>, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
