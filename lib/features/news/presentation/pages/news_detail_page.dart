import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:newsapp/l10n/app_localizations.dart';

import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/core/themes/app_colors.dart';
import 'package:newsapp/core/themes/app_text_styles.dart';
import 'package:newsapp/core/themes/app_spacing.dart';
import 'package:newsapp/core/themes/app_radius.dart';
import 'package:newsapp/core/widgets/shimmer_widget.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsEntity article;

  const NewsDetailPage({super.key, required this.article});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _openArticle(BuildContext context, String fallbackText) async {
    if (article.articleUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackText),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(article.articleUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackText),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing AppBar with hero image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            leading: _BackButton(),
            actions: [
              _ActionButton(
                icon: Icons.open_in_new_rounded,
                onTap: () => _openArticle(context, l10n.noContent),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroImage(imageUrl: article.imageUrl),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source badge
                      if (article.source.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sourceBadgeBackground,
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Text(
                            article.source,
                            style: AppTextStyles.labelSmall,
                          ),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Title
                      Text(
                        article.title.isNotEmpty
                            ? article.title
                            : l10n.noContent,
                        style: AppTextStyles.headlineLarge,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Author + Date row
                      Row(
                        children: [
                          // Author
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.sourceBadgeBackground,
                                    borderRadius: AppRadius.fullAll,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 18,
                                    color: AppColors.sourceBadgeText,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.author,
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        article.author.isNotEmpty
                                            ? article.author
                                            : l10n.unknownAuthor,
                                        style: AppTextStyles.labelMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: AppSpacing.lg),

                          // Date
                          if (article.publishedAt.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.publishedAt,
                                    style: AppTextStyles.caption),
                                Text(
                                  _formatDate(article.publishedAt),
                                  style: AppTextStyles.labelMedium,
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      const Divider(color: AppColors.border),

                      const SizedBox(height: AppSpacing.xxl),

                      // Description
                      if (article.description.isNotEmpty) ...[
                        Text(
                          article.description,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      // Content
                      Text(
                        article.content.isNotEmpty
                            ? article.content
                            : l10n.noContent,
                        style: AppTextStyles.newsContent,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                
                      _ReadMoreButton(
                        label: l10n.readMore,
                        onTap: () =>
                            _openArticle(context, l10n.noContent),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Image ─────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String imageUrl;

  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => ShimmerWidget(
                  width: double.infinity,
                  height: 300,
                  borderRadius: BorderRadius.zero,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.shimmerBase,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
              )
            : Container(
                color: AppColors.shimmerBase,
                child: const Icon(
                  Icons.newspaper_rounded,
                  size: 48,
                  color: AppColors.textHint,
                ),
              ),

        // Gradient overlay
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.imageOverlay,
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Back Button ────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: AppRadius.smAll,
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: AppRadius.smAll,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Read More Button ───────────────────────────────────────────────────────────

class _ReadMoreButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ReadMoreButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: Text(label, style: AppTextStyles.button.copyWith(
          color: AppColors.textWhite,
        )),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          elevation: 0,
        ),
      ),
    );
  }
}