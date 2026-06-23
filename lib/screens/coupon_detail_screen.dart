import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/wavy_app_bar.dart';
import '../widgets/network_image.dart';
import '../l10n/app_strings.dart';

class CouponDetailScreen extends StatefulWidget {
  final CouponProduct coupon;
  const CouponDetailScreen({super.key, required this.coupon});
  @override
  State<CouponDetailScreen> createState() => _CouponDetailScreenState();
}

class _CouponDetailScreenState extends State<CouponDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _confirm() {
    // Confirm locks in the qty — nothing visible to do here since Add To Cart is bottom btn
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'Quantity set to'.tr(context)} $_qty'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    cart.addCoupon(widget.coupon.toCartItem(quantity: _qty));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to cart!'.tr(context)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.coupon;
    final isArabic = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    final description = isArabic && c.descriptionAr.trim().isNotEmpty
        ? c.descriptionAr
        : c.description;
    final terms = isArabic && c.termsAndConditionsAr.trim().isNotEmpty
        ? c.termsAndConditionsAr
        : c.termsAndConditions;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WavyAppBar(title: 'Coupons', showBack: true),
      body: Column(children: [
        // ── Breadcrumb ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Coupons'.tr(context),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium,fontWeight: FontWeight.w600)),
            ),
            const Text('  »  ',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
            Text('Coupons Details'.tr(context),
                style: const TextStyle(fontSize: 14, color: AppColors.textDark,
                    fontWeight: FontWeight.w700)),
          ]),
        ),

        // ── Scrollable content ──────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Hero image ──
              AspectRatio(
                aspectRatio: 16 / 9,
                child: smartImage(c.imageUrl, fit: BoxFit.cover,
                    placeholder: Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Icon(Icons.image_outlined,
                            color: Color(0xFFCCCCCC), size: 64))),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── Brand ──
                  Row(children: [
                    ClipOval(
                      child: smartImage(c.brandImageUrl,
                          width: 32, height: 32, fit: BoxFit.cover,
                          placeholder: Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.storefront_outlined,
                                  size: 16, color: AppColors.primary))),
                    ),
                    const SizedBox(width: 10),
                    Text(c.brandName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 14),

                  // ── Tabs ──
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800),
                      unselectedLabelStyle:
                          const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMedium,
                      tabs: [
                        Tab(text: 'Description'.tr(context)),
                        Tab(text: 'Terms & Conditions'.tr(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Tab content ──
                  _tabs.index == 0
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(description,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMedium,
                                  height: 1.6)
                          ),
                          const SizedBox(height: 12),
                          // Countdown
                          _CountdownRow(expiresAt: c.expiresAt),
                          const SizedBox(height: 10),
                          // Price
                          Row(children: [
                            Text('${c.price.toInt()} Kd',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800,
                                    color: AppColors.textDark)),
                            const SizedBox(width: 8),
                            Text('${c.originalPrice.toInt()} Kd',
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.primary,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.primary)),
                            const SizedBox(width: 6),
                            Text('-${c.discountPercent}%',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ]),
                        ])
                      : Text(terms,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMedium, height: 1.7)),

                  const SizedBox(height: 18),

                  // ── Expire / Coupons left ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Expire Date'.tr(context),
                            style: const TextStyle(fontSize: 12, color: AppColors.textLight,fontWeight: FontWeight.w600,)),
                        const SizedBox(height: 4),
                        Text(c.expiryDate,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                      ]),
                      Container(width: 1, height: 36, color:Colors.white),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Coupons Left'.tr(context),
                            style: const TextStyle(fontSize: 11,fontWeight: FontWeight.w600,color: AppColors.textLight)),
                        const SizedBox(height: 4),
                        Text('${c.qrTotal > 0 ? c.qrAvailable : c.couponsLeft}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // ── Quantity picker ────────────────────────────
                  if (!c.isOutOfStock)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Number Of Cpouons You Want:'.tr(context),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                          const SizedBox(height: 14),
                          Row(children: [
                            _QtyBtn(
                              icon: Icons.remove,
                              onTap: () { if (_qty > 1) setState(() => _qty--); },
                              filled: false,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration:  BoxDecoration(
                                  color: const Color(0xffF8F8F8),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Text('$_qty',
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.w700,
                                          color: AppColors.textDark)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _QtyBtn(
                              icon: Icons.add,
                              onTap: () {
                                final max = c.qrTotal > 0 ? c.qrAvailable : null;
                                if (max == null || _qty < max) setState(() => _qty++);
                              },
                              filled: true,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          // ── Confirm ────────────────────────────────────
                          InkWell(
                            onTap:_confirm,
                            child: Container(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffFFE9E3),
                              ),
                              child: Center(
                                child: Text('Confirm'.tr(context),
                                    style: const TextStyle(fontSize: 15,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  const SizedBox(height: 100),
                ]),
              ),
            ]),
          ),
        ),
      ]),

      // ── Add To Cart ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200,width: 1.5)) ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).padding.bottom + 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: c.isOutOfStock ? null : _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.isOutOfStock ? const Color(0xFFCCCCCC) : AppColors.primary,
                disabledBackgroundColor: const Color(0xFFCCCCCC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                c.isOutOfStock ? 'Out of Stock'.tr(context) : 'Add To Cart'.tr(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Countdown row ─────────────────────────────────────────────────────────────

class _CountdownRow extends StatefulWidget {
  final DateTime expiresAt;
  const _CountdownRow({required this.expiresAt});
  @override
  State<_CountdownRow> createState() => _CountdownRowState();
}

class _CountdownRowState extends State<_CountdownRow> {
  late Duration _remaining;
  Timer? _timer;

  Duration _calc() {
    final diff = widget.expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void initState() {
    super.initState();
    _remaining = _calc();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _calc());
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final s = _remaining.inSeconds.remainder(60);
    return Text(
      '$d ${'Days'.tr(context)} : ${h.toString().padLeft(2, '0')} ${'Hours'.tr(context)} : ${s.toString().padLeft(2, '0')} ${'Sec'.tr(context)}',
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
    );
  }
}

// ── Qty button ────────────────────────────────────────────────────────────────

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyBtn({required this.icon, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : const Color(0xffFFE9E3),
        borderRadius: BorderRadius.circular(8),
       // border: filled ? null : Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Icon(icon,
          size: 18,
          color: filled ? Colors.white : AppColors.primary),
    ),
  );
}
