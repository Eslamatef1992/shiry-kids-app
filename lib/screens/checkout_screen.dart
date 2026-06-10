import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../widgets/wavy_app_bar.dart';
import '../widgets/network_image.dart';
import 'payment_success_screen.dart';
import 'payment_failed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartCouponItem> coupons;
  final List<CartItem> products;
  final bool hasCoupons;
  const CheckoutScreen({
    super.key,
    required this.coupons,
    required this.products,
    this.hasCoupons = false,
  });
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _delivery = 'address'; // 'address' | 'store'
  String _payment = 'knet';    // 'knet' | 'cod'
  bool _paying = false;

  double get _subtotal =>
      widget.coupons.fold(0.0, (s, c) => s + c.total) +
      widget.products.fold(0.0, (s, p) => s + p.total);

  int get _totalQty =>
      widget.coupons.fold(0, (s, c) => s + c.quantity) +
      widget.products.fold(0, (s, p) => s + p.quantity);

  Future<void> _payNow() async {
    setState(() => _paying = true);
    try {
      final items = [
        ...widget.coupons.map((c) => {'id': c.id, 'type': 'coupon', 'qty': c.quantity}),
        ...widget.products.map((p) => {'id': p.product.id, 'type': 'product', 'qty': p.quantity}),
      ];

      final isLoggedIn = await ApiService.isLoggedIn();
      Map<String, dynamic> res;

      if (isLoggedIn) {
        res = await ApiService.createOrder(
          items: items,
          paymentMethod: _payment,
          deliveryMethod: _delivery,
        );
      } else {
        res = await ApiService.createGuestOrder(
          items: items,
          paymentMethod: _payment,
          deliveryMethod: _delivery,
        );
      }

      if (!mounted) return;

      if (res['success'] == true) {
        final order = res['data'] as Map<String, dynamic>? ?? {};
        final orderId = order['order_number'] as String? ??
            '#${DateTime.now().millisecondsSinceEpoch % 100000}';
        final discount = double.tryParse('${order['discount'] ?? 0}') ?? 0.0;
        final shipping = double.tryParse('${order['shipping_fees'] ?? 0}') ?? 0.0;
        final delivery = double.tryParse('${order['delivery_fees'] ?? 0}') ?? 0.0;

        context.read<CartProvider>().clear();

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderId: orderId,
            subtotal: _subtotal,
            discount: discount,
            shippingFees: shipping,
            deliveryFees: delivery,
          ),
        ));
      } else {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const PaymentFailedScreen(),
        ));
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const PaymentFailedScreen(),
      ));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Checkout', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Shipping Details ──────────────────────────────────
          _SectionLabel('Shipping Details'),
          const SizedBox(height: 8),
          _ShippingCard(),
          const SizedBox(height: 18),

          // ── Cart Items ────────────────────────────────────────
          _SectionLabel('Cart Item($_totalQty)'),
          const SizedBox(height: 8),

          if (widget.coupons.isNotEmpty) ...[
            _SubLabel('Coupons'),
            ...widget.coupons.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CheckoutCouponCard(item: c),
            )),
          ],

          if (widget.products.isNotEmpty) ...[
            if (widget.coupons.isNotEmpty) _SubLabel('Products'),
            ...widget.products.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CheckoutProductCard(item: p),
            )),
          ],

          const SizedBox(height: 8),

          // ── Summary ───────────────────────────────────────────
          _SectionLabel('Summary', primary: true),
          const SizedBox(height: 8),
          _CheckoutSummary(subtotal: _subtotal),
          const SizedBox(height: 18),

          // ── Delivery Method ───────────────────────────────────
          _SectionLabel('Delivery Method', primary: true),
          const SizedBox(height: 8),
          _OptionCard(children: [
            _RadioOption(
              icon: Icons.local_shipping_outlined,
              label: 'Delivery To My Address',
              selected: _delivery == 'address',
              onTap: () => setState(() => _delivery = 'address'),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
            _RadioOption(
              icon: Icons.store_outlined,
              label: 'Pickup From Store',
              selected: _delivery == 'store',
              onTap: () => setState(() => _delivery = 'store'),
            ),
          ]),
          const SizedBox(height: 18),

          // ── Payment Method ────────────────────────────────────
          _SectionLabel('Payment Method', primary: true),
          const SizedBox(height: 8),
          _OptionCard(children: [
            _RadioOption(
              svgAsset: 'assets/icons/knet_logo.png',
              label: 'Knet',
              selected: _payment == 'knet',
              onTap: () => setState(() => _payment = 'knet'),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
            _RadioOption(
              svgAsset: 'assets/icons/visa_card.svg',
              label: 'Cash On Delivery',
              selected: _payment == 'cod',
              disabled: widget.hasCoupons,
              onTap: widget.hasCoupons ? null : () => setState(() => _payment = 'cod'),
            ),
          ]),

          // QR notice when coupons present
          if (widget.hasCoupons) ...[
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.campaign_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'The QR Code Will Be Displayed Immediately After The Payment Is Completed.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4),
                ),
              ),
            ]),
          ],
        ]),
      ),

      // ── Pay Now ───────────────────────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _paying ? null : _payNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _paying
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Pay Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool primary;
  const _SectionLabel(this.text, {this.primary = false});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700,
        color: primary ? AppColors.primary : AppColors.textMedium,
      ));
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
  );
}

