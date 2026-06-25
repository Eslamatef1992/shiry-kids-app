import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';
import 'coupon_detail_screen.dart';
import 'product_detail_screen.dart';

class SearchItem {
  final String type;
  final dynamic data;

  SearchItem({
    required this.type,
    required this.data,
  });
}

class SearchSuggestion {
  final String title;
  final String type;
  final dynamic data;

  SearchSuggestion({
    required this.title,
    required this.type,
    required this.data,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  List<SearchItem> _results = [];
  List<SearchSuggestion> _suggestions = [];
  bool _loading = false;
  bool _searched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {
      if (_searched) { _results = []; _searched = false; }
    });
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetchSuggestions(v.trim()));
  }

  Future<void> _fetchSuggestions(String q) async {
    try {
      final results = await Future.wait([
        ApiService.search(q, limit: 5),
        ApiService.searchCoupons(q, limit: 5),
      ]);

      final suggestions = <SearchSuggestion>[];

      final productsRes = results[0];

      if (productsRes['success'] == true) {
        final data = productsRes['data'];
        final list = data is List ? data : [];

        for (final item in list) {
          final product =
          Product.fromJson(item as Map<String, dynamic>);

          suggestions.add(
            SearchSuggestion(
              title: product.name,
              type: 'product',
              data: product,
            ),
          );
        }
      }

      final couponsRes = results[1];

      if (couponsRes['success'] == true) {
        final data = couponsRes['data'];
        final list = data is List ? data : [];

        for (final item in list) {
          final coupon =
          CouponProduct.fromJson(item as Map<String, dynamic>);

          suggestions.add(
            SearchSuggestion(
              title: coupon.title,
              type: 'coupon',
              data: coupon,
            ),
          );
        }
      }

      if (mounted && _ctrl.text.trim() == q) {
        setState(() {
          _suggestions = suggestions.take(10).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _searched = true;
      _suggestions = [];
    });

    try {
      final responses = await Future.wait([
        ApiService.search(q.trim()),
        ApiService.searchCoupons(q.trim()),
      ]);

      final List<SearchItem> items = [];

      final productsRes = responses[0];

      if (productsRes['success'] == true) {
        final data = productsRes['data'];

        final list = data is List
            ? data
            : (data is Map ? (data['rows'] as List? ?? []) : []);

        items.addAll(
          list.map(
                (e) => SearchItem(
              type: 'product',
              data: Product.fromJson(
                e as Map<String, dynamic>,
              ),
            ),
          ),
        );
      }

      final couponsRes = responses[1];

      if (couponsRes['success'] == true) {
        final data = couponsRes['data'];

        final list = data is List
            ? data
            : (data is Map ? (data['rows'] as List? ?? []) : []);

        items.addAll(
          list.map(
                (e) => SearchItem(
              type: 'coupon',
              data: CouponProduct.fromJson(
                e as Map<String, dynamic>,
              ),
            ),
          ),
        );
      }

      setState(() {
        _results = items;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  void _openSuggestion(SearchSuggestion item) {
    if (item.type == 'product') {
      final product = item.data as Product;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
            categoryName: product.category,
          ),
        ),
      );
    } else {
      final coupon = item.data as CouponProduct;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CouponDetailScreen(
            coupon: coupon,
          ),
        ),
      );
    }
  }

  void _openResult(SearchItem item) {
    if (item.type == 'product') {
      final product = item.data as Product;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
            categoryName: product.category,
          ),
        ),
      );
    } else {
      final coupon = item.data as CouponProduct;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CouponDetailScreen(
            coupon: coupon,
          ),
        ),
      );
    }
  }

  void _selectSuggestion(String label) {
    _ctrl.text = label;
    _search(label);
  }

  void _removeSuggestion(String label) {
    setState(() => _suggestions.remove(label));
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
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...'.tr(context),
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
                          _ctrl.clear();
                          setState(() { _results = []; _searched = false; _suggestions = []; });
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

            // Results / suggestions
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_searched) {
      if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      if (_results.isEmpty) return Center(child: Text('No results found'.tr(context), style: const TextStyle(color: AppColors.textMedium)));
      return _buildResultsGrid();
    }

    if (_suggestions.isNotEmpty) return _buildSuggestions();

    return const SizedBox.shrink();
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final item = _suggestions[index];

        return ListTile(
          onTap: () => _openSuggestion(item),
          leading: Icon(
            item.type == 'product'
                ? Icons.shopping_bag_outlined
                : Icons.local_offer_outlined,
            color: AppColors.primary,
          ),
          title: Text(item.title),
        );
      },
    );
  }

  Widget _buildResultsGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];

        if (item.type == 'product') {
          final p = item.data as Product;

          return ListTile(
            onTap: () => _openResult(item),
            leading: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                p.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(p.name),
            subtitle: const Text('Product'),
            trailing: Text('${p.price} KD'),
          );
        }

        final coupon = item.data as CouponProduct;

        return ListTile(
          onTap: () => _openResult(item),
          leading: const Icon(
            Icons.local_offer,
            color: AppColors.primary,
          ),
          title: Text(coupon.title),
          subtitle: const Text('Coupon'),
          trailing: Text('${coupon.price} KD'),
        );
      },
    );
  }
}
