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
  /// 세분화 선호도만 PATCH
  Future<void> updateDetailPreference(String detailPreference) async {
    final uri = Uri.parse('$baseUrl/api/user/users/detail-preference');
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');

    final resp = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'detailPreference': detailPreference,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('세분화 선호도 수정 실패: ${resp.statusCode}');
    }
  }

  /// 시간 선호도만 PATCH
  Future<void> updateTimePreference(String timePreference) async {
    final uri = Uri.parse('$baseUrl/api/user/users/work-pace');
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token found');

    final resp = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'timePreference': timePreference,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('시간 선호도 수정 실패: ${resp.statusCode}');
    }
  }

  /*
  /// GET /api/user/users/me  (or whatever your “current user” endpoint is)
  Future<Profile> fetchProfile() async {
    final uri = Uri.parse('$baseUrl/api/user/users/me');
    final storage = FlutterSecureStorage();
    final token   = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('No token');

    final resp = await http.get(
      uri,
      headers: { 'Authorization': 'Bearer $token' }
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Profile.fromJson(data);
    } else {
      throw Exception('Failed to load profile: ${resp.statusCode}');
    }
  }
  */

  /// 비밀번호 변경
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/password');
    final storage = FlutterSecureStorage();
    final token   = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token');

    final resp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('비밀번호 변경 실패 (${resp.statusCode}): ${resp.body}');
    }
  }

  Future<Profile> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Profile(
      id: '315',
      name: '이지완',
      username: 'jiyaa',
      email: 'jiyaa@korea.ac.kr',
      coins: 100,
      subtaskPreference: '보통으로',
      timePreference: '여유롭게',
    );
  }
}


