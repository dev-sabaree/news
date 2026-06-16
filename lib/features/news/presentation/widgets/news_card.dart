import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../domain/entities/news_entity.dart';

class NewsCard extends StatelessWidget {
  final NewsEntity article;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.article, required this.onTap});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _readTime(String content) {
    final words = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
              child: article.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ShimmerWidget(
                        width: double.infinity,
                        height: 200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.lg),
                          topRight: Radius.circular(AppRadius.lg),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200,
                        color: AppColors.shimmerBase,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: AppColors.shimmerBase,
                      child: const Icon(
                        Icons.newspaper_rounded,
                        size: 40,
                        color: AppColors.textHint,
                      ),
                    ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + Read time row
                  Row(
                    children: [
                      if (article.source.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
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
                      const Spacer(),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _readTime(article.content.isNotEmpty
                            ? article.content
                            : article.title),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),

                  if (article.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // Author + Date row
                  Row(
                    children: [
                      if (article.author.isNotEmpty) ...[
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            article.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ] else
                        const Spacer(),
                      if (article.publishedAt.isNotEmpty) ...[
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatDate(article.publishedAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}