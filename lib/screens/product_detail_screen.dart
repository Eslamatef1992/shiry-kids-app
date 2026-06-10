import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/wavy_app_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String categoryName;
  const ProductDetailScreen({super.key, required this.product, required this.categoryName});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  int _imageIndex = 0;

  static const _colorMap = {
    'White': Color(0xFFFFFFFF),
    'Black': Color(0xFF222222),
    'Red':   Color(0xFFE53935),
    'Blue':  Color(0xFF1E88E5),
    'Green': Color(0xFF43A047),
  };

  @override
  void initState() {
    super.initState();
    // Pre-select first option if variants exist
    if (widget.product.sizes?.isNotEmpty == true) {
      _selectedSize = widget.product.sizes!.first;
    }
    if (widget.product.colors?.isNotEmpty == true) {
      _selectedColor = widget.product.colors!.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasSizes  = product.sizes?.isNotEmpty == true;
    final hasColors = product.colors?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Products', showBack: true),
      body: Column(
        children: [
          // ── Scrollable content ────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _Breadcrumb(
                      parts: ['Products', widget.categoryName, product.name],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Full-width product image (with thumbnail gallery if multiple)
                  Builder(builder: (context) {
                    final gallery = product.images.isNotEmpty ? product.images : [product.imageUrl];
                    final current = (_imageIndex < gallery.length ? gallery[_imageIndex] : '');
                    return Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: current.startsWith('http')
                              ? Image.network(current, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (_, __, ___) => Image.asset('assets/images/product_detail.jpg', fit: BoxFit.cover, width: double.infinity))
                              : Image.asset(current.isNotEmpty ? current : 'assets/images/product_detail.jpg', fit: BoxFit.cover, width: double.infinity),
                        ),
                        if (gallery.length > 1) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 56,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: gallery.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final selected = i == _imageIndex;
                                return GestureDetector(
                                  onTap: () => setState(() => _imageIndex = i),
                                  child: Container(
                                    width: 56, height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: gallery[i].startsWith('http')
                                          ? Image.network(gallery[i], fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF5F5F5)))
                                          : Image.asset(gallery[i], fit: BoxFit.cover),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          product.description.isEmpty
                              ? 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit, Sed Do Eiusmod Tempor Incididunt Ut Labore Et Dolore Magna Aliqua. Ut Enim Ad Minim Veniam, Quis Nostrud Exercitation Ullamco Laboris Nisi Ut Aliquip Ex Ea Commodo Consequat.'
                              : product.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Price (reflects selected variant if it has its own price)
                        Builder(builder: (context) {
                          final variant = product.variantFor(size: _selectedSize, color: _selectedColor);
                          final price = variant?.price ?? product.price;
                          return Row(
                            children: [
                              Text(
                                '${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 3)} Kwd',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (variant != null && variant.stock == 0) ...[
                                const SizedBox(width: 10),
                                const Text('Out of stock',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                              ],
                            ],
                          );
                        }),
                        const SizedBox(height: 16),

                        // ── Size selector ─────────────────────────────────
                        if (hasSizes) ...[
                          const Text('Size',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: product.sizes!.map((s) {
                              final selected = _selectedSize == s;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedSize = s),
                                child: Container(
                                  width: 48, height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected ? AppColors.primary : AppColors.divider,
                                      width: selected ? 2 : 1,
                                    ),
                                    color: selected ? AppColors.primary.withOpacity(0.06) : AppColors.white,
                                  ),
                                  child: Center(
                                    child: Text(s,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: selected ? AppColors.primary : AppColors.textMedium,
                                        )),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Color selector ────────────────────────────────
                        if (hasColors) ...[
                          const Text('Color',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            children: product.colors!.map((c) {
                              final selected = _selectedColor == c;
                              final fill = _colorMap[c] ?? Colors.grey;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = c),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: fill,
                                        border: Border.all(
                                          color: selected ? AppColors.primary : const Color(0xFFDDDDDD),
                                          width: selected ? 2.5 : 1,
                                        ),
                                        boxShadow: selected
                                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(c,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: selected ? AppColors.primary : AppColors.textMedium,
                                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                        )),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Add To Cart — pinned bottom ────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().addProduct(CartItem(product: widget.product));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${widget.product.name} added to cart!'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Add To Cart',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Breadcrumb ───────────────────────────────────────────────────────────────
class _Breadcrumb extends StatelessWidget {
  final List<String> parts;
  const _Breadcrumb({required this.parts});

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (int i = 0; i < parts.length; i++) {
      final isLast = i == parts.length - 1;
      widgets.add(Text(
        parts[i],
        style: TextStyle(
          fontSize: 12,
          fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
          color: isLast ? AppColors.primary : AppColors.textMedium,
        ),
      ));
      if (!isLast) {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('»', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ));
      }
    }
    return Wrap(children: widgets);
  }
}
