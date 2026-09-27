import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import '../l10n/app_strings.dart';

/// Generic vertical list screen used by Home's "See All" links — the caller
/// builds the item widgets (already wired to the right onTap/onAddToCart
/// callbacks) so this screen just lays them out one under another.
///
/// [items] is shown immediately (the preview already loaded on Home); if
/// [loadAll] is given, the full list is fetched and replaces it.
class SeeAllScreen extends StatefulWidget {
  final String title;
  final List<Widget> items;
  final Future<List<Widget>> Function()? loadAll;
  const SeeAllScreen({super.key, required this.title, required this.items, this.loadAll});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  late List<Widget> _items = widget.items;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loader = widget.loadAll;
    if (loader == null) return;
    setState(() => _loading = true);
    try {
      final all = await loader();
      if (mounted) setState(() => _items = all);
    } catch (e) {
      debugPrint('SeeAllScreen._load error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: widget.title, showBack: true),
      body: _items.isEmpty
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Text('No items found'.tr(context),
                      style: const TextStyle(color: AppColors.textMedium)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => i < _items.length
                  ? _items[i]
                  : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
    );
  }
}
