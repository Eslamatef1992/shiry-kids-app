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

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showAdPopup(context);
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductsScreen(),
    CouponsScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    _NavItem(asset: 'assets/icons/nav_home.svg',    label: 'Home'),
    _NavItem(asset: 'assets/icons/nav_product.svg', label: 'Product'),
    _NavItem(asset: 'assets/icons/nav_coupons.svg', label: 'Coupons'),
    _NavItem(asset: 'assets/icons/nav_cart.svg',    label: 'Cart',       showBadge: true),
    _NavItem(asset: 'assets/icons/nav_profile.svg', label: 'My Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalCount;
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
            height: 72,
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isActive = _selectedIndex == i;
                final color = isActive ? Colors.white : const Color(0xFFAAAAAA);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: Semantics(
                    label: item.label,
                    selected: isActive,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isActive ? 50 : 40,
                            height: isActive ? 50 : 40,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              item.asset,
                              width: isActive ? 24 : 22,
                              height: isActive ? 24 : 22,
                              colorFilter: ColorFilter.mode(
                                isActive ? color : const Color(0xFFAAAAAA),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          if (item.showBadge && cartCount > 0)
                            Positioned(
                              top: isActive ? -2 : 2, right: isActive ? 0 : 6,
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white : AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: isActive ? Border.all(color: AppColors.primary, width: 1.5) : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '$cartCount',
                                    style: TextStyle(
                                        color: isActive ? AppColors.primary : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ),
                  ),
                );
              }),
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
