import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import '../models/product.dart' show AppOrder;
import '../l10n/app_strings.dart';
import '../services/api_service.dart';

class OrderInvoiceScreen extends StatefulWidget {
  final AppOrder order;
  const OrderInvoiceScreen({super.key, required this.order});

  @override
  State<OrderInvoiceScreen> createState() => _OrderInvoiceScreenState();
}

class _OrderInvoiceScreenState extends State<OrderInvoiceScreen> {
  String? _name;
  String? _phone;
  String? _address;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiService.getProfile();
      if (!mounted) return;
      if (res['success'] == true) {
        final user = res['user'] as Map<String, dynamic>?;
        if (user != null) {
          setState(() {
            _name = user['name'] as String?;
            _phone = user['phone'] as String?;
            _address = user['address'] as String?;
            _email = user['email'] as String?;
          });
        }
      }
    } catch (_) {
      // Keep whatever we have; invoice still renders without customer info.
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isPaid = order.paymentStatus == 'paid';
    final items = order.items
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final subtotal = items.fold<double>(
        0, (s, i) => s + (double.tryParse(i['price']?.toString() ?? '0') ?? 0));
    final dateStr =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          // Breadcrumb
          _Breadcrumb(parts: ['My Profile'.tr(context), 'My Orders'.tr(context), '#${order.orderNumber}']),
          const SizedBox(height: 16),

          // ── Header card ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: logo + customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo_cropped.png', height: 60,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80, height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('SHIRY\nKIDS FUN',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary))),
                          )),
                      const SizedBox(height: 14),
                      Text('Customer Information'.tr(context),
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                      const SizedBox(height: 4),
                      if ((_name ?? '').trim().isNotEmpty || (_email ?? '').trim().isNotEmpty) ...[
                        Text((_name ?? '').trim().isNotEmpty ? _name! : _email!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                      ],
                      if ((_address ?? '').trim().isNotEmpty) ...[
                        Text(_address!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                      ],
                      if ((_phone ?? '').trim().isNotEmpty)
                        Text(_phone!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                    ],
                  ),
                ),
                // Right: invoice meta
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Invoice Id'.tr(context),
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text('#${order.orderNumber}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    Text('Order Date'.tr(context),
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text(dateStr,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    Text('Payment Status'.tr(context),
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text((isPaid ? 'Paid' : 'Not Paid').tr(context),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    Text('Payment Method'.tr(context),
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text(order.paymentMethod,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Product table ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9E3),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    Expanded(child: Text('Product\nName'.tr(context),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 40, child: Text('Qty'.tr(context),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 40, child: Text('Size'.tr(context),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 44, child: Text('Color'.tr(context),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 54, child: Text('Price'.tr(context),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  ]),
                ),

                // Item rows
                ...items.asMap().entries.map((e) {
                  final i = e.value;
                  final isLast = e.key == items.length - 1;
                  final price = double.tryParse(i['price']?.toString() ?? '0') ?? 0;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(children: [
                          Expanded(child: Text(i['product_name']?.toString() ?? i['name']?.toString() ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 40, child: Text('${i['quantity'] ?? i['qty'] ?? 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 40, child: Text(i['size']?.toString() ?? '-',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 44, child: Text(i['color']?.toString() ?? '-',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 54, child: Text('${price.toInt()} Kd',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                        ]),
                      ),
                      if (!isLast) const Divider(height: 1, indent: 12, endIndent: 12, color: Color(0xFFF0F0F0)),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Totals card ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                _TotalRow(label: 'Subtotal',      value: '${subtotal.toInt()} Kw'),
                const SizedBox(height: 10),
                _TotalRow(label: 'Discount',      value: '0.00 Kw', valueColor: AppColors.primary),
                const SizedBox(height: 10),
                _TotalRow(label: 'Shipping Fees', value: '0.00 Kw'),
                const SizedBox(height: 10),
                _TotalRow(label: 'Delivery Fees', value: '0.00 Kw'),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total'.tr(context),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    Text('${order.total.toInt()} Kwd',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _TotalRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label.tr(context), style: const TextStyle(fontSize: 13, color: AppColors.textLight,
        fontWeight: FontWeight.w600,
      )),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
          color: valueColor ?? AppColors.textDark)),
    ],
  );
}

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
