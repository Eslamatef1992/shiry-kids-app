import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../widgets/wavy_app_bar.dart';
import '../widgets/network_image.dart';
import 'checkout_screen.dart';
import 'guest_checkout_screen.dart';
import '../l10n/app_strings.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Track open dropdowns per product index
  final Map<int, bool> _sizeOpen = {};
  final Map<int, bool> _colorOpen = {};

  void _onCheckout(List<CartCouponItem> coupons, List<CartItem> products) async {
    final loggedIn = await ApiService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      // Logged-in users go straight to checkout (their saved address is loaded there).
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          coupons: coupons,
          products: products,
          hasCoupons: coupons.isNotEmpty,
        ),
      ));
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => _GuestOrLoginDialog(
        onLogin: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/login');
          });
        },
        onGuest: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => GuestCheckoutScreen(
                onSaved: (data) => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CheckoutScreen(
                    coupons: coupons,
                    products: products,
                    hasCoupons: coupons.isNotEmpty,
                    guestName: data['name'],
                    guestEmail: data['email'],
                    guestPhone: data['phone'],
                    initialAddress: data['address'],
                  ),
                )),
              ),
            ));
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: WavyAppBar(title: 'Cart'.tr(context), showBack: false),
          body: cart.isEmpty ? _emptyState() : _filledState(cart),
        );
      },
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.primary.withOpacity(0.25)),
      const SizedBox(height: 16),
      Text('You Have Not Any Item In Cart'.tr(context),
          style: const TextStyle(fontSize: 15, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _filledState(CartProvider cart) {
    final coupons = cart.coupons;
    final products = cart.products;
    final totalItems = coupons.length + products.length;
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${'Cart Item'.tr(context)} ($totalItems)',
                style: const TextStyle(fontSize: 15,
                    color: AppColors.textMedium,fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // Coupon items
            ...coupons.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CouponCartCard(
                item: e.value,
                onDelete: () => cart.removeCoupon(e.value.id),
                onQty: (q) => cart.updateCouponQty(e.value.id, q),
              ),
            )),

            // Product items
            ...products.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCartCard(
                  item: item,
                  sizeOpen: _sizeOpen[i] == true,
                  colorOpen: _colorOpen[i] == true,
                  onDelete: () => cart.removeProduct(item.product.id),
                  onQty: (q) => cart.updateProductQty(item.product.id, q),
                  onToggleSize: () => setState(() {
                    _sizeOpen[i] = !(_sizeOpen[i] == true);
                    _colorOpen[i] = false;
                  }),
                  onToggleColor: () => setState(() {
                    _colorOpen[i] = !(_colorOpen[i] == true);
                    _sizeOpen[i] = false;
                  }),
                  onSelectSize: (s) => setState(() {
                    item.selectedSize = s;
                    _sizeOpen[i] = false;
                  }),
                  onSelectColor: (c) => setState(() {
                    item.selectedColor = c;
                    _colorOpen[i] = false;
                  }),
                ),
              );
            }),

            // Summary
            const SizedBox(height: 4),
            _SummarySection(subtotal: cart.subtotal, hasProducts: products.isNotEmpty),
          ]),
        ),
      ),

      // Checkout button
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _onCheckout(List.from(coupons), List.from(products)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Checkout'.tr(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ]);
  }
}

// ─── Coupon Cart Card (ticket style) ─────────────────────────────────────────

class _CouponCartCard extends StatelessWidget {
  final CartCouponItem item;
  final VoidCallback onDelete;
  final ValueChanged<int> onQty;
  const _CouponCartCard({required this.item, required this.onDelete, required this.onQty});


