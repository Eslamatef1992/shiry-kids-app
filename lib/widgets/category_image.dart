import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// Renders a category image that can be:
///  - a normal raster image (.png/.jpg/.webp/...) -> Image.network
///  - a genuine vector .svg -> SvgPicture.network
///  - a Figma-exported ".svg" that's actually just a raster image applied
///    via a <pattern>/<image> fill. flutter_svg's renderer doesn't support
///    SVG <pattern> fills, so those render as a blank/flat shape. For these
///    we extract the embedded base64 image and draw it with Image.memory.
class CategoryImage extends StatelessWidget {
  final String? imageUrl;
  final String? imagePath;
  final String emoji;
  final double size;
  final BoxFit fit;
  final Color placeholderColor;

  const CategoryImage({
    super.key,
    required this.imageUrl,
    this.imagePath,
    this.emoji = '',
    this.size = 44,
    this.fit = BoxFit.cover,
    this.placeholderColor = const Color(0xFFFFDDDD),
  });

  Widget _placeholder() => Container(
        width: size,
        height: size,
        color: placeholderColor,
        child: Center(
          child: Text(emoji.isNotEmpty ? emoji : '🎁',
              style: TextStyle(fontSize: size * 0.5)),
        ),
      );

  static final Map<String, Future<Widget>> _svgCache = {};

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.startsWith('http')) {
      if (url.toLowerCase().endsWith('.svg')) {
        final future = _svgCache.putIfAbsent(url, () => _loadSvgImage(url));
        return FutureBuilder<Widget>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _placeholder();
            }
            return snapshot.data ?? _placeholder();
          },
        );
      }
      return Image.network(
        url,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (imagePath != null) {
      return Image.asset(imagePath!, width: size, height: size, fit: fit);
    }
    return _placeholder();
  }

  Future<Widget> _loadSvgImage(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return _placeholder();
      final text = res.body;

      // Figma-style export: raster image embedded via
      // <image ... xlink:href="data:image/png;base64,..."/> referenced by a
      // <pattern> fill. flutter_svg can't render the pattern, so pull the
      // embedded bitmap out directly.
      final match = RegExp(
        r'<image[^>]*(?:xlink:href|href)="data:image/(?:png|jpe?g|webp);base64,([^"]+)"',
      ).firstMatch(text);
      if (match != null) {
        final bytes = base64Decode(match.group(1)!);
        return Image.memory(bytes, width: size, height: size, fit: fit);
      }

      // Genuine vector SVG - render with flutter_svg.
      return SvgPicture.network(
        url,
        width: size,
        height: size,
        fit: fit,
        placeholderBuilder: (_) => _placeholder(),
      );
    } catch (_) {
      return _placeholder();
    }
  }
}
