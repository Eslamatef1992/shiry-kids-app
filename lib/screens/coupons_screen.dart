import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  static const List<Coupon> _coupons = [
    Coupon(id: '1', code: 'KIDS20', title: '20% Off Toys', description: 'Get 20% off all toys this weekend only!', discount: 20, isPercent: true, expiryDate: '30 Jun 2026'),
    Coupon(id: '2', code: 'BOOK10', title: '\$10 Off Books', description: 'Save \$10 on any book order over \$30.', discount: 10, isPercent: false, expiryDate: '15 Jul 2026'),
    Coupon(id: '3', code: 'ART30', title: '30% Off Art Kits', description: 'All art supplies at 30% discount.', discount: 30, isPercent: true, expiryDate: '10 Jul 2026'),
    Coupon(id: '4', code: 'SUMMER50', title: 'Summer Sale 50%', description: 'Half price on selected summer items.', discount: 50, isPercent: true, expiryDate: '31 Aug 2026', isUsed: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Coupons')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Coupons', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Tap a coupon to copy the code', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const Text('🎟️', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._coupons.map((c) => _CouponCard(coupon: c)),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: coupon.isUsed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left color strip
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: coupon.isUsed ? AppColors.textLight : AppColors.primary,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              // Dashed separator area
              SizedBox(
                width: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (_) => Container(margin: const EdgeInsets.symmetric(vertical: 3), width: 1, height: 6, color: AppColors.divider),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    coupon.code,
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                                if (coupon.isUsed) ...[
                                  const SizedBox(width: 8),
                                  const Text('Used', style: TextStyle(color: AppColors.textLight, fontSize: 11)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              coupon.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              coupon.description,
                              style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textLight),
                                const SizedBox(width: 4),
                                Text('Expires ${coupon.expiryDate}', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Discount badge
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            coupon.isPercent ? '${coupon.discount.toInt()}%' : '\$${coupon.discount.toInt()}',
                            style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          const Text('OFF', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          if (!coupon.isUsed)
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: coupon.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Code "${coupon.code}" copied!'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Copy', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
