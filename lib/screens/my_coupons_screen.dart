import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class _UserCoupon {
  final String imageUrl, brandImageUrl, brandName, countdown, discount;
  final bool used;
  const _UserCoupon({
    required this.imageUrl, required this.brandImageUrl, required this.brandName,
    required this.countdown, required this.discount, this.used = true,
  });
}

final _myCoupons = const [
  _UserCoupon(
    imageUrl: 'assets/images/weekly_1.jpg',
    brandImageUrl: 'assets/images/logo_cropped.png',
    brandName: 'Kuwait Pool', countdown: '3 Days : 13 Hours : 30 Sec',
    discount: '50 %', used: true,
  ),
  _UserCoupon(
    imageUrl: 'assets/images/weekly_1.jpg',
    brandImageUrl: 'assets/images/logo_cropped.png',
    brandName: 'Kuwait Pool', countdown: '3 Days : 13 Hours : 30 Sec',
    discount: '50 %', used: true,
  ),
  _UserCoupon(
    imageUrl: 'assets/images/weekly_1.jpg',
    brandImageUrl: 'assets/images/logo_cropped.png',
    brandName: 'Kuwait Pool', countdown: '0 Days : 1 Hours : 00 Sec',
    discount: '50 %', used: true,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class MyCouponsScreen extends StatelessWidget {
  const MyCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile', showBack: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: _Breadcrumb(parts: const ['My Profile', 'My Coupons']),
          ),
          Expanded(
            child: _myCoupons.isEmpty
                ? const Center(
                    child: Text('No coupons yet',
                        style: TextStyle(color: AppColors.textLight, fontSize: 14)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _myCoupons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CouponCard(coupon: _myCoupons[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Coupon card ───────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final _UserCoupon coupon;
  const _CouponCard({required this.coupon});

  static const double _imgW = 110.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Left image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.asset(coupon.imageUrl,
                width: _imgW, height: 130, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: _imgW, color: const Color(0xFFF5F5F5),
                    child: const Icon(Icons.image_outlined, color: Color(0xFFCCCCCC)))),
          ),

          // Middle content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Countdown
                  Text(coupon.countdown,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMedium)),
                  const SizedBox(height: 6),

                  // Brand logo + name row
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset(coupon.brandImageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(Icons.storefront_outlined,
                                    size: 14, color: AppColors.primary))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(coupon.brandName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ]),
                  const Spacer(),

                  // Used / Active button
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        coupon.used ? 'Used' : 'Active',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right: discount
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
            child: Text(coupon.discount,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ── Breadcrumb ────────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  final List<String> parts;
  const _Breadcrumb({required this.parts});
  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (int i = 0; i < parts.length; i++) {
      final isLast = i == parts.length - 1;
      widgets.add(Text(parts[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            color: isLast ? AppColors.primary : AppColors.textMedium,
          )));
      if (!isLast) widgets.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('»', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
      ));
    }
    return Wrap(children: widgets);
  }
}
