// lib/services/profile_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:domo/models/profile.dart';

class ProfileService {
  /// Point at your real backend.
  final String baseUrl;

  ProfileService({
    this.baseUrl = 'http://ec2-3-38-104-110.ap-northeast-2.compute.amazonaws.com:8080',
  });

  /// Sign up a new user.
  ///
  /// Swagger spec wants exactly:
  /// {
  ///   "loginId": "...",
  ///   "password": "...",
  ///   "name": "...",
  ///   "email": "..."
  /// }
  Future<Profile> signUp({
    required String loginId,
    required String password,
    required String name,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/signup');
    final payload = {
      'loginId': loginId,
      'password': password,
      'name': name,
      'email': email,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('✅ Signup response: $data');

      // Assume the response JSON has the same shape as Profile.fromJson expects.
      // If it's nested, e.g. { "data": { … } }, adjust accordingly.
      return Profile.fromJson(data);
    }

    throw Exception(
      'Failed to sign up (status=${resp.statusCode}): ${resp.body}',
    );
  }

  /// Update an existing user profile.
  ///
  /// Example swagger might be PUT /api/user/{id}, adjust as needed.
  Future<Profile> updateProfile({
    required String id,
    String? subtaskPreference,
    String? timePreference,
    List<String>? categories,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/$id');
    final body = <String, dynamic>{};
    if (subtaskPreference != null) body['subtaskPreference'] = subtaskPreference;
    if (timePreference    != null) body['timePreference']    = timePreference;
    if (categories        != null) body['categories']        = categories;

    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      debugPrint('✅ Update response: $data');
      return Profile.fromJson(data);
    }

    throw Exception(
      'Failed to update profile (status=${resp.statusCode}): ${resp.body}',
    );
  }
}
