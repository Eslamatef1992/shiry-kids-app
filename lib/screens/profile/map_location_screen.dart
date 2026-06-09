import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MapLocationScreen extends StatelessWidget {
  const MapLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map placeholder — replace with google_maps_flutter GoogleMap widget
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=29.3759,47.9774&zoom=10&size=400x800&style=feature:water|color:0xadd8e6&key=YOUR_KEY'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: const Color(0xFFD4E6B5)),
          ),

          // Map visual placeholder (stylised grid)
          Positioned.fill(
            child: CustomPaint(painter: _MapPainter()),
          ),

          // Red dot marker
          const Center(
            child: Icon(Icons.circle, color: AppColors.primary, size: 20),
          ),

          // "Order will be delivered" tooltip
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: const Text(
                'The Order Will Be Delivered To This Address.',
                style: TextStyle(fontSize: 13, color: AppColors.textDark),
              ),
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search Your Location',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Address Is 10 Km From Your Current Location.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Kuwait , Kuwait City',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Confirm Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E6B5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final linePaint = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    // Road-like lines
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 4;
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.5, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.35), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.65), roadPaint);
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
}
