import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/wavy_app_bar.dart';
import '../widgets/category_image.dart';
import '../widgets/skeleton_loader.dart';
import 'product_detail_screen.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedCat = 0;
  final _searchCtrl = TextEditingController();
  List<ProductCategory> _categories = [
    const ProductCategory(id: 'all', name: 'All Categories', emoji: '🎉'),
  ];
  List<Product> _allProducts = [];
  bool _loading = true;
  bool _error = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(() => setState(() {}));
  }

  Future<void> _loadData() async {
    if (mounted) setState(() { _loading = true; _error = false; _errorMsg = null; });
    try {
      final catRes = await ApiService.getCategories();
      final prodRes = await ApiService.getProducts();
      if (mounted) {
        setState(() {
          final cats = ((catRes['data'] as List?) ?? [])
              .map((j) => ProductCategory.fromJson(j as Map<String, dynamic>))
              .toList();
          _categories = [const ProductCategory(id: 'all', name: 'All', emoji: '🎉'), ...cats];
          final prodData = prodRes['data'];
          final rows = prodData is Map ? (prodData['rows'] as List? ?? []) : (prodData as List? ?? []);
          _allProducts = rows.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('ProductsScreen._loadData error: $e');
      if (mounted) setState(() { _loading = false; _error = true; _errorMsg = e.toString(); });
    }
  }

  List<Product> get _filtered {
    final cat = _categories[_selectedCat];
    var list = cat.id == 'all'
        ? _allProducts
        : _allProducts.where((p) => p.categoryId == cat.id).toList();
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Products'.tr(context), showBack: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Categories ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              '${'All Categories'.tr(context)}(${_allProducts.length})',
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCat == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCat = i),
                  child: Column(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: ClipOval(
                          child: (cat.imageUrl != null && cat.imageUrl!.startsWith('http')) || cat.imagePath != null
                              ? CategoryImage(
                                  imageUrl: cat.imageUrl,
                                  imagePath: cat.imagePath,
                                  emoji: cat.emoji,
                                  size: 52,
                                  placeholderColor: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.white,
                                )
                              : Container(
                                  color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.white,
                                  child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 22))),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.name.split(' ').first,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppColors.primary : AppColors.textMedium,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // ── Search ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search'.tr(context),
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          // ── Grid ─────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const ProductGridSkeleton()
                : _error
                ? LoadErrorView(onRetry: _loadData, detail: _errorMsg)
                : _filtered.isEmpty
                ? Center(child: Text('No products found'.tr(context), style: const TextStyle(color: AppColors.textMedium)))
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _ProductCard(
                product: _filtered[i],
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: _filtered[i], categoryName: _categories[_selectedCat].name),
                )),
                onAddToCart: () {
                  context.read<CartProvider>().addProduct(CartItem(product: _filtered[i]));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${_filtered[i].name} ${'added to cart!'.tr(context)}'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 2),
                  ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  const _ProductCard({required this.product, required this.onTap, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final catLabel = (product.category.isNotEmpty ? product.category : 'Product').tr(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: product.imageUrl.isNotEmpty
                        ? (product.imageUrl.startsWith('http')
                            ? Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF0F0F0), child: const Center(child: Text('🎁', style: TextStyle(fontSize: 48)))))
                            : Image.asset(product.imageUrl, width: double.infinity, fit: BoxFit.cover))
                        : Container(
                            color: const Color(0xFFF0F0F0),
                            child: const Center(child: Text('🎁', style: TextStyle(fontSize: 48))),
                          ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(catLabel,
                          style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('${product.price.toInt()} Kwd',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      const SizedBox(width: 6),
                      Text('${product.originalPrice.toInt()} Kwd',
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight,
                              fontWeight: FontWeight.w500
                              )),
                      const SizedBox(width: 4),
                      if (product.discountPercent > 0)
                        Text('-${product.discountPercent} %',
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Add To Cart button
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE9E3),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Add To Cart'.tr(context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
