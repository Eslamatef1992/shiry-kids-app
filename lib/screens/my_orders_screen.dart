import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import 'order_invoice_screen.dart';
import '../models/product.dart' show AppOrder;
import '../services/api_service.dart';
import '../l10n/app_strings.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _filter = 'all';
  List<AppOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final res = await ApiService.getMyOrders();
      if (mounted) {
        final data = res['data'];
        final rows = data is List
            ? data
            : (data is Map && data['rows'] is List ? data['rows'] as List : <dynamic>[]);
        setState(() {
          _orders = rows.map((j) => AppOrder.fromJson(j as Map<String, dynamic>)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AppOrder> get _filtered {
    if (_filter == 'paid')    return _orders.where((o) => o.paymentStatus == 'paid').toList();
    if (_filter == 'notpaid') return _orders.where((o) => o.paymentStatus != 'paid').toList();
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile', showBack: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: _Breadcrumb(parts: const ['My Profile', 'My Orders'].map((e) => e.tr(context)).toList()),
          ),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _FilterTab(label: 'All',      value: 'all',     selected: _filter, onTap: (v) => setState(() => _filter = v)),
              const SizedBox(width: 20),
              _FilterTab(label: 'Paid',     value: 'paid',    selected: _filter, onTap: (v) => setState(() => _filter = v)),
              const SizedBox(width: 20),
              _FilterTab(label: 'Not Paid', value: 'notpaid', selected: _filter, onTap: (v) => setState(() => _filter = v)),
            ]),
          ),
          const SizedBox(height: 16),

          // List or empty state
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filtered.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _AppOrderCard(order: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _AppOrderCard extends StatelessWidget {
  final AppOrder order;
  const _AppOrderCard({required this.order});

  String get _statusLabel {
    switch (order.status) {
      case 'arrived': return 'Arrived';
      case 'shipped': return 'Shipped';
      case 'cancelled': return 'Cancelled';
      default: return 'Processing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = order.paymentStatus == 'paid';
    final dateStr = '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Text('${order.total.toStringAsFixed(3)} KD',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFE6F9F0) : const Color(0xFFFFE9E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (isPaid ? 'Paid' : 'Not Paid').tr(context),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: isPaid ? const Color(0xFF1DB76A) : AppColors.primary),
                ),
              ),
            ]),
          ),
          _DashedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Order Id'.tr(context), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              Text('Order Date'.tr(context), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('#${order.orderNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ]),
          ),
          _DashedDivider(),
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Text('Order Status'.tr(context), style: const TextStyle(fontSize: 12, color: AppColors.textLight))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SizedBox(),
              Text(_statusLabel.tr(context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              width: double.infinity, height: 44,
              decoration: BoxDecoration(color: const Color(0xFFFFE9E3), borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text('View'.tr(context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/icons/no_order.svg', width: 100, height: 100),
        const SizedBox(height: 16),
        Text('You Have Not Any Order'.tr(context),
            style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// ── Filter tab ────────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _FilterTab({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? null : [const BoxShadow(color: Color(0x0D000000), blurRadius: 4)],
        ),
        child: Text(label.tr(context),
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textMedium,
            )),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(double.infinity, 1),
    painter: _DashedLinePainter(),
  );
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 11;
    }
  }
  @override bool shouldRepaint(_) => false;
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
