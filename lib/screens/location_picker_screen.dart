import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LocationPickerScreen extends StatelessWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // ── Map placeholder ───────────────────────────────────
        Container(
          color: const Color(0xFFE8EAD3), // map sand color
          child: CustomPaint(
            painter: _MapPainter(),
            size: Size.infinite,
          ),
        ),

        // ── Search bar ────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16, right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search Your Address',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Color(0xFFAAAAAA), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // ── Center pin ────────────────────────────────────────
        const Center(
          child: Icon(Icons.location_on, color: AppColors.primary, size: 40),
        ),

        // ── Bottom sheet ──────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                'Allow Access To The Site For More\nAccurate Delivery.',
                style: TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    'city': 'Kuwait',
                    'detail': 'Kuwait City ,Kuwait',
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEDED),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 9, height: 9,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                          child: const Icon(Icons.add, size: 7, color: Colors.white),
                        ),
                      ),
                    ]),
                    const SizedBox(width: 8),
                    const Text('Set Your Location',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// Simple painted map background (rivers + roads suggestion)
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final water = Paint()..color = const Color(0xFF9FC5D8);
    final road = Paint()..color = const Color(0xFFFFFFFF)..strokeWidth = 3..style = PaintingStyle.stroke;
    final roadMinor = Paint()..color = const Color(0xFFFFCC66)..strokeWidth = 2..style = PaintingStyle.stroke;

    // Water body (Gulf)
    final waterPath = Path()
      ..moveTo(size.width * 0.6, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.6, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.2, size.width * 0.6, 0)
      ..close();
    canvas.drawPath(waterPath, water);

    // Main roads
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width * 0.55, size.height * 0.45), road);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width * 0.5, size.height * 0.65), roadMinor);
    canvas.drawLine(Offset(size.width * 0.15, 0), Offset(size.width * 0.15, size.height), roadMinor);
  }

  @override
  bool shouldRepaint(_) => false;
}
