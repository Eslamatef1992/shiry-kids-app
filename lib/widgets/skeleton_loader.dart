import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Wraps [child] in a shimmer animation. Use with [SkeletonBox] placeholders.
Widget shimmerWrap({required Widget child}) => Shimmer.fromColors(
      baseColor: const Color(0xFFEDEDED),
      highlightColor: const Color(0xFFF7F7F7),
      child: child,
    );

/// Simple rounded-rectangle placeholder block for shimmer layouts.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  const SkeletonBox({super.key, this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Full home-screen skeleton — banner, categories, coupons, product rows.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => shimmerWrap(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Banner
            const SkeletonBox(height: 155, radius: 14, width: double.infinity),
            const SizedBox(height: 18),

            // Categories
            const SkeletonBox(width: 100, height: 16),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => const SkeletonBox(width: 100, height: 56, radius: 28),
              ),
            ),
            const SizedBox(height: 20),

            // Coupons
            const SkeletonBox(width: 80, height: 16),
            const SizedBox(height: 10),
            SizedBox(
              height: 172,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => const SkeletonBox(width: 320, height: 172, radius: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Product rows
            for (int s = 0; s < 2; s++) ...[
              const SkeletonBox(width: 120, height: 16),
              const SizedBox(height: 10),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => const SkeletonBox(width: 162, height: 270, radius: 14),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      );
}

/// Grid of product-card skeletons (Products screen).
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) => shimmerWrap(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const SkeletonBox(radius: 14, width: double.infinity, height: double.infinity),
        ),
      );
}

/// List of coupon-ticket skeletons (Coupons screen / home coupon row).
class CouponListSkeleton extends StatelessWidget {
  const CouponListSkeleton({super.key});

  @override
  Widget build(BuildContext context) => shimmerWrap(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, __) => const SkeletonBox(height: 172, radius: 14, width: double.infinity),
        ),
      );
}

/// Generic "something went wrong" view with a retry button — used when an
/// API call fails or times out so the screen never appears to be stuck
/// loading forever.
class LoadErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const LoadErrorView({super.key, this.message = "Couldn't load data. Check your connection and try again.", required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
}
