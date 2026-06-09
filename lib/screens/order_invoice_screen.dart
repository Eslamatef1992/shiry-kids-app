import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import 'my_orders_screen.dart';

class OrderInvoiceScreen extends StatelessWidget {
  final Order order;
  const OrderInvoiceScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isPaid = order.paymentStatus == PaymentStatus.paid;
    final subtotal = order.items.fold<double>(0, (s, i) => s + i.price);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          // Breadcrumb
          _Breadcrumb(parts: ['My Profile', 'My Orders', order.id]),
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
                      const Text('Customer Information',
                          style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                      const SizedBox(height: 4),
                      const Text('Dina Rizk Mohamed',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      const Text('Kuwait , Kuwait City',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      const Text('+956 1234567',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark)),
                    ],
                  ),
                ),
                // Right: invoice meta
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Invoice Id',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text(order.id,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    const Text('Order Date',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text(order.date,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    const Text('Payment Status',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text(isPaid ? 'Paid' : 'Not Paid',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    const Text('Payment Method',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
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
                  child: Row(children: const [
                    Expanded(child: Text('Product\nName',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 40, child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 40, child: Text('Size',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 44, child: Text('Color',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    SizedBox(width: 54, child: Text('Price',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  ]),
                ),

                // Item rows
                ...order.items.asMap().entries.map((e) {
                  final i = e.value;
                  final isLast = e.key == order.items.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(children: [
                          Expanded(child: Text(i.productName,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 40, child: Text('${i.qty}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 40, child: Text(i.size,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 44, child: Text(i.color,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
                          SizedBox(width: 54, child: Text('${i.price.toInt()} Kd',
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
                    const Text('Total',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
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
