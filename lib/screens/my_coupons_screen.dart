

import 'package:flutter/material.dart';
import 'package:shiry_kids_app/widgets/show_img_dialog.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import '../widgets/network_image.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';

const String _baseUrl = 'https://back.sherykids.com';



String _imgUrl(dynamic v) {
  if (v == null || v.toString().isEmpty) return '';
  final s = v.toString();
  return s.startsWith('http') ? s : '$_baseUrl$s';
}

// ── Model ─────────────────────────────────────────────────────────────────────

class _UserCoupon {
  final String name, imageUrl;
  final List<String> qrImages;
  final double price;
  final int quantity;
  final bool used;
  const _UserCoupon({
    required this.name, required this.imageUrl, required this.price,
    required this.quantity, required this.used, required this.qrImages,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});
  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  bool _loading = true;
  List<_UserCoupon> _coupons = [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getMyOrders();
      final data = res['data'];
      final rows = data is List
          ? data
          : (data is Map && data['rows'] is List ? data['rows'] as List : <dynamic>[]);

      final coupons = <_UserCoupon>[];
      for (final o in rows) {
        final order = o as Map<String, dynamic>;
        final items = (order['items'] as List? ?? [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        final qrCodes = (order['coupon_qr_codes'] as List? ?? [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        for (final item in items) {
          if (item['type'] != 'coupon') continue;
          final couponId = item['id'];
          final couponQrs = qrCodes.where((q) => q['coupon_id'] == couponId).toList();
          final used = couponQrs.isNotEmpty &&
              couponQrs.every((q) => q['status'] == 'used');
          final qrImages = couponQrs
              .map((q) => _imgUrl(q['image']))
              .where((s) => s.isNotEmpty)
              .toList();
          coupons.add(_UserCoupon(
            name: item['name']?.toString() ?? '',
            imageUrl: _imgUrl(item['image']),
            price: double.tryParse(item['price']?.toString() ?? '0') ?? 0,
            quantity: int.tryParse(item['quantity']?.toString() ?? '1') ?? 1,
            used: used,
            qrImages: qrImages,
          ));
        }
      }

      if (mounted) setState(() { _coupons = coupons; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const WavyAppBar(title: 'My Profile', showBack: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: _Breadcrumb(parts: ['My Profile'.tr(context), 'My Coupons'.tr(context)]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _coupons.isEmpty
                    ? Center(
                        child: Text('No coupons yet'.tr(context),
                            style: const TextStyle(color: AppColors.textLight, fontSize: 14)))
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadCoupons,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _coupons.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _CouponCard(coupon: _coupons[i]),
                        ),
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
            child: smartImage(coupon.imageUrl, width: _imgW, height: 130, fit: BoxFit.cover),
          ),

          // Middle content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('${'Qty'.tr(context)}: ${coupon.quantity}',
                      style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),

                  const Spacer(),
                  InkWell(
                    onTap: coupon.qrImages.isEmpty ? null : () {
                      showDialog(context: context,
                          builder:(context)=> ShowImgDialog(images: coupon.qrImages, isCoupon: false),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9E3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                             'View'.tr(context),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right: price
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 20, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Used / Active button
                Text(
                  (coupon.used ? 'Used' : 'Active').tr(context),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text('${coupon.price} Kd',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ],
            ),
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
