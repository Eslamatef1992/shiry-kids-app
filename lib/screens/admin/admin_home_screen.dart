import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'admin_scan_screen.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum QrStatus { valid, used, notFound }

QrStatus _statusFromString(String? s) {
  switch (s) {
    case 'valid': return QrStatus.valid;
    case 'used': return QrStatus.used;
    default: return QrStatus.notFound;
  }
}

class ScannedQr {
  final String code;
  final DateTime scannedAt;
  final QrStatus status;
  const ScannedQr({required this.code, required this.scannedAt, required this.status});

  factory ScannedQr.fromJson(Map<String, dynamic> j) => ScannedQr(
        code: j['qr_code']?.toString() ?? '',
        scannedAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
        status: _statusFromString(j['status']?.toString()),
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _filter = 'all';
  List<ScannedQr> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getQRHistory();
      if (res['success'] == true) {
        final rows = (res['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ScannedQr.fromJson)
            .toList();
        setState(() => _history = rows);
      }
    } catch (_) {
      // keep existing history on error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ScannedQr> get _filtered {
    if (_filter == 'used')     return _history.where((q) => q.status == QrStatus.used).toList();
    if (_filter == 'valid')    return _history.where((q) => q.status == QrStatus.valid).toList();
    if (_filter == 'notFound') return _history.where((q) => q.status == QrStatus.notFound).toList();
    return _history;
  }

  void _onScanResult(ScannedQr result) {
    setState(() => _history.insert(0, result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('HOME',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(children: [
              _Tab(label: 'All',       value: 'all',      selected: _filter, onTap: (v) => setState(() => _filter = v)),
              const SizedBox(width: 12),
              _Tab(label: 'Used',      value: 'used',     selected: _filter, onTap: (v) => setState(() => _filter = v)),
              const SizedBox(width: 12),
              _Tab(label: 'Valid',     value: 'valid',    selected: _filter, onTap: (v) => setState(() => _filter = v)),
              const SizedBox(width: 12),
              _Tab(label: 'Not Found', value: 'notFound', selected: _filter, onTap: (v) => setState(() => _filter = v)),
            ]),
          ),

          // Grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filtered.isEmpty
                ? const Center(child: Text('No records', style: TextStyle(color: Color(0xFF999999))))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12,
                      mainAxisSpacing: 12, childAspectRatio: 0.85,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _QrCard(item: _filtered[i]),
                  ),
          ),

          // Scan button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AdminScanScreen(onResult: _onScanResult),
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Scan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── QR card ───────────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  final ScannedQr item;
  const _QrCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final d = item.scannedAt;
    final dateStr = '${d.day}/${d.month}/${d.year}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: QrImageView(
              data: item.code,
              version: QrVersions.auto,
              size: double.infinity,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black)),
              _StatusBadge(status: item.status),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final QrStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    Color bg;
    switch (status) {
      case QrStatus.valid:
        label = 'Valid'; color = const Color(0xFF1DB76A); bg = const Color(0xFFE6F9F0);
      case QrStatus.used:
        label = 'Used';  color = AppColors.primary;       bg = const Color(0xFFFFE9E3);
      case QrStatus.notFound:
        label = 'Not Found'; color = const Color(0xFFE8A500); bg = Colors.transparent;
    }
    if (status == QrStatus.notFound) {
      return Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Filter tab ────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _Tab({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF666666),
            )),
      ),
    );
  }
}
