import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'admin_home_screen.dart';

enum _ScanState { idle, scanning, valid, used, notFound }

class AdminScanScreen extends StatefulWidget {
  final void Function(ScannedQr result) onResult;
  const AdminScanScreen({super.key, required this.onResult});
  @override
  State<AdminScanScreen> createState() => _AdminScanScreenState();
}

class _AdminScanScreenState extends State<AdminScanScreen>
    with SingleTickerProviderStateMixin {
  final _controller = MobileScannerController();
  _ScanState _state = _ScanState.idle;
  String? _scannedCode;
  late AnimationController _lineCtrl;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _lineAnim = Tween<double>(begin: 0, end: 1).animate(_lineCtrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_state != _ScanState.idle) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    debugPrint('[QR-SCAN] sending qr_code=[$code]');

    setState(() {
      _scannedCode = code;
      _state = _ScanState.scanning;
    });

    // Call real backend API
    ApiService.scanQR(code).then((res) {
      debugPrint('[QR-SCAN] raw response => $res');
      if (!mounted) return;
      final apiStatus = res['status'] as String? ?? 'not_found';
      _ScanState result;
      QrStatus qrStatus;
      switch (apiStatus) {
        case 'valid':
          result = _ScanState.valid; qrStatus = QrStatus.valid;
          break;
        case 'used':
          result = _ScanState.used; qrStatus = QrStatus.used;
          break;
        default:
          result = _ScanState.notFound; qrStatus = QrStatus.notFound;
          break;
      }
      setState(() => _state = result);
      widget.onResult(ScannedQr(code: code, scannedAt: DateTime.now(), status: qrStatus));
    }).catchError((e) {
      debugPrint('[QR-SCAN] error => $e');
      if (!mounted) return;
      setState(() => _state = _ScanState.notFound);
      widget.onResult(ScannedQr(code: code, scannedAt: DateTime.now(), status: QrStatus.notFound));
    });
  }

  void _reset() => setState(() { _state = _ScanState.idle; _scannedCode = null; });

  String _cameraErrorMessage(MobileScannerErrorCode code) {
    switch (code) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera permission denied.\nPlease allow camera access in your device settings to scan QR codes.';
      case MobileScannerErrorCode.unsupported:
        return 'QR scanning is not supported on this device.';
      default:
        return 'Unable to access the camera.\nPlease make sure no other app is using the camera and try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('SCAN QR CODE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Scan Qr Code To Show Qr Code Status',
                  style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
            ),
          ),
          const Spacer(),

          // Scanner / result area
          Center(
            child: SizedBox(
              width: 220, height: 220,
              child: _buildActiveScanner(),
            ),
          ),
          const SizedBox(height: 24),

          // Status message
          if (_state == _ScanState.valid)     _StatusMsg.valid()
          else if (_state == _ScanState.used) _StatusMsg.used()
          else if (_state == _ScanState.notFound) _StatusMsg.notFound(),

          if (_state != _ScanState.idle && _state != _ScanState.scanning)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextButton(
                onPressed: _reset,
                child: const Text('Scan Again',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),

          const Spacer(),

          // Loading indicator while checking
          if (_state == _ScanState.scanning)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Container(
                width: double.infinity, height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9E3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)),
                ),
              ),
            )
          else
            const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActiveScanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              // Surface camera/permission errors instead of a blank screen,
              // so it's clear why the scanner "isn't working" (e.g. denied
              // camera permission or no camera available on this device).
              return Container(
                color: Colors.black87,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      _cameraErrorMessage(error.errorCode),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
          // Scan line
          if (_state == _ScanState.scanning || _state == _ScanState.idle)
            AnimatedBuilder(
              animation: _lineAnim,
              builder: (_, __) => Positioned(
                top: _lineAnim.value * 210,
                left: 0, right: 0,
                child: Container(height: 2, color: const Color(0xFF00CC44)),
              ),
            ),
          // Corner overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _CornerPainter(
                  color: Colors.black, radius: 12, strokeWidth: 3, cornerLen: 30),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner frame painter ──────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final Color color;
  final double radius, strokeWidth, cornerLen;
  const _CornerPainter({required this.color, required this.radius,
      required this.strokeWidth, required this.cornerLen});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final w = size.width; final h = size.height;
    // Top-left
    canvas.drawPath(Path()
      ..moveTo(0, cornerLen)..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(cornerLen, 0), p);
    // Top-right
    canvas.drawPath(Path()
      ..moveTo(w - cornerLen, 0)..lineTo(w - radius, 0)
      ..arcToPoint(Offset(w, radius), radius: Radius.circular(radius))
      ..lineTo(w, cornerLen), p);
    // Bottom-left
    canvas.drawPath(Path()
      ..moveTo(0, h - cornerLen)..lineTo(0, h - radius)
      ..arcToPoint(Offset(radius, h), radius: Radius.circular(radius))
      ..lineTo(cornerLen, h), p);
    // Bottom-right
    canvas.drawPath(Path()
      ..moveTo(w - cornerLen, h)..lineTo(w - radius, h)
      ..arcToPoint(Offset(w, h - radius), radius: Radius.circular(radius))
      ..lineTo(w, h - cornerLen), p);
  }
  @override bool shouldRepaint(_) => false;
}

// ── Status messages ───────────────────────────────────────────────────────────

class _StatusMsg extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusMsg({required this.icon, required this.label, required this.color});

  factory _StatusMsg.valid() => const _StatusMsg(
      icon: Icons.check, label: 'Valid Qr Code', color: Color(0xFF1DB76A));
  factory _StatusMsg.used() => const _StatusMsg(
      icon: Icons.close, label: 'Qr Code Already Used', color: Color(0xFFFF3B30));
  factory _StatusMsg.notFound() => const _StatusMsg(
      icon: Icons.block, label: 'Not Found', color: Color(0xFFE8A500));

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ],
  );
}
