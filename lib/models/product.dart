const String _baseUrl = 'https://back.sherykids.com';

String _imgUrl(dynamic v) {
  if (v == null || v.toString().isEmpty) return '';
  final s = v.toString();
  return s.startsWith('http') ? s : '$_baseUrl$s';
}

/// Parses [v] as a [double], guarding against backend values that
/// round-trip to the strings "NaN"/"Infinity"/"-Infinity" (which
/// [double.tryParse] happily accepts). A non-finite price would later
/// crash `.toInt()` calls in the UI (e.g. the checkout coupon/product
/// cards), producing a build-time exception that blanks that part of
/// the screen — so any non-finite result is treated as 0 here instead.
double _safeDouble(dynamic v) {
  final d = double.tryParse(v?.toString() ?? '0') ?? 0;
  return d.isFinite ? d : 0;
}

List<String> _strList(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [];
}

class ProductVariant {
  final String? id;
  final String? size;
  final String? color;
  final String? sku;
  final double? price;
  final int stock;
  final String imageUrl;

  const ProductVariant({
    this.id,
    this.size,
    this.color,
    this.sku,
    this.price,
    this.stock = 0,
    this.imageUrl = '',
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) {
    return ProductVariant(
      id: j['id']?.toString(),
      size: j['size']?.toString(),
      color: j['color']?.toString(),
      sku: j['sku']?.toString(),
      price: j['price'] != null ? double.tryParse(j['price'].toString()) : null,
      stock: int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
      imageUrl: _imgUrl(j['image']),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final List<String> images;
  final String category;
  final String categoryId;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final List<String>? sizes;
  final List<String>? colors;
  final bool featured;
  final bool isNewArrival;
  final bool isWeeklyOffer;
  final int stock;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    this.nameAr = '',
    this.description = '',
    this.descriptionAr = '',
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    this.images = const [],
    required this.category,
    this.categoryId = '',
    this.rating = 4.5,
    this.reviewCount = 0,
    this.isFavorite = false,
    this.sizes,
    this.colors,
    this.featured = false,
    this.isNewArrival = false,
    this.isWeeklyOffer = false,
    this.stock = 0,
    this.variants = const [],
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    final rawImages = j['images'] as List? ?? [];
    final imgList = rawImages.map((e) => _imgUrl(e)).where((e) => e.isNotEmpty).toList();
    final firstImg = imgList.isNotEmpty ? imgList.first : '';
    final rawVariants = j['variants'] as List? ?? [];

    return Product(
      id: j['id'].toString(),
      name: j['name']?.toString() ?? '',
      nameAr: j['name_ar']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      descriptionAr: j['description_ar']?.toString() ?? '',
      price: _safeDouble(j['price']),
      originalPrice: _safeDouble(j['original_price']),
      imageUrl: firstImg,
      images: imgList,
      category: (j['category'] as Map?)?['name']?.toString() ?? '',
      categoryId: j['category_id']?.toString() ?? '',
      rating: double.tryParse(j['rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(j['reviews_count']?.toString() ?? '0') ?? 0,
      sizes: _strList(j['sizes']),
      colors: _strList(j['colors']),
      featured: j['featured'] == true || j['featured'] == 1,
      isNewArrival: j['is_new_arrival'] == true || j['is_new_arrival'] == 1,
      isWeeklyOffer: j['is_weekly_offer'] == true || j['is_weekly_offer'] == 1,
      stock: int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
      variants: rawVariants.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>)).toList(),
    );
  }

  int get discountPercent =>
      originalPrice > price ? ((originalPrice - price) / originalPrice * 100).round() : 0;

  bool get hasVariants =>
      (sizes != null && sizes!.isNotEmpty) || (colors != null && colors!.isNotEmpty) || variants.isNotEmpty;

  /// Find a specific variant matching the selected size/color, if any.
  ProductVariant? variantFor({String? size, String? color}) {
    if (variants.isEmpty) return null;
    for (final v in variants) {
      final sizeMatches = size == null || v.size == null || v.size == size;
      final colorMatches = color == null || v.color == null || v.color == color;
      if (sizeMatches && colorMatches && (v.size == size || v.color == color)) return v;
    }
    return null;
  }
}

class CartItem {
  final Product product;
  int quantity;
  String? selectedSize;
  String? selectedColor;
  CartItem({required this.product, this.quantity = 1, this.selectedSize, this.selectedColor});
  double get total => product.price * quantity;
}

class CartCouponItem {
  final String id;
  final String title;
  final String brandName;
  final String brandImageUrl;
  final String imageUrl;
  final int couponCount;
  final int qrCodeAvailable;
  final double price;
  final double originalPrice;
  final String discount;
  int quantity;
  CartCouponItem({
    required this.id, required this.title, required this.brandName,
    required this.brandImageUrl, required this.imageUrl,
    required this.couponCount, required this.price, required this.originalPrice,
    required this.discount, this.quantity = 1, required this.qrCodeAvailable,
  });
  double get total => price * quantity;
}

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
    required this.id, required this.code, required this.title,
    required this.description, required this.discount, required this.isPercent,
    required this.expiryDate, this.isUsed = false,
  });
}

