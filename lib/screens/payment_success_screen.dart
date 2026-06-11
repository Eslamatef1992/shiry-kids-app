import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/network_image.dart';
import '../l10n/app_strings.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderId;
  final double subtotal;
  final double discount;
  final double shippingFees;
  final double deliveryFees;

  /// Real per-unit QR code images uploaded by the admin for any purchased
  /// coupons (full URLs). When non-empty, these are shown instead of the
  /// generated order QR code.
  final List<String> couponQrImages;

  /// Whether this order included any coupons. The QR section is only shown
  /// for coupon purchases — product-only orders don't get a QR code.
  final bool hasCoupons;

  const PaymentSuccessScreen({
    super.key,
    this.orderId = '#12345',
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.shippingFees = 0.0,
    this.deliveryFees = 1.5,
    this.couponQrImages = const [],
    this.hasCoupons = false,
  });

  double get _total => subtotal - discount + shippingFees + deliveryFees;

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

              // ── Receipt card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Green badge icon
                    SvgPicture.asset(
                      'assets/icons/success_badge.svg',
                      width: 86,
                      height: 83,
                    ),
                    const SizedBox(height: 20),

                    // Heading
                    Text(
                      'Successful Payment'.tr(context),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF34C759),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'Order'.tr(context)} $orderId ${'has been placed'.tr(context)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Dashed divider
                    _DashedDivider(),
                    const SizedBox(height: 28),

                    // QR code(s) — show real uploaded coupon QR codes if any
                    // were assigned, otherwise the generated order QR.
                    if (couponQrImages.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            (couponQrImages.length > 1
                                    ? 'Your Coupon QR Codes'
                                    : 'Your Coupon QR Code')
                                .tr(context),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: couponQrImages.map((url) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: smartImage(url, width: 130, height: 130, fit: BoxFit.contain),
                            )).toList(),
                          ),
                        ],
                      )
                    else if (hasCoupons)
                      QrImageView(
                        data: 'SHIRY-ORDER-$orderId',
                        version: QrVersions.auto,
                        size: 130,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF000508),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF000508),
                        ),
                      ),
                    if (couponQrImages.isNotEmpty || hasCoupons)
                      const SizedBox(height: 8),
                    Text(
                      orderId,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Dashed divider
                    _DashedDivider(),
                    const SizedBox(height: 20),

                    // Order totals
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _TotalRow('Subtotal'.tr(context),
                              '${subtotal.toStringAsFixed(2)} KD'),
                          const SizedBox(height: 10),
                          _TotalRow('Discount'.tr(context),
                              '-${discount.toStringAsFixed(2)} KD',
                              valueColor: AppColors.primary),
                          const SizedBox(height: 10),
                          _TotalRow('Shipping Fees'.tr(context),
                              '${shippingFees.toStringAsFixed(2)} KD'),
                          const SizedBox(height: 10),
                          _TotalRow('Delivery Fees'.tr(context),
                              '${deliveryFees.toStringAsFixed(2)} KD'),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total'.tr(context),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark)),
                              Text('${_total.toStringAsFixed(2)} KD',
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
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Back To Home'.tr(context),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 12),

              // View Order
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('View Order'.tr(context),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
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

// ── Dashed divider ─────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomPaint(
        size: const Size(double.infinity, 2),
        painter: _DashedPainter(),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0, gap = 5.0;
    final paint = Paint()
      ..color = const Color(0xFFFFF5F2)
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => false;
}

// ── Row helper ─────────────────────────────────────────────────────────────────

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
            style: const TextStyle(
                fontSize: 13, color: AppColors.textMedium)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }
}
