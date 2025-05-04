import 'dart:convert';
import 'package:http/http.dart' as http;

/// A simple authentication service that handles login API calls.
class AuthService {
  /// Base URL for production vs. test.
  final String baseUrl;
  final bool useHttpbin;

  /// By default uses reqres; if [useHttpbin] is true, sends to httpbin.org/post.
  AuthService({
    this.baseUrl = 'https://reqres.in/api',
    this.useHttpbin = true,
  });

  /// Attempts to log in with [id] and [password].
  Future<LoginResponse> login(String id, String password) async {
    final uri = useHttpbin
        ? Uri.parse('https://httpbin.org/post')
        : Uri.parse('$baseUrl/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'password': password}),
    );

    if (useHttpbin) {
      // httpbin always returns 200, echoing your JSON under "json"
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final echoed = body['json'] as Map<String, dynamic>?;

      if (echoed == null) {
        throw AuthException('Invalid echo from httpbin');
      }
      // for test, treat echo.id and echo.password as “token”
      return LoginResponse(token: 'echoed:${echoed['id']}');
    }

    // real backend behavior (reqres)
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return LoginResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      throw AuthException('Invalid credentials');
    } else {
      throw AuthException('Login failed: ${response.statusCode}');
    }
  }
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

/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}
