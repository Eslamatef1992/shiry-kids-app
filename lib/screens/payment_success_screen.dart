import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final double subtotal;
  final double discount;
  final double shippingFees;
  final double deliveryFees;
  final List<String> qrImageUrls; // actual QR image paths from backend

  const PaymentSuccessScreen({
    super.key,
    this.orderNumber = '',
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.shippingFees = 0.0,
    this.deliveryFees = 0.0,
    this.qrImageUrls = const [],
  });

  double get total => subtotal - discount + shippingFees + deliveryFees;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Receipt Card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Badge icon
                    SvgPicture.asset(
                      'assets/icons/success_badge.svg',
                      width: 86,
                      height: 83,
                    ),
                    const SizedBox(height: 20),

                    // "Successful Payment" heading
                    const Text(
                      'تم الدفع بنجاح',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF34C759),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الطلب $orderNumber تم تقديمه',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Dashed divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomPaint(
                        size: const Size(double.infinity, 2),
                        painter: _DashedLinePainter(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── QR Code Images ────────────────────────────────────
                    if (qrImageUrls.isNotEmpty) ...[
                      const Text(
                        'كود QR الخاص بك',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...qrImageUrls.map((url) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Image.network(
                          ApiService.absoluteImageUrl(url),
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              width: 180,
                              height: 180,
                              child: Center(child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              )),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.qr_code_2,
                            size: 100,
                            color: AppColors.textMedium,
                          ),
                        ),
                      )),
                      const SizedBox(height: 8),
                    ] else ...[
                      // No QR codes (product order or online payment pending)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'سيتم إرسال كود QR الخاص بك عبر البريد الإلكتروني بعد تأكيد الدفع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Dashed divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomPaint(
                        size: const Size(double.infinity, 2),
                        painter: _DashedLinePainter(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Order totals
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _TotalRow('المجموع الفرعي', '${subtotal.toStringAsFixed(2)} KD'),
                          const SizedBox(height: 10),
                          _TotalRow('الخصم', '-${discount.toStringAsFixed(2)} KD',
                              valueColor: AppColors.primary),
                          const SizedBox(height: 10),
                          _TotalRow('رسوم الشحن', '${shippingFees.toStringAsFixed(2)} KD'),
                          const SizedBox(height: 10),
                          _TotalRow('رسوم التوصيل', '${deliveryFees.toStringAsFixed(2)} KD'),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الإجمالي',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark)),
                              Text('${total.toStringAsFixed(2)} KD',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Back to Home
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('العودة للرئيسية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 12),

              // View Order
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('عرض الطلب',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Dashed line painter
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0;
    const gap = 5.0;
    final paint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}

// Total row helper
class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TotalRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }
}
