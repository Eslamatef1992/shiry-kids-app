class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
  });

  int get discountPercent =>
      ((originalPrice - price) / originalPrice * 100).round();
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

// ── Purchasable coupon product (from backend) ─────────────────────────────────
class CouponProduct {
  final int backendId;
  final String imageUrl;
  final String title;
  final String brandName;
  final String description;
  final String termsAndConditions;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final String expiryDate;
  final DateTime expiresAt;
  final int couponsLeft;

  const CouponProduct({
    required this.backendId,
    required this.imageUrl,
    required this.title,
    required this.brandName,
    required this.description,
    this.termsAndConditions = '',
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    required this.expiryDate,
    required this.expiresAt,
    required this.couponsLeft,
  });

  CartCouponItem toCartItem({int quantity = 1}) => CartCouponItem(
    id: backendId.toString(),
    backendId: backendId,
    imageUrl: imageUrl,
    title: title,
    brandName: brandName,
    price: price,
    discount: '$discountPercent% OFF',
    quantity: quantity,
  );

  factory CouponProduct.fromJson(Map<String, dynamic> j) {
    final expiry = j['expiry_date'] != null
        ? DateTime.tryParse(j['expiry_date'].toString()) ?? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));
    final price = double.tryParse(j['price'].toString()) ?? 0.0;
    final original = double.tryParse(j['original_price']?.toString() ?? '0') ?? price;
    final discount = int.tryParse(j['discount_percent']?.toString() ?? '0') ?? 0;
    return CouponProduct(
      backendId: j['id'] as int,
      imageUrl: j['image'] ?? '',
      title: j['title'] ?? '',
      brandName: j['vendor']?['name'] ?? '',
      description: j['description'] ?? '',
      termsAndConditions: j['terms_and_conditions'] ?? '',
      price: price,
      originalPrice: original,
      discountPercent: discount,
      expiryDate: expiry.day.toString().padLeft(2, '0') + ' '
          + ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][expiry.month - 1]
          + ' ${expiry.year}',
      expiresAt: expiry,
      couponsLeft: j['coupon_count'] ?? 0,
    );
  }
}

// ── Cart item for purchasable coupons ─────────────────────────────────────────
class CartCouponItem {
  final String id;
  final int backendId;
  final String imageUrl;
  final String title;
  final String brandName;
  final double price;
  final String discount;
  int quantity;

  CartCouponItem({
    required this.id,
    required this.backendId,
    required this.imageUrl,
    required this.title,
    required this.brandName,
    required this.price,
    required this.discount,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

// ── Discount coupon (promo code) ──────────────────────────────────────────────
class Coupon {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discount;
  final bool isPercent;
  final String expiryDate;
  final bool isUsed;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.isPercent,
    required this.expiryDate,
    this.isUsed = false,
  });
}
