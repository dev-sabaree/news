import 'package:flutter/material.dart';
import 'package:newsapp/core/themes/app_radius.dart';
import 'package:newsapp/core/themes/app_spacing.dart';
import 'shimmer_widget.dart';

class NewsShimmerCard extends StatelessWidget {
  const NewsShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            width: double.infinity,
            height: 180,
            borderRadius: AppRadius.mdAll,
          ),
          const SizedBox(height: AppSpacing.md),
          ShimmerWidget(
            width: 100,
            height: 12,
            borderRadius: AppRadius.smAll,
          ),
          const SizedBox(height: AppSpacing.sm),
          ShimmerWidget(
            width: double.infinity,
            height: 16,
            borderRadius: AppRadius.smAll,
          ),
          const SizedBox(height: AppSpacing.xs),
          ShimmerWidget(
            width: double.infinity * 0.7,
            height: 16,
            borderRadius: AppRadius.smAll,
          ),
          const SizedBox(height: AppSpacing.sm),
          ShimmerWidget(
            width: 140,
            height: 12,
            borderRadius: AppRadius.smAll,
          ),
        ],
      ),
    );
  }
}