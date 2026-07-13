import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kit_model.dart';
import '../services/local_storage.dart'; // Import your existing service

class KitRepository {
  static const String _baseUrl = 'https://talentokids.com/api/kits';

  static Future<List<KitModel>> getAllKits() async {
    // 1. Get the token from your existing service
    final token = await LocalStorage.getAccessToken();

    // 2. Add headers to the request
    final response = await http.get(
      Uri.parse('$_baseUrl/?size=3&sort=createdAt,desc'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map((json) => KitModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load kits: ${response.statusCode}');
    }
  }
}