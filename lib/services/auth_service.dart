// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

/// Model for the login response.
class LoginResponse {
  /// The authentication token returned by the server.
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(token: json['token'] as String);
  }
}

/// A simple authentication service that handles login API calls.
class AuthService {
  /// Base URL for your real backend
  final String baseUrl;

  AuthService({
    this.baseUrl = 'http://ec2-3-38-104-110.ap-northeast-2.compute.amazonaws.com:8080',
  });

  /// Attempts to log in with [loginId] and [password].
  ///
  /// Endpoint: POST /api/user/login
  Future<LoginResponse> login(String loginId, String password) async {
    final uri = Uri.parse('$baseUrl/api/user/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loginId': loginId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return LoginResponse.fromJson(data);
    }

    // 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException('Invalid login credentials');
    }

    // any other error
    throw AuthException(
      'Login failed (status=${response.statusCode}): ${response.body}',
    );
  }
}