class CouponProduct {
  final String id;
  final String title;
  final String titleAr;
  final String brandName;
  final String brandImageUrl;
  final String imageUrl;
  final double price;
  final double originalPrice;
  final String expiryDate;
  final int couponsLeft;
  final String description;
  final String descriptionAr;
  final String termsAndConditions;
  final String termsAndConditionsAr;
  final String category;
  final DateTime expiresAt;
  final bool featured;
  final int? discountPercentValue;
  final int qrTotal;
  final int qrAvailable;

  const CouponProduct({
    required this.id,
    required this.title,
    this.titleAr = '',
    required this.brandName,
    required this.brandImageUrl,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.expiryDate,
    required this.couponsLeft,
    required this.description,
    this.descriptionAr = '',
    this.termsAndConditions = '',
    this.termsAndConditionsAr = '',
    required this.category,
    required this.expiresAt,
    this.featured = false,
    this.discountPercentValue,
    this.qrTotal = 0,
    this.qrAvailable = 0,
  });

  /// Coupon is sold out only if it uses the per-unit QR system (qrTotal > 0)
  /// and all uploaded QR codes have already been assigned/used.
  bool get isOutOfStock =>  qrAvailable == 0;

  factory CouponProduct.fromJson(Map<String, dynamic> j) {
    final expiry = j['expiry_date'] != null
        ? DateTime.tryParse(j['expiry_date'].toString()) ?? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));
    final vendor = j['vendor'] as Map? ?? {};

    return CouponProduct(
      id: j['id'].toString(),
      title: j['title']?.toString() ?? '',
      titleAr: j['title_ar']?.toString() ?? '',
      brandName: vendor['name']?.toString() ?? '',
      brandImageUrl: _imgUrl(vendor['logo']),
      imageUrl: _imgUrl(j['image']),
      price: _safeDouble(j['price']),
      originalPrice: _safeDouble(j['original_price']),
      expiryDate: expiry.toLocal().toString().split(' ').first,
      couponsLeft: int.tryParse(j['coupon_count']?.toString() ?? '0') ?? 0,
      description: j['description']?.toString() ?? '',
      descriptionAr: j['description_ar']?.toString() ?? '',
      termsAndConditions: j['terms_and_conditions']?.toString() ?? '',
      termsAndConditionsAr: j['terms_and_conditions_ar']?.toString() ?? '',
      category: j['category']?.toString() ?? '',
      expiresAt: expiry,
      featured: j['featured'] == true || j['featured'] == 1,
      discountPercentValue: j['discount_percent'] != null
          ? int.tryParse(j['discount_percent'].toString())
          : null,
      qrTotal: int.tryParse(j['qr_total']?.toString() ?? '0') ?? 0,
      qrAvailable: int.tryParse(j['qr_available']?.toString() ?? '0') ?? 0,
    );
  }

  /// Use the admin-set discount percentage when available; otherwise fall
  /// back to computing it from price vs original price.
  int get discountPercent {
    if (discountPercentValue != null && discountPercentValue! > 0) return discountPercentValue!;
    return originalPrice > price ? ((originalPrice - price) / originalPrice * 100).round() : 0;
  }

  CartCouponItem toCartItem({int quantity = 1}) => CartCouponItem(
        id: id,
        title: title,
        brandName: brandName,
        brandImageUrl: brandImageUrl,
        imageUrl: imageUrl,
        couponCount: quantity,
        price: price,
        originalPrice: originalPrice,
        discount: '-${discountPercent}%',
        quantity: quantity,
      qrCodeAvailable: qrAvailable,
      );
}

