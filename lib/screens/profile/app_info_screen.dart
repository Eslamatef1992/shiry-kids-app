import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';
import '../../services/api_service.dart';

/// Generic CMS-backed page (About Us, Privacy Policy, Terms & Conditions).
/// Fetches `/cms/:slug` and renders the bilingual HTML content set by the
/// admin (rich text editor), choosing the Arabic or English copy based on
/// the device locale.
class AppInfoScreen extends StatefulWidget {
  final String title;
  final String slug;
  const AppInfoScreen({super.key, required this.title, required this.slug});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  bool _loading = true;
  bool _error = false;
  String _title = '';
  String _html = '';

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getCmsPage(widget.slug);
      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) {
        if (mounted) setState(() { _loading = false; _error = true; });
        return;
      }
      final isAr = mounted && Localizations.localeOf(context).languageCode == 'ar';

      String pick(String enKey, String arKey, String fallback) {
        final ar = data[arKey]?.toString() ?? '';
        final en = data[enKey]?.toString() ?? '';
        if (isAr && ar.isNotEmpty) return ar;
        return en.isNotEmpty ? en : fallback;
      }

      if (!mounted) return;
      setState(() {
        _title = pick('title', 'title_ar', widget.title);
        _html = pick('content', 'content_ar', '');
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBreadcrumb(section: _title),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error || _html.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Content for this page hasn\'t been added yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Html(
          data: _html,
          style: {
            'body': Style(fontSize: FontSize(13), color: AppColors.textDark),
            'p': Style(fontSize: FontSize(13), color: AppColors.textDark),
            'li': Style(fontSize: FontSize(13), color: AppColors.textDark),
            'h1': Style(fontSize: FontSize(20), fontWeight: FontWeight.w800, color: AppColors.textDark),
            'h2': Style(fontSize: FontSize(17), fontWeight: FontWeight.w700, color: AppColors.textDark),
            'h3': Style(fontSize: FontSize(15), fontWeight: FontWeight.w700, color: AppColors.textDark),
            'a': Style(color: AppColors.primary),
          },
        ),
      ],
    );
  }
}
