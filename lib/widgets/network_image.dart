import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// Renders [url] with the right loader:
///  - empty            -> [placeholder]
///  - *.svg (http)     -> fetches the bytes once, sniffs whether they're
///    really an SVG document, and renders with [SvgPicture.string] or
///    [Image.memory] accordingly (see [_RemoteVectorImage])
///  - *.svg (asset)    -> SvgPicture.asset, falls back to [placeholder] on error
///  - http(s) URL      -> Image.network (falls back to [placeholder] on error)
///  - anything else    -> Image.asset (bundled asset path, falls back to [placeholder])
///
/// Use this anywhere an image can come either from the backend (full URL,
/// e.g. vendor logos, coupon images, product images) or from a bundled
/// local asset (design placeholders).
///
/// IMPORTANT: Don't pass admin-uploaded URLs that merely *end* in `.svg`
/// straight to [SvgPicture.network]. If the uploaded file isn't actually a
/// valid SVG document (e.g. a JPEG/PNG saved with a `.svg` filename),
/// flutter_svg's XML parser can hang the UI thread indefinitely on the very
/// first frame — which shows up as a completely blank/frozen screen (this is
/// exactly what caused the checkout screen to freeze whenever a coupon with
/// such an image was in the cart). [_RemoteVectorImage] fetches the bytes,
/// sniffs the content, and only uses [SvgPicture] for content that actually
/// looks like SVG/XML.
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
      return _RemoteVectorImage(
        url: url,
        width: width,
        height: height,
        fit: fit,
        fallback: fallback,
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

/// Cache of in-flight/completed byte fetches for [_RemoteVectorImage], keyed
/// by URL, so the same coupon/product/brand image isn't re-downloaded every
/// time its widget rebuilds.
final Map<String, Future<Uint8List?>> _remoteImageBytesCache = {};

/// Fetches [url] once (cached), then renders the bytes as an SVG via
/// [SvgPicture.string] if they actually look like an SVG document, or as a
/// raster image via [Image.memory] otherwise. Shows [fallback] while
/// loading, on a failed/timed-out request, or if the bytes can't be decoded
/// as either.
class _RemoteVectorImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget fallback;

  const _RemoteVectorImage({
    required this.url,
    this.width,
    this.height,
    required this.fit,
    required this.fallback,
  });

  @override
  State<_RemoteVectorImage> createState() => _RemoteVectorImageState();
}

class _RemoteVectorImageState extends State<_RemoteVectorImage> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _remoteImageBytesCache.putIfAbsent(widget.url, () => _fetch(widget.url));
  }

  static Future<Uint8List?> _fetch(String url) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) return res.bodyBytes;
    } catch (_) {
      // Network error / timeout — fall through to fallback below.
    }
    return null;
  }

  /// Looks at the first chunk of [bytes] for the opening of an SVG/XML
  /// document. Admin-uploaded "coupon image" files sometimes end in `.svg`
  /// even when the actual content is a JPEG/PNG, so we can't trust the
  /// extension alone.
  static bool _looksLikeSvg(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    final len = bytes.length < 256 ? bytes.length : 256;
    final head = utf8.decode(bytes.sublist(0, len), allowMalformed: true).toLowerCase();
    return head.contains('<svg') || head.contains('<?xml');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.fallback;
        }
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) return widget.fallback;

        if (_looksLikeSvg(bytes)) {
          try {
            return SvgPicture.string(
              utf8.decode(bytes, allowMalformed: true),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              placeholderBuilder: (_) => widget.fallback,
            );
          } catch (_) {
            return widget.fallback;
          }
        }

        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          cacheWidth: widget.width != null ? (widget.width! * 2).round() : null,
          cacheHeight: widget.height != null ? (widget.height! * 2).round() : null,
          errorBuilder: (_, __, ___) => widget.fallback,
        );
      },
    );
  }
}