class ProductCategory {
  final String id;
  final String name;
  final String nameAr;
  final String emoji;
  final String? imagePath;
  final String? imageUrl;

  const ProductCategory({
    required this.id,
    required this.name,
    this.nameAr = '',
    required this.emoji,
    this.imagePath,
    this.imageUrl,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> j) {
    return ProductCategory(
      id: j['id'].toString(),
      name: j['name']?.toString() ?? '',
      nameAr: j['name_ar']?.toString() ?? '',
      emoji: '',
      imageUrl: _imgUrl(j['image']),
    );
  }

  int get count => 0;
}

class CouponCategory {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final int sort;

  const CouponCategory({
    required this.id,
    required this.name,
    this.nameAr = '',
    required this.slug,
    this.sort = 0,
  });

  factory CouponCategory.fromJson(Map<String, dynamic> j) {
    return CouponCategory(
      id: j['id'].toString(),
      name: j['name']?.toString() ?? '',
      nameAr: j['name_ar']?.toString() ?? '',
      slug: j['slug']?.toString() ?? '',
      sort: int.tryParse(j['sort']?.toString() ?? '0') ?? 0,
    );
  }
}

class AppBanner {
  final String id;
  final String title;
  final String titleAr;
  final String imageUrl;
  final String? link;

  const AppBanner({
    required this.id,
    this.title = '',
    this.titleAr = '',
    required this.imageUrl,
    this.link,
  });

  factory AppBanner.fromJson(Map<String, dynamic> j) {
    return AppBanner(
      id: j['id'].toString(),
      title: j['title']?.toString() ?? '',
      titleAr: j['title_ar']?.toString() ?? '',
      imageUrl: _imgUrl(j['image']),
      link: j['link']?.toString(),
    );
  }
}

class AppAd {
  final String id;
  final String title;
  final String titleAr;
  final String imageUrl;
  final String linkType; // none | product | coupon | external
  final String? productId;
  final String? couponId;
  final String? externalLink;

  const AppAd({
    required this.id,
    this.title = '',
    this.titleAr = '',
    required this.imageUrl,
    this.linkType = 'none',
    this.productId,
    this.couponId,
    this.externalLink,
  });

  factory AppAd.fromJson(Map<String, dynamic> j) {
    return AppAd(
      id: j['id'].toString(),
      title: j['title']?.toString() ?? '',
      titleAr: j['title_ar']?.toString() ?? '',
      imageUrl: _imgUrl(j['image']),
      linkType: j['link_type']?.toString() ?? 'none',
      productId: j['product_id']?.toString(),
      couponId: j['coupon_id']?.toString(),
      externalLink: j['external_link']?.toString(),
    );
  }
}

class AppOrder {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double total;
  final DateTime createdAt;
  final List<dynamic> items;

  const AppOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory AppOrder.fromJson(Map<String, dynamic> j) {
    return AppOrder(
      id: j['id'].toString(),
      orderNumber: j['order_number']?.toString() ?? '',
      status: j['order_status']?.toString() ?? 'processing',
      paymentStatus: j['payment_status']?.toString() ?? 'pending',
      paymentMethod: j['payment_method']?.toString() ?? '',
      total: double.tryParse(j['total']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      items: (j['items'] as List?) ?? [],
    );
  }
}