class _ShippingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.location_on, color: AppColors.primary, size: 22),
      ),
      const SizedBox(width: 12),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kuwait', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text('Kuwait City ,Kuwait', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        Text('+956123456', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
      ]),
    ]),
  );
}

class _CheckoutCouponCard extends StatelessWidget {
  final CartCouponItem item;
  const _CheckoutCouponCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
    ),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: smartImage(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          Row(children: [
            ClipOval(
              child: smartImage(item.brandImageUrl, width: 14, height: 14, fit: BoxFit.cover,
                  placeholder: Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.storefront_outlined,
                          size: 10, color: AppColors.primary))),
            ),
            const SizedBox(width: 4),
            Text(item.brandName,
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
          Row(children: [
            Text('${item.price.toInt()} Kd',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(width: 6),
            Text('${item.originalPrice.toInt()} Kd',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight,
                    decoration: TextDecoration.lineThrough)),
            const SizedBox(width: 4),
            Text(item.discount,
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
          Text('Qty: ${item.quantity}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
        ]),
      ),
    ]),
  );
}

class _CheckoutProductCard extends StatelessWidget {
  final CartItem item;
  const _CheckoutProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final catLabel = p.category == 'birthday' ? 'Birthday' : "Mother's Day";
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: smartImage(p.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(catLabel,
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            Text('${p.price.toInt()} Kwd',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('Qty: ${item.quantity}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          ]),
        ),
      ]),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  final double subtotal;
  const _CheckoutSummary({required this.subtotal});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
    ),
    child: Column(children: [
      _Row('Subtotal', '${subtotal.toInt()} Kw'),
      _Row('Discount', '0.00 Kw', valueColor: AppColors.primary),
      _Row('Shipping Fees', '0.00 Kw'),
      _Row('Delivery Fees', '0.00 Kw'),
      const Divider(height: 16, color: Color(0xFFF0F0F0)),
      _Row('Total', '${subtotal.toInt()} Kwd', valueBold: true, valueColor: AppColors.primary),
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool valueBold;
  const _Row(this.label, this.value, {this.valueColor, this.valueBold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
      Text(value, style: TextStyle(
        fontSize: 13,
        color: valueColor ?? AppColors.textDark,
        fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
      )),
    ]),
  );
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
    ),
    child: Column(children: children),
  );
}

class _RadioOption extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  const _RadioOption({
    this.icon, this.svgAsset, required this.label,
    required this.selected, this.disabled = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = disabled ? AppColors.textLight : AppColors.textDark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          // Icon
          Container(
            width: 46, height: 36,
            decoration: BoxDecoration(
              color: disabled ? const Color(0xFFF5F5F5) : const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: svgAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(6),
                    child: svgAsset!.endsWith('.svg')
                        ? SvgPicture.asset(svgAsset!, fit: BoxFit.contain,
                            colorFilter: disabled
                                ? const ColorFilter.mode(AppColors.textLight, BlendMode.srcIn)
                                : null)
                        : Image.asset(svgAsset!, fit: BoxFit.contain,
                            color: disabled ? AppColors.textLight : null),
                  )
                : icon != null
                    ? Icon(icon, color: disabled ? AppColors.textLight : AppColors.primary, size: 20)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor))),
          // Radio
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : (disabled ? AppColors.textLight : const Color(0xFFCCCCCC)),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                    ),
                  )
                : null,
          ),
        ]),
      ),
    );
  }
}
