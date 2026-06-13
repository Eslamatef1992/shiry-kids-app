import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<Product> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) { setState(() { _results = []; _searched = false; }); return; }
    setState(() { _loading = true; _searched = true; });
    try {
      final res = await ApiService.search(q.trim());
      if (res['success'] == true) {
        final data = res['data'];
        final list = data is List
            ? data
            : (data is Map ? (data['rows'] as List? ?? []) : []);
        setState(() => _results = list.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList());
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('SEARCH'.tr(context),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                onChanged: (v) { if (v.isEmpty) setState(() { _results = []; _searched = false; }); },
                decoration: InputDecoration(
                  hintText: 'Search products...'.tr(context),
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
                          _ctrl.clear(); setState(() { _results = []; _searched = false; });
                        })
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Results
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (!_searched) return const SizedBox.shrink();
    if (_results.isEmpty) return Center(child: Text('No results found'.tr(context), style: const TextStyle(color: AppColors.textMedium)));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: _results.length,
      itemBuilder: (ctx, i) {
        final p = _results[i];
        return GestureDetector(
          onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p, categoryName: p.category))),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: p.imageUrl.startsWith('http')
                    ? Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40))
                    : Image.asset(p.imageUrl, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${p.price.toStringAsFixed(3)} KD',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}
