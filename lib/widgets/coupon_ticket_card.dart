import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';
import 'network_image.dart';

/// Ticket-style coupon card matching Figma design.
/// Left: product image. Middle: brand + title + countdown + pink price area.
/// Right stub: discount badge + coupon count. Dashed edges + semicircle notches.
class CouponTicketCard extends StatelessWidget {
  final String imageUrl;
  final String brandImageUrl;
  final String brandName;
  final String title;
  final String countdown;
  final String price;
  final String originalPrice;
  final String discount;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isOutOfStock;

  static const double _cardH  = 172.0;
  static const double _imgW   = 118.0;
  static const double _stubW  = 72.0;
  static const double _notchR = 10.0;

  const CouponTicketCard({
    super.key,
    required this.imageUrl,
    required this.brandImageUrl,
    required this.brandName,
    required this.title,
    required this.countdown,
    required this.price,
    required this.originalPrice,
    required this.discount,
    this.onTap,
    this.onAddToCart,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: _cardH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Ticket shape background + dashed lines ──────────
            Positioned.fill(
              child: ClipPath(
                clipper: const _TicketClipper(stubW: _stubW, notchR: _notchR),
                child: CustomPaint(
                  painter: const _TicketPainter(stubW: _stubW, notchR: _notchR),
                ),
              ),
            ),

            // ── Content row ─────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left image
                SizedBox(
                  width: _imgW,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 0, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: smartImage(
                        imageUrl,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: const Color(0xFFF0F0F0),
                          child: const Icon(Icons.image_outlined,
                              color: Color(0xFFCCCCCC), size: 32),
                        ),
                      ),
                    ),
                  ),
                ),

                // Middle content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand name
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 10, 10, 0),
                        child: Text(brandName,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800,
                                color: Color(0xFFE73C00))),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 4, 10, 0),
                        child: Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: AppColors.textDark, height: 1.35)),
                      ),
                      // Countdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 4, 10, 0),
                        child: Text(countdown,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textLight)),
                      ),
                      const Spacer(),
                      // Pink bottom — Add To Cart button (or Out of Stock)
                      GestureDetector(
                        onTap: isOutOfStock ? null : onAddToCart,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? const Color(0xFFEEEEEE)
                                : const Color(0xFFFFE9E3),
                          ),
                          child: Center(
                            child: Text(
                              isOutOfStock
                                  ? 'Out of Stock'.tr(context)
                                  : 'Add To Cart'.tr(context),
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: isOutOfStock
                                      ? AppColors.textLight
                                      : AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right stub
                SizedBox(
                  width: _stubW,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Discount badge
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCFD0).withOpacity(0.35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(discount,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(height: 10),
                      // Price
                      Text(price,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.2)),
                      const SizedBox(height: 2),
                      // Original price
                      Text(originalPrice,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textLight,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textLight)),
                    ],
                  ),
                ),
              ],
            ),

            // ── Brand logo circle (overlaps image/content boundary) ──
            Positioned(
              top: 8,
              left: _imgW - _notchR - 8,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x20000000), blurRadius: 4)
                  ],
                ),
                child: ClipOval(
                  child: smartImage(
                    brandImageUrl,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.storefront_outlined,
                          size: 16, color: AppColors.primary),
                    ),
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

// ── Ticket shape: rounded outer corners + semicircle notches at stub divider ──
class _TicketClipper extends CustomClipper<Path> {
  final double stubW, notchR;
  static const double _cornerR = 14.0;
  const _TicketClipper({required this.stubW, required this.notchR});

  @override
  Path getClip(Size size) {
    const r = _cornerR;
    final divX = size.width - stubW;
    return Path()
      // Start at top-left after corner
      ..moveTo(r, 0)
      // Top edge → notch
      ..lineTo(divX - notchR, 0)
      // Top notch (bites INTO card)
      ..arcToPoint(Offset(divX + notchR, 0),
          radius: Radius.circular(notchR), clockwise: false)
      // Top edge → top-right corner
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r),
          radius: const Radius.circular(_cornerR))
      // Right edge → bottom-right corner
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height),
          radius: const Radius.circular(_cornerR))
      // Bottom edge ← notch
      ..lineTo(divX + notchR, size.height)
      // Bottom notch
      ..arcToPoint(Offset(divX - notchR, size.height),
          radius: Radius.circular(notchR), clockwise: false)
      // Bottom edge → bottom-left corner
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r),
          radius: const Radius.circular(_cornerR))
      // Left edge → top-left corner
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),
          radius: const Radius.circular(_cornerR))
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

// ── Ticket painter: #F8F8F8 bg + dashed left, right, divider edges ────────────
class _TicketPainter extends CustomPainter {
  final double stubW, notchR;
  const _TicketPainter({required this.stubW, required this.notchR});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFF8F8F8));

    final divX = size.width - stubW;
    final dashPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLen = 6.0, gap = 5.0;
    _vDash(canvas, 0, size.height, dashPaint, dashLen, gap);
    _vDash(canvas, size.width, size.height, dashPaint, dashLen, gap);

    // Divider — skip notch zones
    double y = 0;
    while (y < size.height) {
      if (y > notchR && y < size.height - notchR) {
        final end = (y + dashLen).clamp(0.0, size.height);
        canvas.drawLine(Offset(divX, y), Offset(divX, end), dashPaint);
      }
      y += dashLen + gap;
    }
  }

  void _vDash(Canvas c, double x, double h, Paint p, double dl, double g,
      {double skip = 14.0}) {
    double y = skip; // skip corner zone
    while (y < h - skip) {
      c.drawLine(Offset(x, y), Offset(x, (y + dl).clamp(0, h - skip)), p);
      y += dl + g;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