  @override
  Widget build(BuildContext context) {
    return Container(
     // height: 180,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: image
              SizedBox(
                width: 112,
                height: 112,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: smartImage(item.imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),

              // Middle: content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // name
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 30, 10, 5),
                      child: Text(item.title,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: AppColors.textDark, height: 1.35)),
                    ),
                    // brand + logo
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 8, 0),
                      child: Row(
                        children: [
                          // ── Brand logo circle (overlapping image/content boundary) ──
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(color: Color(0x20000000), blurRadius: 4)
                              ],
                            ),
                            child: ClipOval(
                              child: smartImage(item.brandImageUrl, fit: BoxFit.cover,
                                  placeholder: Container(
                                      color: AppColors.primary.withOpacity(0.1),
                                      child: const Icon(Icons.storefront_outlined,
                                          size: 14, color: AppColors.primary))),
                            ),
                          ),
                          const SizedBox(width: 5,),
                          Text(item.brandName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w800,
                                  color: Color(0xFFE73C00))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topRight: Localizations.localeOf(context).languageCode=="ar"?
                        const Radius.circular(0):const Radius.circular(16),
                        topLeft: Localizations.localeOf(context).languageCode=="en"?
                        const Radius.circular(0):const Radius.circular(16),
                      )
                  ),
                  child: SvgPicture.asset('assets/images/delete.svg',fit: BoxFit.none,),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4,),
          // Coupon count
         /* Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white
            ),
            child: Center(
              child: Text('${'Number Of'.tr(context)} ${'Coupons:'.tr(context)} ${item.couponCount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                      fontSize: 12, color: AppColors.textLight)),
            ),
          ),*/
          const Divider(height: 4, color: Colors.white,thickness: 4,),
          // price + quantity
          Padding(
            padding: const EdgeInsets.fromLTRB(22,8,22,10),
            child: Row(
              children: [
                Text('${item.price} Kd',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const Spacer(),
                _QtyRow(qty: item.quantity, onQty: onQty,
                    maxQty: CartProvider.maxQtyForStock(item.qrCodeAvailable)),
              ],
            ),
          ),
          // Discount + quantity
          /*Row(
            children: [
              const SizedBox(height: 12),
              // Discount badge
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCFD0).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(item.discount,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ),
              const Spacer(),
              // Coupon qty display
              Text('${item.quantity}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text('qty'.tr(context),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textLight)),
              const SizedBox(height: 12),
            ],
          ),*/
        ],
      ),
    );
  }
}



// ─── Product Cart Card ────────────────────────────────────────────────────────

class _ProductCartCard extends StatelessWidget {
  final CartItem item;
  final bool sizeOpen;
  final bool colorOpen;
  final VoidCallback onDelete;
  final ValueChanged<int> onQty;
  final VoidCallback onToggleSize;
  final VoidCallback onToggleColor;
  final ValueChanged<String> onSelectSize;
  final ValueChanged<String> onSelectColor;
  const _ProductCartCard({
    required this.item, required this.sizeOpen, required this.colorOpen,
    required this.onDelete, required this.onQty, required this.onToggleSize,
    required this.onToggleColor, required this.onSelectSize, required this.onSelectColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final catLabel = (p.category == 'birthday' ? 'Birthday' : "Mother's Day").tr(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
       // boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10,12,0,0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: smartImage(p.imageUrl, width: 80, height: 80, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12,12,0,0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(catLabel,
                    style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(p.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight,fontWeight: FontWeight.w500,)),
              ]),
            ),
          ),
                 // delete
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary,
            borderRadius: BorderRadius.only(
                topRight: Localizations.localeOf(context).languageCode=="ar"?
                const Radius.circular(0):const Radius.circular(16),
              topLeft: Localizations.localeOf(context).languageCode=="en"?
              const Radius.circular(0):const Radius.circular(16),
            ),
              ),
              child: SvgPicture.asset('assets/images/delete.svg',fit: BoxFit.none,),
            ),
          ),
        ]),

        // Size (if product has sizes)
        if (p.sizes != null && p.sizes!.isNotEmpty) ...[
          GestureDetector(
            onTap: onToggleSize,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Text('Size:'.tr(context), style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(item.selectedSize ?? 'M',
                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(sizeOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary, size: 18),
              ]),
            ),
          ),
          if (sizeOpen)
            _DropdownOptions(
              options: p.sizes!,
              selected: item.selectedSize,
              onSelect: onSelectSize,
            ),
        ],

        // Color (if product has colors)
        if (p.colors != null && p.colors!.isNotEmpty) ...[
          GestureDetector(
            onTap: onToggleColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Text('Color:'.tr(context), style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorFromName(item.selectedColor ?? 'Green'),
                  ),
                ),
                const SizedBox(width: 6),
                Text(item.selectedColor ?? 'Green',
                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(colorOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary, size: 18),
              ]),
            ),
          ),
          if (colorOpen)
            _ColorDropdownOptions(
              colors: p.colors!,
              selected: item.selectedColor,
              onSelect: onSelectColor,
            ),
        ],

        // Item count label
        Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 10),
              margin: const EdgeInsets.symmetric( vertical: 8,horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white
              ),
              child: Center(
                child: Text('${'Number Of Item'.tr(context)}: ${item.product.stock}',
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight)),
              ),
            ),
        ),
        const Divider(height: 2, color: Colors.white,thickness: 2,),

        // Price + qty
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(children: [
            Text('${p.price} Kwd',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const Spacer(),
            _QtyRow(qty: item.quantity, onQty: onQty),
          ]),
        ),
      ]),
    );
  }
}

