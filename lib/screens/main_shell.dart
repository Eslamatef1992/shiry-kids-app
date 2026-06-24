import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'coupons_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../widgets/ad_popup.dart';
import '../l10n/app_strings.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? _pendingCategoryId;
  late List<AnimationController> _bounceCtrl;
  late List<Animation<double>> _bounceAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showAdPopup(context);
    });
    _bounceCtrl = List.generate(
      _items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _bounceAnim = _bounceCtrl.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.30), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 1.30, end: 0.88), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeOut));
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _bounceCtrl) c.dispose();
    super.dispose();
  }

  void _goToProductsCategory(String categoryId) {
    setState(() {
      _pendingCategoryId = categoryId;
      _selectedIndex = 1;
    });
  }

  List<Widget> get _screens => [
    HomeScreen(onCategoryTap: _goToProductsCategory),
    ProductsScreen(initialCategoryId: _pendingCategoryId),
    const CouponsScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  static const _items = [
    _NavItem(asset: 'assets/icons/nav_home.svg',    label: 'Home'),
    _NavItem(asset: 'assets/icons/nav_product.svg', label: 'Product'),
    _NavItem(asset: 'assets/icons/nav_coupons.svg', label: 'Coupons'),
    _NavItem(asset: 'assets/icons/nav_cart.svg',    label: 'Cart',       showBadge: true),
    _NavItem(asset: 'assets/icons/nav_profile.svg', label: 'My Profile'),
  ];

  void _onTap(int i) {
    setState(() => _selectedIndex = i);
    _bounceCtrl[i].forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalCount;
    final isArabic = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    final order = isArabic
        ? List.generate(_items.length, (i) => _items.length - 1 - i)
        : List.generate(_items.length, (i) => i);
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 78,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: order.map((i) {
                  final item = _items[i];
                  final isActive = _selectedIndex == i;
                  final color = isActive ? AppColors.primary :
                   AppColors.textMedium;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _bounceAnim[i],
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SvgPicture.asset(
                                  item.asset,
                                  width: 35, height: 35,
                                  colorFilter: ColorFilter.mode(
                                      color, BlendMode.srcIn),
                                ),
                                if (item.showBadge && cartCount > 0)
                                  Positioned(
                                    top: 1, right: -2,
                                    child: Container(
                                      width: 18, height: 18,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$cartCount',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 10,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 0),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: isActive ? 20 : 0,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label.tr(context),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isActive ? FontWeight.w800 :
                              FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String asset;
  final String label;
  final bool showBadge;
  const _NavItem({required this.asset, required this.label, this.showBadge = false});
}