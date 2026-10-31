import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://back.sherykids.com/api/v1';
  static const String storageUrl = 'https://back.sherykids.com';

  static String absoluteImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$storageUrl$path';
  }

  // ── Place a guest order ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createGuestOrder({
    required String name,
    required String phone,
    String email = '',
    String address = 'Kuwait',
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFees,
    required double total,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/guest-orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'items': items,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'discount': 0,
        'delivery_fees': deliveryFees,
        'total': total,
      }),
    );
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Order failed');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Fetch all coupons ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchCoupons() async {
    final response = await http.get(Uri.parse('$baseUrl/coupons'));
    if (response.statusCode >= 400) throw Exception('Failed to load coupons');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data['rows'] is List) {
      return List<Map<String, dynamic>>.from(data['rows'] as List);
    }
    return [];
  }
}
