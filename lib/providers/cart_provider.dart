import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  // A single checkout can only carry up to this many units of the same
  // coupon — buying more requires a separate checkout.
  static const int maxCouponQtyPerCheckout = 5;

  final List<CartCouponItem> _coupons = [];
  final List<CartItem> _products = [];

  List<CartCouponItem> get coupons => List.unmodifiable(_coupons);
  List<CartItem> get products => List.unmodifiable(_products);

  bool get isEmpty => _coupons.isEmpty && _products.isEmpty;

  int get totalCount =>
      _coupons.fold(0, (s, c) => s + c.quantity) +
      _products.fold(0, (s, p) => s + p.quantity);

  double get subtotal =>
      _coupons.fold(0.0, (s, c) => s + c.total) +
      _products.fold(0.0, (s, p) => s + p.total);

  // ── Coupons ──────────────────────────────────────────────────────────────

  void addCoupon(CartCouponItem item) {
    final idx = _coupons.indexWhere((c) => c.id == item.id);
    if (idx >= 0) {
      _coupons[idx].quantity =
          (_coupons[idx].quantity + item.quantity).clamp(1, maxCouponQtyPerCheckout);
    } else {
      item.quantity = item.quantity.clamp(1, maxCouponQtyPerCheckout);
      _coupons.add(item);
    }
    notifyListeners();
  }

  void removeCoupon(String id) {
    _coupons.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void updateCouponQty(String id, int qty) {
    if (qty <= 0) { removeCoupon(id); return; }
    final idx = _coupons.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      _coupons[idx].quantity = qty.clamp(1, maxCouponQtyPerCheckout);
      notifyListeners();
    }
  }

  // ── Products ─────────────────────────────────────────────────────────────

  void addProduct(CartItem item) {
    final idx = _products.indexWhere((p) => p.product.id == item.product.id);
    if (idx >= 0) {
      _products[idx].quantity += item.quantity;
    } else {
      _products.add(item);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _products.removeWhere((p) => p.product.id == productId);
    notifyListeners();
  }

  void updateProductQty(String productId, int qty) {
    if (qty <= 0) { removeProduct(productId); return; }
    final idx = _products.indexWhere((p) => p.product.id == productId);
    if (idx >= 0) { _products[idx].quantity = qty; notifyListeners(); }
  }

  void clear() {
    _coupons.clear();
    _products.clear();
    notifyListeners();
  }
}
