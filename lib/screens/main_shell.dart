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

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

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
            height: 60,
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isActive = _selectedIndex == i;
                final color = isActive ? AppColors.primary : const Color(0xFFAAAAAA);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              item.asset,
                              width: 22, height: 22,
                              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                            ),
                            if (item.showBadge && cartCount > 0)
                              Positioned(
                                top: -6, right: -8,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$cartCount',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 9,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: color,
                          ),
                        ),
                      ],
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
