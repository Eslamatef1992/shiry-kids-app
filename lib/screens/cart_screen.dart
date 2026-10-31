import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/wavy_app_bar.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: WavyAppBar(title: 'My Cart', showBack: false),
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.shopping_cart_outlined,
                    size: 72, color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text('Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text('Add some items to get started!',
                    style: TextStyle(color: AppColors.textMedium)),
              ]),
            ),
          );
        }

        final double delivery = 1.5;
        final double total = cart.subtotal + delivery;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: WavyAppBar(title: 'My Cart', showBack: false),
          body: Column(children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                children: [
                  // Coupon items
                  if (cart.coupons.isNotEmpty) ...[
                    const _SectionLabel('Coupons'),
                    const SizedBox(height: 8),
                    ...cart.coupons.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CouponCard(
                        item: c,
                        onRemove: () => cart.removeCoupon(c.id),
                        onQtyChange: (q) => cart.updateCouponQty(c.id, q),
                      ),
                    )),
                  ],

                  // Product items
                  if (cart.products.isNotEmpty) ...[
                    const _SectionLabel('Products'),
                    const SizedBox(height: 8),
                    ...cart.products.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProductCard(
                        item: p,
                        onRemove: () => cart.removeProduct(p.product.id),
                        onQtyChange: (q) => cart.updateProductQty(p.product.id, q),
                      ),
                    )),
                  ],
                ],
              ),
            ),

            // Order summary
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
              ),
              child: Column(children: [
                _SummaryRow('Subtotal', '${cart.subtotal.toStringAsFixed(2)} Kd'),
                const SizedBox(height: 8),
                _SummaryRow('Delivery', '${delivery.toStringAsFixed(2)} Kd'),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider()),
                _SummaryRow('Total', '${total.toStringAsFixed(2)} Kd', bold: true),
                const SizedBox(height: 16),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(
                              coupons: cart.coupons,
                              products: cart.products,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Proceed to Checkout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

// ── Coupon cart card ──────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final CartCouponItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;
  const _CouponCard({required this.item, required this.onRemove, required this.onQtyChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(item.imageUrl,
              width: 72, height: 72, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 72, height: 72,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.local_offer_outlined,
                      color: AppColors.primary, size: 32))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(item.brandName,
                style: const TextStyle(fontSize: 12, color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${item.price.toInt()} Kd',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
              const SizedBox(width: 6),
              Text(item.discount,
                  style: const TextStyle(fontSize: 11, color: Colors.green,
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
        Column(children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline, color: AppColors.textLight, size: 22),
          ),
          const SizedBox(height: 8),
          _QtyControl(
            qty: item.quantity,
            onDec: item.quantity > 1 ? () => onQtyChange(item.quantity - 1) : null,
            onInc: () => onQtyChange(item.quantity + 1),
          ),
        ]),
      ]),
    );
  }
}

// ── Product cart card ─────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;
  const _ProductCard({required this.item, required this.onRemove, required this.onQtyChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(item.product.imageUrl,
              width: 72, height: 72, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 72, height: 72,
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.image_outlined,
                      color: Color(0xFFCCCCCC), size: 32))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(item.product.category,
                style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
            const SizedBox(height: 6),
            Text('${item.product.price.toStringAsFixed(2)} Kd',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ]),
        ),
        Column(children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline, color: AppColors.textLight, size: 22),
          ),
          const SizedBox(height: 8),
          _QtyControl(
            qty: item.quantity,
            onDec: item.quantity > 1 ? () => onQtyChange(item.quantity - 1) : null,
            onInc: () => onQtyChange(item.quantity + 1),
          ),
        ]),
      ]),
    );
  }
}

// ── Qty control ───────────────────────────────────────────────────────────────

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback? onDec;
  final VoidCallback onInc;
  const _QtyControl({required this.qty, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _Btn(icon: Icons.remove, onTap: onDec, active: onDec != null),
      SizedBox(width: 28,
          child: Text('$qty', textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
      _Btn(icon: Icons.add, onTap: onInc, active: true),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  const _Btn({required this.icon, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 15, color: Colors.white),
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
          color: AppColors.textDark));
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? AppColors.textDark : AppColors.textMedium,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: bold ? AppColors.primary : null)),
      ],
    );
  }
}

// ── Summary Section ───────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final double subtotal;
  const _SummarySection({required this.subtotal});

  static const double _delivery = 1.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _SummaryRow('Subtotal', '${subtotal.toStringAsFixed(2)} KD'),
          const SizedBox(height: 8),
          _SummaryRow('Delivery', '${_delivery.toStringAsFixed(2)} KD'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          _SummaryRow('Total', '${(subtotal + _delivery).toStringAsFixed(2)} KD', bold: true),
        ],
      ),
    );
  }
}

// ── Guest or Login dialog ─────────────────────────────────────────────────────

class _GuestOrLoginDialog extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGuest;
  const _GuestOrLoginDialog({required this.onLogin, required this.onGuest});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('How would you like to proceed?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMedium)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Log In',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Continue as Guest',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
