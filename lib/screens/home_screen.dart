import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/coupon_ticket_card.dart';
import '../widgets/category_image.dart';
import '../widgets/skeleton_loader.dart';
import 'search_screen.dart';
import 'coupon_detail_screen.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import '../l10n/app_strings.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

// ─── Screen ───────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerCtrl = PageController();
  int _bannerPage = 0;
  bool _loading = true;
  bool _error = false;
  String? _errorMsg;

  List<AppBanner> _banners = [];
  List<ProductCategory> _categories = [];
  List<CouponProduct> _featuredCoupons = [];
  List<Product> _featuredProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _weeklyOffers = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (mounted) setState(() { _loading = true; _error = false; _errorMsg = null; });
    try {
      final results = await Future.wait([
        ApiService.getBanners(),
        ApiService.getCategories(),
        ApiService.getCoupons(featured: true, limit: 5),
        ApiService.getProducts(featured: true, limit: 6),
        ApiService.getProducts(isNewArrival: true, limit: 6, sortBy: 'created_at'),
        ApiService.getProducts(isWeeklyOffer: true, limit: 6),
      ]);

      if (mounted) {
        setState(() {
          _banners = ((results[0]['data'] as List?) ?? [])
              .map((j) => AppBanner.fromJson(j as Map<String, dynamic>)).toList();
          _categories = ((results[1]['data'] as List?) ?? [])
              .map((j) => ProductCategory.fromJson(j as Map<String, dynamic>)).toList();
          _featuredCoupons = ((results[2]['data'] as List?) ?? [])
              .map((j) => CouponProduct.fromJson(j as Map<String, dynamic>)).toList();
          final data3 = results[3]['data'];
          final prodRows0 = data3 is Map ? (data3['rows'] as List? ?? []) : (data3 as List? ?? []);
          _featuredProducts = prodRows0.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
          final data4 = results[4]['data'];
          final prodRows1 = data4 is Map ? (data4['rows'] as List? ?? []) : (data4 as List? ?? []);
          _newArrivals = prodRows1.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
          final data5 = results[5]['data'];
          final prodRows2 = data5 is Map ? (data5['rows'] as List? ?? []) : (data5 as List? ?? []);
          _weeklyOffers = prodRows2.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('HomeScreen._loadAll error: $e');
      if (mounted) setState(() { _loading = false; _error = true; _errorMsg = e.toString(); });
    }
  }

  @override
  void dispose() { _bannerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white /*AppColors.background*/,
      body: Column(
        children: [
          _HomeAppBar(onSearchTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SearchScreen()),
          )),
          Expanded(
            child: _loading
                ? const HomeSkeleton()
                : _error
                ? LoadErrorView(onRetry: _loadAll, detail: _errorMsg)
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadAll,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),

                          // ── Banner ──────────────────────────────────────
                          if (_banners.isNotEmpty) ...[
                            _BannerWidget(ctrl: _bannerCtrl, page: _bannerPage,
                                banners: _banners, onChanged: (p) => setState(() => _bannerPage = p)),
                            const SizedBox(height: 18),
                          ],

                          // ── Categories ──────────────────────────────────
                          if (_categories.isNotEmpty) ...[
                            _sectionTitle(context, 'Categories', null),
                            const SizedBox(height: 10),
                            _CategoriesRow(categories: _categories),
                            const SizedBox(height: 20),
                          ],

                          // ── Featured Coupons ─────────────────────────────
                          if (_featuredCoupons.isNotEmpty) ...[
                            _sectionTitle(context, 'Coupons', null),
                            const SizedBox(height: 10),
                            _CouponsList(coupons: _featuredCoupons),
                            const SizedBox(height: 20),
                          ],

                          // ── Best Sellers ────────────────────────────────
                          if (_featuredProducts.isNotEmpty) ...[
                            _sectionTitle(context, 'Best Sellers', null),
                            const SizedBox(height: 10),
                            _ProductRow(products: _featuredProducts),
                            const SizedBox(height: 20),
                          ],

                          // ── New Arrivals ────────────────────────────────
                          if (_newArrivals.isNotEmpty) ...[
                            _sectionTitle(context, 'New Arrivals', null),
                            const SizedBox(height: 10),
                            _ProductRow(products: _newArrivals),
                            const SizedBox(height: 20),
                          ],

                          // ── Weekly Offers ────────────────────────────────
                          if (_weeklyOffers.isNotEmpty) ...[
                            _sectionTitle(context, 'Weekly Offers', null),
                            const SizedBox(height: 10),
                            _ProductRow(products: _weeklyOffers),
                            const SizedBox(height: 36),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title, VoidCallback? onSeeAll) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      if (onSeeAll != null)
        GestureDetector(
          onTap: onSeeAll,
          child: Text('See All'.tr(context), style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
    ],
  ),
);

// ─── AppBar ───────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _HomeAppBar({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipPath(
      clipper: _WavyClipper(),
      child: Container(
        color: AppColors.primary,
        height: top + 72,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_cropped.png', height: 46),
                const Spacer(),
                GestureDetector(
                  onTap: onSearchTap,
                  child: const Icon(Icons.search, color: Colors.white, size: 26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 16);
    double x = 0;
    bool up = false;
    while (x < size.width) {
      x += 20;
      path.quadraticBezierTo(x - 10, up ? size.height - 28 : size.height - 4, x, size.height - 16);
      up = !up;
    }
    path..lineTo(size.width, 0)..close();
    return path;
  }
  @override bool shouldReclip(_WavyClipper _) => false;
}

// ─── Banner ───────────────────────────────────────────────────────────────────
class _BannerWidget extends StatelessWidget {
  final PageController ctrl;
  final int page;
  final List<AppBanner> banners;
  final ValueChanged<int> onChanged;
  const _BannerWidget({required this.ctrl, required this.page, required this.banners, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 155,
            child: PageView.builder(
              controller: ctrl,
              onPageChanged: onChanged,
              itemCount: banners.length,
              itemBuilder: (_, i) {
                final b = banners[i];
                return b.imageUrl.startsWith('http')
                    ? Image.network(b.imageUrl, fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFFEDED)))
                    : Image.asset(b.imageUrl, fit: BoxFit.cover, width: double.infinity);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: page == i ? 10 : 8,
            height: page == i ? 10 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page == i ? AppColors.primary : const Color(0xFFDDDDDD),
            ),
          )),
        ),
      ],
    ),
  );
}

