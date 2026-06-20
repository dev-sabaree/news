import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:newsapp/l10n/app_localizations.dart';
import 'package:newsapp/features/news/presentation/widgets/news_card.dart';
import 'package:newsapp/features/news/presentation/bloc/news_bloc.dart';
import 'package:newsapp/features/news/presentation/bloc/news_event.dart';
import 'package:newsapp/features/news/presentation/bloc/news_state.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:newsapp/core/themes/app_colors.dart';
import 'package:newsapp/core/themes/app_text_styles.dart';
import 'package:newsapp/core/themes/app_spacing.dart';
import 'package:newsapp/core/themes/app_radius.dart';
import 'package:newsapp/core/widgets/news_shimmer_card.dart';
import 'package:newsapp/core/widgets/empty_state_widget.dart';
import 'package:newsapp/core/widgets/error_state_widget.dart';
import 'package:newsapp/features/settings/widgets/language_switcher.dart';
import 'package:newsapp/routes/route_names.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300) {
        context.read<NewsBloc>().add(LoadMoreNews());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        context.read<NewsBloc>().add(FetchTopHeadlines());
      } else {
        context.read<NewsBloc>().add(SearchNews(value.trim()));
      }
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<NewsBloc>().add(FetchTopHeadlines());
  }

  Widget _buildArticleList({
    required List articles,
    bool hasReachedMax = true,
  }) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<NewsBloc>().add(RefreshNews());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.xxxl,
        ),
        itemCount: hasReachedMax ? articles.length : articles.length + 1,
        itemBuilder: (context, index) {
          if (index >= articles.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          return NewsCard(
            article: articles[index],
            onTap: () {
              context.push(RouteNames.newsDetail, extra: articles[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      itemCount: 5,
      itemBuilder: (context, _) => const NewsShimmerCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final userEmail =
        authState is AuthAuthenticated ? authState.user.email : null;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(RouteNames.login);
        }
      },
      child: PopScope(
        canPop: !_isSearching, //
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _isSearching) {
            _closeSearch();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // AppBar
                _NewsAppBar(
                  searchController: _searchController,
                  isSearching: _isSearching,
                  onSearchToggle: () {
                    if (_isSearching) {
                      _closeSearch();
                    } else {
                      setState(() => _isSearching = true);
                    }
                  },
                  onSearchChanged: _onSearchChanged,
                  l10n: l10n,
                  userEmail: userEmail,
                ),

                // Body
                Expanded(
                  child: BlocBuilder<NewsBloc, NewsState>(
                    builder: (context, state) {
                      if (state is NewsLoading) {
                        return _buildShimmerList();
                      }

                      if (state is NewsLoaded) {
                        if (state.articles.isEmpty) {
                          return EmptyStateWidget(
                            icon: Icons.search_off_rounded,
                            title: l10n.noArticlesFound,
                            subtitle: l10n.tryDifferentKeywords,
                            buttonText: l10n.clearSearch,
                            onAction: _closeSearch,
                          );
                        }

                        return _buildArticleList(
                          articles: state.articles,
                          hasReachedMax: state.hasReachedMax,
                        );
                      }

                      if (state is NewsError) {
                        if (state.cachedArticles != null &&
                            state.cachedArticles!.isNotEmpty) {
                          return _buildArticleList(
                            articles: state.cachedArticles!,
                            hasReachedMax: true,
                          );
                        }

                        return ErrorStateWidget(
                          title: l10n.noInternetConnection,
                          subtitle: l10n.failedToLoad,
                          retryText: l10n.refresh,
                          onRetry: () {
                            context.read<NewsBloc>().add(FetchTopHeadlines());
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── AppBar Widget ──────────────────────────────────────────────────────────────

class _NewsAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final AppLocalizations l10n;
  final String? userEmail;

  const _NewsAppBar({
    required this.searchController,
    required this.isSearching,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.l10n,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.newspaper_rounded,
                  color: AppColors.textWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appTitle, style: AppTextStyles.headlineMedium),
                    if (userEmail != null && userEmail!.isNotEmpty)
                      Text(
                        '${l10n.signedInAs} $userEmail',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const LanguageSwitcher(),
              IconButton(
                icon: Icon(
                  isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: onSearchToggle,
              ),
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    ctx.read<AuthBloc>().add(LogoutRequested());
                  },
                ),
              ),
            ],
          ),

          // Search bar — animated
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isSearching
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                autofocus: true,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.fullAll,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.fullAll,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.fullAll,
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
