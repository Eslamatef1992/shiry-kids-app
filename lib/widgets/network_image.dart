import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders [url] with the right loader:
///  - empty            -> [placeholder]
///  - *.svg (http or asset) -> SvgPicture (network/asset), falls back to
///    [placeholder] while loading or on error
///  - http(s) URL      -> Image.network (falls back to [placeholder] on error)
///  - anything else    -> Image.asset (bundled asset path, falls back to [placeholder])
///
/// Use this anywhere an image can come either from the backend (full URL,
/// e.g. vendor logos, coupon images, product images) or from a bundled
/// local asset (design placeholders).
///
/// IMPORTANT: SVGs must NOT be passed to [Image.network]/[Image.asset] —
/// Flutter's raster image codecs cannot decode vector SVG data, which can
/// cause the image pipeline to spin indefinitely (UI freeze / FPS drop /
/// climbing memory) instead of failing cleanly. Always route `.svg` URLs
/// through [SvgPicture].
Widget smartImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
}) {
  final fallback = placeholder ??
      Container(
        width: width,
        height: height,
        color: const Color(0xFFF0F0F0),
        child: const Icon(Icons.image_outlined, color: Color(0xFFCCCCCC)),
      );

  if (url.isEmpty) return fallback;

  final isSvg = url.toLowerCase().split('?').first.endsWith('.svg');

  if (url.startsWith('http')) {
    if (isSvg) {
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => fallback,
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      // Bound the decoded bitmap size to roughly the rendered size (x2 for
      // pixel density) so a very large source image can't force a slow,
      // full-resolution decode on the main thread — this can otherwise read
      // as a UI "freeze" for a second or more when the screen first opens.
      cacheWidth: width != null ? (width * 2).round() : null,
      cacheHeight: height != null ? (height * 2).round() : null,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  if (isSvg) {
    return SvgPicture.asset(
      url,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (_) => fallback,
    );
  }

  return Image.asset(
    url,
    width: width,
    height: height,
    fit: fit,
    cacheWidth: width != null ? (width * 2).round() : null,
    cacheHeight: height != null ? (height * 2).round() : null,
    errorBuilder: (_, __, ___) => fallback,
  );
}