Color _colorFromName(String name) {
  switch (name.toLowerCase()) {
    case 'white': return const Color(0xFFF0F0F0);
    case 'black': return const Color(0xFF222222);
    case 'red': return const Color(0xFFE53935);
    case 'blue': return const Color(0xFF1976D2);
    case 'green': return const Color(0xFF388E3C);
    default: return const Color(0xFF888888);
  }
}

// ─── Dropdown Options ─────────────────────────────────────────────────────────

class _DropdownOptions extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _DropdownOptions({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: options.map((o) => GestureDetector(
          onTap: () => onSelect(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: o != options.last
                  ? const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), style: BorderStyle.solid))
                  : null,
            ),
            child: Row(children: [
              Text(o, style: TextStyle(
                fontSize: 13,
                color: o == selected ? AppColors.primary : AppColors.textDark,
                fontWeight: o == selected ? FontWeight.w700 : FontWeight.w500,
              )),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}

class _ColorDropdownOptions extends StatelessWidget {
  final List<String> colors;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _ColorDropdownOptions({required this.colors, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: colors.map((c) => GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: c != colors.last
                  ? const Border(bottom: BorderSide(color: Color(0xFFEEEEEE), style: BorderStyle.solid))
                  : null,
            ),
            child: Row(children: [
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _colorFromName(c)),
              ),
              const SizedBox(width: 10),
              Text(c, style: TextStyle(
                fontSize: 13,
                color: c == selected ? AppColors.primary : AppColors.textDark,
                fontWeight: c == selected ? FontWeight.w700 : FontWeight.w500,
              )),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}

// ─── Qty Row ──────────────────────────────────────────────────────────────────

class _QtyRow extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onQty;
  final int? maxQty;
  const _QtyRow({required this.qty, required this.onQty, this.maxQty});

  @override
  Widget build(BuildContext context) => Row(children: [
    _QtyBtn(icon: Icons.add,isAdd: true,
        onTap: maxQty == null || qty < maxQty! ? () => onQty(qty + 1) : null),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    ),
    _QtyBtn(icon: Icons.remove,isAdd: false ,onTap: qty > 1 ? () => onQty(qty - 1) : null,

    ),
  ]);
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final bool isAdd;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap, required this.isAdd});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: onTap == null || !isAdd ?const Color(0xffFFE9E3): AppColors.primary ,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16,
          color: isAdd? Colors.white : AppColors.primary
      ),
    ),
  );
}

// ─── Summary ──────────────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final double subtotal;
  final bool hasProducts;
  const _SummarySection({required this.subtotal, this.hasProducts = true});

  // Flat delivery fee charged by the backend when the order contains at
  // least one product (see order.controller.js: delivery_fees). Coupon-only
  // orders aren't shipped, so no delivery fee applies for them.
  static const double deliveryFee = 1.5;

  @override
  Widget build(BuildContext context) {
    final total = subtotal + (hasProducts ? deliveryFee : 0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Summary'.tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        //  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(children: [
          _SumRow('Subtotal'.tr(context), '${subtotal.toStringAsFixed(2)} Kw'),
          _SumRow('Discount'.tr(context), '0.00 Kw', valueColor: AppColors.primary),
          _SumRow('Shipping Fees'.tr(context), '0.00 Kw'),
          if (hasProducts) _SumRow('Delivery Fees'.tr(context), '${deliveryFee.toStringAsFixed(2)} Kw'),
          const Divider(height: 16, color: Color(0xFFF0F0F0)),
          _SumRow('Total'.tr(context), '${total.toStringAsFixed(2)} Kwd',
              labelBold: true, valueColor: AppColors.primary, valueBold: true),
        ]),
      ),
    ]);
  }
}

class _SumRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool labelBold, valueBold;
  const _SumRow(this.label, this.value, {this.valueColor, this.labelBold = false, this.valueBold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: 14, color: labelBold?Colors.black: AppColors.textMedium,
          fontWeight: labelBold ? FontWeight.w700 : FontWeight.w600,
        )),
        Text(value, style: TextStyle(
          fontSize: 13,
          color: valueColor ?? AppColors.textDark,
          fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
        )),
      ],
    ),
  );
}

// ─── Guest or Login dialog ────────────────────────────────────────────────────

class _GuestOrLoginDialog extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGuest;
  const _GuestOrLoginDialog({required this.onLogin, required this.onGuest});

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: Colors.white,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text('Do You Want Login Or Continue As A Guest?'.tr(context),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: AppColors.primary, size: 22),
          ),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Log In'.tr(context), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onGuest,
          child: Center(
            child: Text('Continue As Guest'.tr(context),
                style: const TextStyle(fontSize: 14, color: AppColors.primary,
                    fontWeight: FontWeight.w700, decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 4),
      ]),
    ),
  );
}
