import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../screens/product_detail_screen.dart';
import '../screens/coupon_detail_screen.dart';

/// Fetches active ads and, if any exist, shows a full-screen promo popup
/// once. Call this from the main shell's initState (after first frame).
Future<void> showAdPopup(BuildContext context) async {
  try {
    final res = await ApiService.getAds();
    final list = (res['data'] as List?) ?? [];
    if (list.isEmpty) return;

    final ads = list.map((j) => AppAd.fromJson(j as Map<String, dynamic>)).toList();
    final ad = ads.first;
    if (ad.imageUrl.isEmpty) return;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => _AdPopupDialog(ad: ad),
    );
  } catch (e) {
    debugPrint('showAdPopup error: $e');
  }
}

class _AdPopupDialog extends StatelessWidget {
  final AppAd ad;
  const _AdPopupDialog({required this.ad});

  Future<void> _handleTap(BuildContext context) async {
    Navigator.of(context).pop(); // close popup first

    switch (ad.linkType) {
      case 'product':
        if (ad.productId == null) return;
        try {
          final res = await ApiService.getProduct(int.parse(ad.productId!));
          final data = res['data'] as Map<String, dynamic>?;
          if (data == null || !context.mounted) return;
          final product = Product.fromJson(data);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              categoryName: product.category.isNotEmpty ? product.category : 'Product',
            ),
          ));
        } catch (e) {
          debugPrint('Ad product navigation error: $e');
        }
        break;

      case 'coupon':
        if (ad.couponId == null) return;
        try {
          final res = await ApiService.getCoupon(int.parse(ad.couponId!));
          final data = res['data'] as Map<String, dynamic>?;
          if (data == null || !context.mounted) return;
          final coupon = CouponProduct.fromJson(data);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => CouponDetailScreen(coupon: coupon),
          ));
        } catch (e) {
          debugPrint('Ad coupon navigation error: $e');
        }
        break;

      case 'external':
        final link = ad.externalLink;
        if (link == null || link.isEmpty) return;
        final uri = Uri.tryParse(link);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;

      default:
        break; // 'none' — just close
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: () => _handleTap(context),
              child: Image.network(
                ad.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: AppColors.white,
                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: AppColors.textLight)),
                ),
              ),
            ),
          ),
          Positioned(
            top: -16,
            right: -8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: const Icon(Icons.close, size: 20, color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
