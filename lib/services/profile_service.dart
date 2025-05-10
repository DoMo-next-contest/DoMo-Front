// lib/services/profile_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:domo/models/profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ProfileService {
  /// Point at your real backend.
  final String baseUrl;

  ProfileService({
    this.baseUrl = 'http://ec2-15-165-74-79.ap-northeast-2.compute.amazonaws.com:8080',
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

Future<Profile> createProfile({
  required String name,
  required String username,
  required String email,
  required String password,
}) async {
  final uri = Uri.parse('$baseUrl/api/user/signup');

  final payload = {
    'loginId': username,
    'password': password,
    'name': name,
    'email': email,
  };

  final resp = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(payload),
  );

  debugPrint('📥 Signup response: ${resp.statusCode} ${resp.body}');

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    // ✅ Get access token from response header
    final token = resp.headers['authorization'];
    if (token != null) {
      final storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: token);
      debugPrint('🔐 Saved access token from header');
    } else {
      debugPrint('⚠️ No token found in header');
    }

    // Since response body is plain text, return dummy Profile
    return Profile(
      id: '', // No ID returned yet
      name: name,
      username: username,
      email: email,
    );
  }

  throw Exception('회원가입 실패: ${resp.body}');
}



Future<void> submitOnboardingPreferences({
  required String detailPreference,
  required String workPace,
  required List<String> interestedTags,
}) async {
  final uri = Uri.parse('$baseUrl/api/user/onboarding');

  final payload = {
    'detailPreference': detailPreference,
    'workPace': workPace,
    'interestedTags': interestedTags,
  };

  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'accessToken');

  if (token == null) {
    throw Exception('❌ No access token found');
  }

  final resp = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ✅ Send token here
    },
    body: jsonEncode(payload),
  );

  debugPrint('📤 Onboarding payload: $payload');
  debugPrint('📥 Response: ${resp.statusCode} ${resp.body}');

  if (resp.statusCode != 200) {
    throw Exception('Onboarding failed: ${resp.body}');
  }
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


