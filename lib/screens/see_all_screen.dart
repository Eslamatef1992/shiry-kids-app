import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import '../l10n/app_strings.dart';

/// Generic vertical list screen used by Home's "See All" links — the caller
/// builds the item widgets (already wired to the right onTap/onAddToCart
/// callbacks) so this screen just lays them out one under another.
class SeeAllScreen extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const SeeAllScreen({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: title, showBack: true),
      body: items.isEmpty
          ? Center(child: Text('No items found'.tr(context),
              style: const TextStyle(color: AppColors.textMedium)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => items[i],
            ),
    );
  }
}