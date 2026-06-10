import 'package:flutter/material.dart';

/// Renders [url] with the right loader:
///  - empty            -> [placeholder]
///  - http(s) URL      -> Image.network (falls back to [placeholder] on error)
///  - anything else    -> Image.asset (bundled asset path, falls back to [placeholder])
///
/// Use this anywhere an image can come either from the backend (full URL,
/// e.g. vendor logos, coupon images, product images) or from a bundled
/// local asset (design placeholders).
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

  if (url.startsWith('http')) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  return Image.asset(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => fallback,
  );
}
