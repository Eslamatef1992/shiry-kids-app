import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'admin_scan_screen.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum QrStatus { valid, used, redeemed, notFound }

QrStatus qrStatusFromString(String? s) {
  switch (s) {
    case 'valid': return QrStatus.valid;
    case 'used': return QrStatus.used;
    case 'redeemed': return QrStatus.redeemed;
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
        scannedAt: DateTime.tryParse((j['createdAt'] ?? j['created_at'])?.toString() ?? '')
                ?.toLocal() ??
            DateTime.now(),
        status: qrStatusFromString(j['status']?.toString()),
      );

  ScannedQr copyWith({QrStatus? status}) =>
      ScannedQr(code: code, scannedAt: scannedAt, status: status ?? this.status);
}

/// Extracts the QR code string from a redemption record — tolerant of the
/// code being at the top level or nested under `qr` / `qr_code`.
String? _redemptionCode(Map<String, dynamic> r) {
  final direct = r['qr_code'] ?? r['code'];
  if (direct is String) return direct;
  if (direct is Map) return direct['qr_code']?.toString() ?? direct['code']?.toString();
  final qr = r['qr'];
  if (qr is Map) return qr['qr_code']?.toString() ?? qr['code']?.toString();
  return null;
}

List<Map<String, dynamic>> _listFrom(Map<String, dynamic> res, List<String> keys) {
  for (final k in keys) {
    final v = res[k];
    if (v is List) return v.whereType<Map<String, dynamic>>().toList();
    if (v is Map && v['data'] is List) {
      return (v['data'] as List).whereType<Map<String, dynamic>>().toList();
    }
  }
  return [];
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
  final Set<String> _redeeming = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getQRHistory(),
        ApiService.getQRRedemptions().catchError((_) => <String, dynamic>{}),
      ]);
      final historyRes = results[0];
      final redemptionsRes = results[1];

      if (historyRes['success'] == true) {
        var rows = (historyRes['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ScannedQr.fromJson)
            .toList();

        // Codes that were redeemed move from "Used" to "Redeemed".
        final redemptions = _listFrom(redemptionsRes, ['data', 'redemptions']);
        final redeemedCodes = <String>{};
        for (final r in redemptions) {
          final code = _redemptionCode(r);
          if (code == null || code.isEmpty) continue;
          redeemedCodes.add(code);
          // Redeemed codes that are missing from scan history still get a card.
          if (!rows.any((q) => q.code == code)) {
            rows.add(ScannedQr(
              code: code,
              scannedAt: DateTime.tryParse(r['redeemed_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
              status: QrStatus.redeemed,
            ));
          }
        }
        rows = rows
            .map((q) => redeemedCodes.contains(q.code) && q.status == QrStatus.used
                ? q.copyWith(status: QrStatus.redeemed)
                : q)
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
    if (_filter == 'redeemed') return _history.where((q) => q.status == QrStatus.redeemed).toList();
    if (_filter == 'valid')    return _history.where((q) => q.status == QrStatus.valid).toList();
    if (_filter == 'notFound') return _history.where((q) => q.status == QrStatus.notFound).toList();
    return _history;
  }

  void _onScanResult(ScannedQr result) {
    setState(() => _history.insert(0, result));
  }

  Future<void> _redeem(ScannedQr item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redeem QR Code'),
        content: const Text('Are you sure you want to redeem this QR code?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Redeem',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _redeeming.add(item.code));
    String message;
    try {
      final res = await ApiService.redeemQR(item.code);
      final ok = res['success'] == true;
      message = res['message']?.toString() ??
          (ok ? 'QR code redeemed successfully' : 'Failed to redeem QR code');
      // "already_redeemed" (409) means the local list is stale — move it anyway.
      if ((ok || res['status'] == 'already_redeemed') && mounted) {
        setState(() {
          _history = _history
              .map((q) => q.code == item.code && q.status == QrStatus.used
                  ? q.copyWith(status: QrStatus.redeemed)
                  : q)
              .toList();
        });
      }
    } catch (_) {
      message = 'Failed to redeem QR code';
    }
    if (!mounted) return;
    setState(() => _redeeming.remove(item.code));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(children: [
                _Tab(label: 'All',       value: 'all',      selected: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 12),
                _Tab(label: 'Used',      value: 'used',     selected: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 12),
                _Tab(label: 'Redeemed',  value: 'redeemed', selected: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 12),
                _Tab(label: 'Valid',     value: 'valid',    selected: _filter, onTap: (v) => setState(() => _filter = v)),
                const SizedBox(width: 12),
                _Tab(label: 'Not Found', value: 'notFound', selected: _filter, onTap: (v) => setState(() => _filter = v)),
              ]),
            ),
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
                      mainAxisSpacing: 12, childAspectRatio: 0.72,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      return _QrCard(
                        item: item,
                        redeeming: _redeeming.contains(item.code),
                        onRedeem: item.status == QrStatus.used ? () => _redeem(item) : null,
                      );
                    },
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
  final bool redeeming;
  final VoidCallback? onRedeem;
  const _QrCard({required this.item, this.redeeming = false, this.onRedeem});

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
          if (onRedeem != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: redeeming ? null : onRedeem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: redeeming
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Redeem',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
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
      case QrStatus.redeemed:
        label = 'Redeemed'; color = const Color(0xFF2F6FED); bg = const Color(0xFFE6EEFD);
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
