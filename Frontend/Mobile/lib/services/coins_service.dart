import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/config/api_constants.dart';
import 'auth/auth_api_client.dart';

class CoinsService {
  final AuthApiClient _client;

  CoinsService({
    AuthApiClient? client,
  }) : _client = client ?? AuthApiClient();

  /// Returns the current coins balance for the child selected on the backend.
  ///
  /// Expected backend response:
  /// 10
  Future<int> getSelectedChildCoins() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.coins),
    );

    debugPrint(
      'GET COINS: ${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseCoins(response.body);
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'تعذر تحميل رصيد الكوينز: ${response.statusCode}',
      ),
    );
  }

  int _parseCoins(String responseBody) {
    final body = responseBody.trim();

    if (body.isEmpty) {
      return 0;
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is int) {
        return decoded;
      }

      if (decoded is num) {
        return decoded.toInt();
      }

      if (decoded is String) {
        return int.tryParse(decoded.trim()) ?? 0;
      }

      // Extra protection in case the backend later wraps the value.
      if (decoded is Map<String, dynamic>) {
        final value =
            decoded['coins'] ??
                decoded['totalCoins'] ??
                decoded['balance'];

        if (value is int) {
          return value;
        }

        if (value is num) {
          return value.toInt();
        }

        if (value is String) {
          return int.tryParse(value.trim()) ?? 0;
        }
      }
    } catch (_) {
      final directValue = int.tryParse(body);

      if (directValue != null) {
        return directValue;
      }
    }

    throw const FormatException(
      'صيغة رصيد الكوينز القادمة من الخادم غير صحيحة.',
    );
  }

  String _extractErrorMessage(
      String responseBody,
      String fallback,
      ) {
    final body = responseBody.trim();

    if (body.isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return (
            decoded['message'] ??
                decoded['error'] ??
                fallback
        ).toString();
      }

      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } catch (_) {
      return body;
    }

    return fallback;
  }
}
