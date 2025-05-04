// lib/services/profile_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';    // for debugPrint
import 'package:http/http.dart' as http;
import 'package:domo/models/profile.dart';

/// A mock ProfileService that echoes payloads against httpbin.org
/// while also providing an updateProfile stub.
class ProfileService {
  /// Base URL for testing. Defaults to httpbin's echo endpoint.
  final String baseUrl;

  ProfileService({this.baseUrl = 'https://httpbin.org'});

  /// Creates a new profile by POSTing to httpbin.org/post,
  /// which echoes your JSON under the 'json' key.
  Future<Profile> createProfile({
    required String name,
    required String username,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/post');
    final payload = {
      'name': name,
      'username': username,
      'email': email,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('🌐 ECHOED CREATE PAYLOAD: ${data['json']}');

      // Return a dummy Profile so your UI flow continues
      return Profile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        username: username,
        email: email,
      );
    }

    throw Exception('Echo test failed: ${resp.statusCode}');
  }

  /// Updates an existing profile by POSTing to httpbin.org/post as well.
  /// In a real backend you'd PUT to /profiles/{id}; here we echo.
  Future<Profile> updateProfile({
    required String id,
    String? subtaskPreference,
    String? timePreference,
    List<String>? categories,
  }) async {
    final uri = Uri.parse('$baseUrl/post');
    final Map<String, dynamic> body = {'id': id};
    if (subtaskPreference != null) body['subtaskPreference'] = subtaskPreference;
    if (timePreference != null)     body['timePreference'] = timePreference;
    if (categories != null)         body['categories'] = categories;

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('🌐 ECHOED UPDATE PAYLOAD: ${data['json']}');

      // Return a new Profile instance with updated fields
      // In a real scenario, you would parse from server response.
      return Profile(
        id: id,
        name: data['json']['name'] ?? '',
        username: data['json']['username'] ?? '',
        email: data['json']['email'] ?? '',
        subtaskPreference: data['json']['subtaskPreference'] as String?,
        timePreference: data['json']['timePreference'] as String?,
        categories: data['json']['categories'] != null
            ? List<String>.from(data['json']['categories'] as List)
            : null,
      );
    }

    throw Exception('Echo update failed: ${resp.statusCode}');
  }
}
