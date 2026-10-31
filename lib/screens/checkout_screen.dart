import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/wavy_app_bar.dart';
import '../services/api_service.dart';
import 'payment_success_screen.dart';

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
  String _paymentMethod = 'knet';
  bool _loading = false;

  static const double _delivery = 1.5;

  double get _subtotal =>
      widget.coupons.fold(0.0, (s, c) => s + c.total) +
      widget.products.fold(0.0, (s, p) => s + p.total);

  double get _total => _subtotal + _delivery;

  bool _isPhoneValid(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 8;
  }

  Future<Map<String, String>?> _collectGuestInfo() async {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    final hasProducts = widget.products.isNotEmpty;
    String? phoneError;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final nameOk  = nameCtrl.text.trim().isNotEmpty;
          final phoneOk = _isPhoneValid(phoneCtrl.text);
          final addrOk  = !hasProducts || addressCtrl.text.trim().isNotEmpty;
          final canProceed = nameOk && phoneOk && addrOk;

          return AlertDialog(
            title: const Text('المتابعة كزائر', textAlign: TextAlign.right),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      border: OutlineInputBorder(),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  // Phone — 8 digits validation
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    onChanged: (v) => setState(() {
                      phoneError = v.isEmpty
                          ? null
                          : (_isPhoneValid(v) ? null : 'Phone must be 8 digits');
                    }),
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '5XXXXXXX',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      prefixText: '+965  ',
                      errorText: phoneError,
                    ),
                  ),
                  // Location — only for product orders
                  if (hasProducts) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      onChanged: (_) => setState(() {}),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        hintText: 'Enter delivery address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textMedium)),
              ),
              ElevatedButton(
                onPressed: canProceed
                    ? () => Navigator.pop(ctx, {
                          'name': nameCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'address': hasProducts ? addressCtrl.text.trim() : 'Kuwait',
                        })
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text('متابعة', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pay() async {
    final info = await _collectGuestInfo();
    if (info == null || !mounted) return;

    setState(() => _loading = true);
    try {
      final items = [
        ...widget.coupons.map((c) => {
          'id': c.backendId,
          'type': 'coupon',
          'quantity': c.quantity,
          'name': c.title,
          'price': c.price,
        }),
        ...widget.products.map((p) => {
          'id': int.tryParse(p.product.id) ?? 0,
          'type': 'product',
          'quantity': p.quantity,
          'name': p.product.name,
          'price': p.product.price,
        }),
      ];

      final result = await ApiService.createGuestOrder(
        name: info['name']!,
        phone: info['phone']!,
        email: '',
        address: info['address'] ?? 'Kuwait',
        items: items,
        paymentMethod: _paymentMethod,
        subtotal: _subtotal,
        deliveryFees: _delivery,
        total: _total,
      );

      if (!mounted) return;

      final order = result['data'] as Map<String, dynamic>? ?? {};
      final rawQrs = (order['coupon_qr_codes'] as List?) ?? [];
      final qrUrls = rawQrs
          .map((q) => (q['image'] ?? '') as String)
          .where((img) => img.isNotEmpty)
          .toList();

      context.read<CartProvider>().clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderNumber: order['order_number'] ?? '',
            subtotal: _subtotal,
            discount: 0.0,
            shippingFees: 0.0,
            deliveryFees: _delivery,
            qrImageUrls: qrUrls,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الطلب: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Checkout', showBack: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order items summary
                  if (widget.coupons.isNotEmpty) ...[
                    _SectionHeader('Coupons (${widget.coupons.length})'),
                    const SizedBox(height: 8),
                    ...widget.coupons.map((c) => _ItemRow(
                          name: c.title,
                          qty: c.quantity,
                          price: c.total,
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (widget.products.isNotEmpty) ...[
                    _SectionHeader('Products (${widget.products.length})'),
                    const SizedBox(height: 8),
                    ...widget.products.map((p) => _ItemRow(
                          name: p.product.name,
                          qty: p.quantity,
                          price: p.total,
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Payment method
                  _SectionHeader('طريقة الدفع'),
                  const SizedBox(height: 10),
                  _PaymentOption(
                    label: 'Visa / MasterCard',
                    icon: Icons.credit_card,
                    selected: _paymentMethod == 'visa',
                    onTap: () => setState(() => _paymentMethod = 'visa'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    label: 'KNET',
                    icon: Icons.account_balance,
                    selected: _paymentMethod == 'knet',
                    onTap: () => setState(() => _paymentMethod = 'knet'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    label: 'الدفع عند الاستلام',
                    icon: Icons.money,
                    selected: _paymentMethod == 'cod',
                    onTap: () => setState(() => _paymentMethod = 'cod'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom summary + pay
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, -4))
              ],
            ),
            child: Column(
              children: [
                _SummaryRow('المجموع الفرعي', '${_subtotal.toStringAsFixed(2)} KD'),
                const SizedBox(height: 8),
                _SummaryRow('التوصيل', '${_delivery.toStringAsFixed(2)} KD'),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider()),
                _SummaryRow('الإجمالي', '${_total.toStringAsFixed(2)} KD',
                    bold: true),
                const SizedBox(height: 16),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              'ادفع ${_total.toStringAsFixed(2)} KD',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark));
}

class _ItemRow extends StatelessWidget {
  final String name;
  final int qty;
  final double price;
  const _ItemRow({required this.name, required this.qty, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text('$name × $qty',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textDark))),
          Text('${price.toStringAsFixed(2)} KD',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentOption(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF5F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textMedium),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected
                        ? AppColors.textDark
                        : AppColors.textMedium)),
            const Spacer(),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.primary),
                child:
                    const Icon(Icons.check, size: 13, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
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
        Text(value,
            style: style.copyWith(
                color: bold ? AppColors.primary : null)),
      ],
    );
  }
}
