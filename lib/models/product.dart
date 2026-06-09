const String _baseUrl = 'https://back.sherykids.com';

String _imgUrl(dynamic v) {
  if (v == null || v.toString().isEmpty) return '';
  final s = v.toString();
  return s.startsWith('http') ? s : '$_baseUrl$s';
}

List<String> _strList(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [];
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
  final int stock;

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
    this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    final rawImages = j['images'] as List? ?? [];
    final imgList = rawImages.map((e) => _imgUrl(e)).where((e) => e.isNotEmpty).toList();
    final firstImg = imgList.isNotEmpty ? imgList.first : '';

    return Product(
      id: j['id'].toString(),
      name: j['name']?.toString() ?? '',
      nameAr: j['name_ar']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      descriptionAr: j['description_ar']?.toString() ?? '',
      price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
      originalPrice: double.tryParse(j['original_price']?.toString() ?? '0') ?? 0,
      imageUrl: firstImg,
      images: imgList,
      category: (j['category'] as Map?)?['name']?.toString() ?? '',
      categoryId: j['category_id']?.toString() ?? '',
      rating: double.tryParse(j['rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(j['reviews_count']?.toString() ?? '0') ?? 0,
      sizes: _strList(j['sizes']),
      colors: _strList(j['colors']),
      featured: j['featured'] == true || j['featured'] == 1,
      stock: int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
    );
  }

  int get discountPercent =>
      originalPrice > price ? ((originalPrice - price) / originalPrice * 100).round() : 0;

  bool get hasVariants => (sizes != null && sizes!.isNotEmpty) || (colors != null && colors!.isNotEmpty);
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
  final double price;
  final double originalPrice;
  final String discount;
  int quantity;
  CartCouponItem({
    required this.id, required this.title, required this.brandName,
    required this.brandImageUrl, required this.imageUrl,
    required this.couponCount, required this.price, required this.originalPrice,
    required this.discount, this.quantity = 1,
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
  final String category;
  final DateTime expiresAt;
  final bool featured;

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
    required this.category,
    required this.expiresAt,
    this.featured = false,
  });

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
      price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
      originalPrice: double.tryParse(j['original_price']?.toString() ?? '0') ?? 0,
      expiryDate: expiry.toLocal().toString().split(' ').first,
      couponsLeft: int.tryParse(j['coupon_count']?.toString() ?? '0') ?? 0,
      description: j['description']?.toString() ?? '',
      descriptionAr: j['description_ar']?.toString() ?? '',
      termsAndConditions: '',
      category: '',
      expiresAt: expiry,
      featured: j['featured'] == true || j['featured'] == 1,
    );
  }

  int get discountPercent =>
      originalPrice > price ? ((originalPrice - price) / originalPrice * 100).round() : 0;

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
