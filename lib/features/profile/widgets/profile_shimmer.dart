import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expensive/core/utils/app_fonts.dart';
import 'package:expensive/core/utils/app_space.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        duration: const Duration(seconds: 1),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionSkeleton("NICKNAME"),
            _buildBoxSkeleton(),
            AppSpacing.h(25),
            _buildSectionSkeleton("ALERT LIMIT (₹)"),
            _buildBoxSkeleton(),
            AppSpacing.h(25),
            _buildSectionSkeleton("CATEGORIES"),
            _buildBoxSkeleton(height: 150),
            AppSpacing.h(25),
            _buildSectionSkeleton("CLOUD SYNC"),
            _buildBoxSkeleton(height: 80),
            AppSpacing.h(25),
            _buildBoxSkeleton(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSkeleton(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppFontStyle.medium.copyWith(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildBoxSkeleton({double height = 60}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
    );
  }
}
