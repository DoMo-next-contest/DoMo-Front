// lib/services/auth_service.dart

import 'dart:convert';           // ← add this
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';


/// Thrown when login or signup fails.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

/// Holds the two tokens returned in response headers.
class LoginResponse {
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });
}

/// A simple authentication service that handles login API calls.
class AuthService {
  /// Base URL for your real backend.
  final String baseUrl;

  AuthService({
    this.baseUrl = 'http://ec2-15-165-74-79.ap-northeast-2.compute.amazonaws.com:8080',
  });

  /// Calls POST /api/user/login with { loginId, password } and
  /// reads the tokens out of the response headers.
  Future<LoginResponse> login(String loginId, String password) async {
    final uri = Uri.parse('$baseUrl/api/user/login');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loginId': loginId,
        'password': password,
      }),
    );

    if (resp.statusCode != 200) {
      throw AuthException('Login failed (${resp.statusCode}): ${resp.body}');
    }

    final accessToken  = resp.headers['authorization'];
    final refreshToken = resp.headers['authorization-refresh'];

    if (accessToken != null) {
      final storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: accessToken);
      debugPrint('🔐 Saved access token from header');
    } else {
      debugPrint('⚠️ No token found in header');
    }

    if (accessToken == null) {
      throw AuthException('No access token returned');
    }

    return LoginResponse(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );
  }
}
