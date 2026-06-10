import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String? message;
  const PaymentFailedScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ── X close ─────────────────────────────────────────────
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: AppColors.primary, size: 26),
              ),
            ),

            // ── Card ─────────────────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 24,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon: money bag + X badge
                      _FailedIcon(),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Failed Payment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        (message != null && message!.trim().isNotEmpty)
                            ? message!
                            : 'The Available Balance Is Less Than The Order Total.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Money bag + X badge icon ───────────────────────────────────────────────────

class _FailedIcon extends StatelessWidget {
  const _FailedIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          // Money bag body
          Positioned.fill(
            child: CustomPaint(painter: _MoneyBagPainter()),
          ),
          // X badge (bottom-right)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // ── Bag body (rounded rectangle, lower 65%) ──────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.30, w * 0.84, h * 0.62),
      Radius.circular(w * 0.26),
    );
    canvas.drawRRect(bodyRect, paint);

    // ── Neck (trapezoid connecting knot to bag) ──────────────────
    final neck = Path()
      ..moveTo(w * 0.34, h * 0.32)
      ..lineTo(w * 0.66, h * 0.32)
      ..lineTo(w * 0.60, h * 0.44)
      ..lineTo(w * 0.40, h * 0.44)
      ..close();
    canvas.drawPath(neck, paint);

    // ── Knot (circle at top) ─────────────────────────────────────
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.22),
      w * 0.17,
      paint,
    );

    // ── Dollar sign (white) ──────────────────────────────────────
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (w - textPainter.width) / 2,
        h * 0.47 + (h * 0.34 - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_MoneyBagPainter old) => false;
}
