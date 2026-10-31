import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _sort = 'Popular';
  final List<String> _sortOptions = ['Popular', 'Newest', 'Price: Low to High', 'Price: High to Low'];

  final List<Product> _products = [
    Product(id: '1', name: 'Educational Puzzle', price: 49.99, originalPrice: 79.99, imageUrl: '', category: 'Toys', rating: 4.5, reviewCount: 120),
    Product(id: '2', name: 'Story Book Set', price: 29.99, originalPrice: 45.00, imageUrl: '', category: 'Books', rating: 4.8, reviewCount: 85),
    Product(id: '3', name: 'Art Supply Kit', price: 35.00, originalPrice: 50.00, imageUrl: '', category: 'Art', rating: 4.3, reviewCount: 64),
    Product(id: '4', name: 'Building Blocks', price: 59.99, originalPrice: 89.99, imageUrl: '', category: 'Toys', rating: 4.7, reviewCount: 200),
    Product(id: '5', name: 'Coloring Book', price: 12.99, originalPrice: 19.99, imageUrl: '', category: 'Books', rating: 4.2, reviewCount: 50),
    Product(id: '6', name: 'Play Dough Set', price: 22.99, originalPrice: 34.99, imageUrl: '', category: 'Art', rating: 4.6, reviewCount: 90),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Sort bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_products.length} Products', style: const TextStyle(color: AppColors.textMedium, fontSize: 13)),
                DropdownButton<String>(
                  value: _sort,
                  underline: const SizedBox(),
                  style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                  items: _sortOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _sort = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: _products.length,
              itemBuilder: (_, i) => ProductCard(product: _products[i]),
            ),
          ),
        ],
      ),
    );
  }
}
