import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/wavy_app_bar.dart';
import '../widgets/coupon_ticket_card.dart';
import 'coupon_detail_screen.dart';
import '../services/api_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  List<CouponProduct> _allCoupons = [];
  String _selected = 'all';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      final res = await ApiService.getCoupons();
      if (mounted) {
        final list = (res['data'] as List?) ?? [];
        setState(() {
          _allCoupons = list.map((j) => CouponProduct.fromJson(j as Map<String, dynamic>)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<CouponProduct> get _filtered => _selected == 'all'
      ? _allCoupons
      : _allCoupons.where((c) => c.category == _selected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Coupons', showBack: false),
      body: Column(children: [
        // ── Category header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('All Categories(${_allCoupons.length})',
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium,
                    fontWeight: FontWeight.w500)),
          ),
        ),

        // ── Category chips ────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: 'Birthday',
                selected: _selected == 'birthday',
                onTap: () => setState(() =>
                    _selected = _selected == 'birthday' ? 'all' : 'birthday'),
              ),
              const SizedBox(width: 10),
              _CategoryChip(
                label: "Mother's Day",
                selected: _selected == 'mothers_day',
                onTap: () => setState(() =>
                    _selected = _selected == 'mothers_day' ? 'all' : 'mothers_day'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Coupon list ───────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _filtered.isEmpty
              ? const Center(child: Text('No coupons found',
                  style: TextStyle(color: AppColors.textMedium)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _CouponCard(item: _filtered[i]),
                ),
        ),
      ]),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEDED) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFEEEEEE)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary.withOpacity(0.15) : const Color(0xFFF0F0F0),
            ),
            child: Icon(
              label == 'Birthday' ? Icons.cake_outlined : Icons.favorite_border,
              size: 14,
              color: selected ? AppColors.primary : AppColors.textMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textDark)),
        ]),
      ),
    );
  }
}

// ── Coupon card ───────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final CouponProduct item;
  const _CouponCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final d = item.expiresAt.difference(DateTime.now());
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final secs = d.inSeconds.remainder(60);
    final countdown =
        '$days Days : ${hours.toString().padLeft(2, '0')} Hours : ${secs.toString().padLeft(2, '0')} Sec';

    return CouponTicketCard(
      imageUrl: item.imageUrl,
      brandImageUrl: item.brandImageUrl,
      brandName: item.brandName,
      title: item.title,
      countdown: countdown,
      price: '${item.price.toInt()} Kd',
      originalPrice: '${item.originalPrice.toInt()} Kd',
      discount: '-${item.discountPercent}%',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CouponDetailScreen(coupon: item)),
      ),
      onAddToCart: () {
        context.read<CartProvider>().addCoupon(item.toCartItem(quantity: 1));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${item.title} added to cart!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ));
      },
    );
  }
}