// ─── Categories Row ───────────────────────────────────────────────────────────
class _CategoriesRow extends StatelessWidget {
  final List<ProductCategory> categories;
  const _CategoriesRow({required this.categories});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final cat = categories[i];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9E3),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              ClipOval(
                child: CategoryImage(
                  imageUrl: cat.imageUrl,
                  imagePath: cat.imagePath,
                  emoji: cat.emoji,
                  size: 44,
                ),
              ),
              const SizedBox(width: 8),
              Text(cat.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    ),
  );
}

// ─── Coupon Card (horizontal ticket layout) ───────────────────────────────────
class _CouponsList extends StatelessWidget {
  final List<CouponProduct> coupons;
  const _CouponsList({required this.coupons});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 172,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 0),
      scrollDirection: Axis.horizontal,
      itemCount: coupons.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final item = coupons[i];
        final d = item.expiresAt.difference(DateTime.now());
        final countdown = '${d.inDays}d : ${d.inHours.remainder(24).toString().padLeft(2,"0")}h : ${d.inSeconds.remainder(60).toString().padLeft(2,"0")}s';
        return SizedBox(
          width: 320,
          child: CouponTicketCard(
            imageUrl: item.imageUrl,
            brandImageUrl: item.brandImageUrl,
            brandName: item.brandName,
            title: item.title,
            countdown: countdown,
            price: '${item.price.toStringAsFixed(3)} KD',
            originalPrice: '${item.originalPrice.toStringAsFixed(3)} KD',
            discount: '-${item.discountPercent}%',
            isOutOfStock: item.isOutOfStock,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CouponDetailScreen(coupon: item),
            )),
            onAddToCart: () {
              context.read<CartProvider>().addCoupon(item.toCartItem(quantity: 1));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${item.title} ${'added to cart!'.tr(context)}'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 2),
              ));
            },
          ),
        );
      },
    ),
  );
}

// ─── Product Card Row ─────────────────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  final List<Product> products;
  const _ProductRow({required this.products});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 260,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final p = products[i];
        final catLabel = (p.category.isNotEmpty ? p.category : 'Product').tr(context);
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: p, categoryName: catLabel),
          )),
          child: Container(
            width: 162,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + badge
                Stack(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: p.imageUrl.startsWith('http')
                        ? Image.network(p.imageUrl, width: 162, height: 130, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 162, height: 130, color: const Color(0xFFF5F5F5), child: const Center(child: Text('🎁', style: TextStyle(fontSize: 40)))))
                        : Image.asset(p.imageUrl, width: 162, height: 130, fit: BoxFit.cover),
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
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMedium,fontWeight: FontWeight.w700,)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text('${p.price.toInt()} Kwd',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(width: 5),
                        Text('${p.originalPrice.toInt()} Kwd',
                            style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w500, color: AppColors.textLight,
                                 decorationColor: AppColors.textLight)),
                        const SizedBox(width: 3),
                        Text('-${p.discountPercent} %',
                            style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addProduct(CartItem(product: p));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${p.name} ${'added to cart!'.tr(context)}'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            duration: const Duration(seconds: 2),
                          ));
                        },
                        child: Container(
                          width: double.infinity, height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('Add To Cart'.tr(context),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ─── Weekly Offers Row (retained for future use) ─────────────────────────────
class _WeeklyCard extends StatelessWidget {
  final Product offer;
  const _WeeklyCard({required this.offer});

  @override
  Widget build(BuildContext context) => Container(
    width: 175,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Countdown bar with scalloped bottom
        ClipPath(
          clipper: _ScallopClipper(),
          child: Container(
            width: double.infinity,
            color: const Color(0xFFFFEDED),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
            child: Text('',  // countdown placeholder
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
        ),
        // Image
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            child: offer.imageUrl.startsWith('http')
                ? Image.network(offer.imageUrl, width: double.infinity, fit: BoxFit.cover)
                : Image.asset(offer.imageUrl, width: double.infinity, fit: BoxFit.cover),
          ),
        ),
        // Bottom info
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(child: Text(offer.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                const SizedBox(width: 6),
                Text('\${offer.price.toStringAsFixed(3)} KD',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ]),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  final product = Product(
                    id: 'w_${offer.name.hashCode}',
                    name: offer.name,
                    description: offer.description,
                    price: offer.price,
                    originalPrice: offer.originalPrice,
                    imageUrl: offer.imageUrl,
                    category: 'birthday',
                  );
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product, categoryName: 'Weekly Offer'),
                  ));
                },
                child: Container(
                  width: double.infinity, height: 26,
                  decoration: BoxDecoration(color: const Color(0xFFFFEDED), borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text('Details'.tr(context), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ScallopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width, size.height - 10);
    double x = size.width;
    bool up = true;
    while (x > 0) {
      x -= 12;
      path.quadraticBezierTo(x + 6, up ? size.height : size.height - 20, x, size.height - 10);
      up = !up;
    }
    path..lineTo(0, 0)..close();
    return path;
  }
  @override bool shouldReclip(_ScallopClipper _) => false;
}
