import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://back.sherykids.com/api/v1';

  // ── Auth token management ─────────────────────────────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token, {String? refresh}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (refresh != null) await prefs.setString('refresh_token', refresh);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Base request ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool adminAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    if (auth || adminAuth) {
      final prefs = await SharedPreferences.getInstance();
      final key = adminAuth ? 'admin_token' : 'auth_token';
      final token = prefs.getString(key);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    final bodyStr = body != null ? jsonEncode(body) : null;
    const timeout = Duration(seconds: 15);

    switch (method.toUpperCase()) {
      case 'POST':   response = await http.post(uri, headers: headers, body: bodyStr).timeout(timeout); break;
      case 'PUT':    response = await http.put(uri, headers: headers, body: bodyStr).timeout(timeout); break;
      case 'PATCH':  response = await http.patch(uri, headers: headers, body: bodyStr).timeout(timeout); break;
      case 'DELETE': response = await http.delete(uri, headers: headers).timeout(timeout); break;
      default:       response = await http.get(uri, headers: headers).timeout(timeout);
    }

    if (response.statusCode == 401) {
      await _tryRefresh(adminAuth: adminAuth);
      // Retry once
      final newToken = adminAuth
          ? (await SharedPreferences.getInstance()).getString('admin_token')
          : (await SharedPreferences.getInstance()).getString('auth_token');
      if (newToken != null) headers['Authorization'] = 'Bearer $newToken';
      switch (method.toUpperCase()) {
        case 'POST':   response = await http.post(uri, headers: headers, body: bodyStr).timeout(timeout); break;
        case 'PUT':    response = await http.put(uri, headers: headers, body: bodyStr).timeout(timeout); break;
        default:       response = await http.get(uri, headers: headers).timeout(timeout);
      }
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> _tryRefresh({bool adminAuth = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh == null) return;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final key = adminAuth ? 'admin_token' : 'auth_token';
        await prefs.setString(key, data['token']);
      }
    } catch (_) {}
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _request('POST', '/auth/login', body: {'email': email, 'password': password});
    if (res['success'] == true) {
      await saveToken(res['token'], refresh: res['refresh']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(res['user']));
    }
    return res;
  }

  static Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    final res = await _request('POST', '/auth/register', body: {'name': name, 'email': email, 'phone': phone, 'password': password});
    if (res['success'] == true) {
      await saveToken(res['token'], refresh: res['refresh']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(res['user']));
    }
    return res;
  }

  // Sends a 4-digit password-reset code to the given email via Mailgun.
  static Future<Map<String, dynamic>> forgotPassword(String email) async =>
      _request('POST', '/auth/forgot-password', body: {'email': email});

  // Verifies a password-reset code without consuming it.
  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async =>
      _request('POST', '/auth/verify-reset-code', body: {'email': email, 'code': code});

  // Verifies the code again and sets a new password.
  static Future<Map<String, dynamic>> resetPassword(String email, String code, String password) async =>
      _request('POST', '/auth/reset-password', body: {'email': email, 'code': code, 'password': password});

  static Future<void> logout() async => clearToken();

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('user');
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // ── Products ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProducts({int page = 1, int limit = 20, String? search, String? categoryId, String? vendorId, bool? featured, bool? isNewArrival, bool? isWeeklyOffer, String? sortBy}) async {
    var path = '/products?page=$page&limit=$limit&status=active';
    if (search != null) path += '&search=$search';
    if (categoryId != null) path += '&category_id=$categoryId';
    if (vendorId != null) path += '&vendor_id=$vendorId';
    if (featured == true) path += '&featured=true';
    if (isNewArrival == true) path += '&is_new_arrival=true';
    if (isWeeklyOffer == true) path += '&is_weekly_offer=true';
    if (sortBy != null) path += '&sort_by=$sortBy';
    return _request('GET', path);
  }

  static Future<Map<String, dynamic>> getProduct(int id) async => _request('GET', '/products/$id');

  // ── Coupons ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCoupons({int page = 1, int limit = 20, String? vendorId, bool? featured}) async {
    var path = '/coupons?page=$page&limit=$limit&status=active';
    if (vendorId != null) path += '&vendor_id=$vendorId';
    if (featured == true) path += '&featured=true';
    return _request('GET', path);
  }

  static Future<Map<String, dynamic>> getCoupon(int id) async => _request('GET', '/coupons/$id');

  // ── Ads ───────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAds() async => _request('GET', '/ads');

  // ── Discount coupon validation ────────────────────────────────────────────
  static Future<Map<String, dynamic>> validateDiscountCode(String code) async =>
      _request('GET', '/discount-coupons/validate/$code');

  // ── Orders ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String deliveryMethod = 'address',
    String? discountCode,
    String? address,
  }) async {
    return _request('POST', '/orders', auth: true, body: {
      'items': items,
      'payment_method': paymentMethod,
      'delivery_method': deliveryMethod,
      if (discountCode != null) 'discount_code': discountCode,
      if (address != null) 'address': address,
    });
  }

  static Future<Map<String, dynamic>> createGuestOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String deliveryMethod = 'address',
    String? name,
    String? phone,
    String? address,
    String? discountCode,
  }) async {
    return _request('POST', '/orders/guest', body: {
      'items': items,
      'payment_method': paymentMethod,
      'delivery_method': deliveryMethod,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (discountCode != null) 'discount_code': discountCode,
    });
  }

  static Future<Map<String, dynamic>> getMyOrders({int page = 1, String? paymentStatus}) async {
    var path = '/orders/my?page=$page';
    if (paymentStatus != null) path += '&payment_status=$paymentStatus';
    return _request('GET', path, auth: true);
  }

  // ── QR scan (admin) ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> scanQR(String qrCode) async =>
      _request('POST', '/qr/scan', adminAuth: true, body: {'qr_code': qrCode});

  static Future<Map<String, dynamic>> getQRHistory({String? status}) async {
    var path = '/qr/history?limit=100';
    if (status != null) path += '&status=$status';
    return _request('GET', path, adminAuth: true);
  }

  // ── App settings ──────────────────────────────────────────────────────────

  // Categories
  static Future<Map<String, dynamic>> getCategories() async => _request('GET', '/categories');

  // Banners
  static Future<Map<String, dynamic>> getBanners() async => _request('GET', '/banners');

  // Search
  static Future<Map<String, dynamic>> search(String query) async =>
      _request('GET', '/products?search=\${Uri.encodeComponent(query)}&limit=30');

  // Get fresh profile (includes saved address)
  static Future<Map<String, dynamic>> getProfile() async => _request('GET', '/auth/me', auth: true);

  // Update profile
  static Future<Map<String, dynamic>> updateProfile({String? name, String? phone, String? address}) async =>
      _request('PUT', '/auth/me', auth: true, body: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      });

  // Upload / change profile avatar
  static Future<Map<String, dynamic>> uploadAvatar(File file) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/auth/me/avatar');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('avatar', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    final res = jsonDecode(response.body) as Map<String, dynamic>;

    if (res['success'] == true && res['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(res['user']));
    }
    return res;
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async =>
      _request('POST', '/auth/change-password', auth: true, body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });

  static Future<Map<String, dynamic>> getSettings() async => _request('GET', '/settings/public');

  // ── CMS pages ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCmsPage(String slug) async => _request('GET', '/cms/$slug');

  // ── Push notifications ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> registerDeviceToken(String token, {String? platform}) async {
    final loggedIn = await isLoggedIn();
    return _request('POST', '/notifications/register-token', auth: loggedIn, body: {
      'token': token,
      if (platform != null) 'platform': platform,
    });
  }

  // ── Admin auth ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final res = await _request('POST', '/auth/admin/login', body: {'email': email, 'password': password});
    if (res['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', res['token']);
      await prefs.setString('refresh_token', res['refresh'] ?? '');
    }
    return res;
  }
}
