// lib/services/profile_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:domo/models/profile.dart';

class ProfileService {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  const ProfileService({
    //this.baseUrl = 'http://ec2-15-165-74-79.ap-northeast-2.compute.amazonaws.com:8080',
    this.baseUrl = 'https://15.165.74.79.nip.io',
  });

  /// Helper to get a valid Bearer token header
  Future<String> _bearerToken() async {
    final raw = await _storage.read(key: 'accessToken');
    if (raw == null) throw Exception('No access token found. Please log in.');
    return raw.startsWith('Bearer ') ? raw : 'Bearer $raw';
  }

  /// Sign up a new user and store the returned JWT
  Future<Profile> createProfile({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/signup');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loginId': username,
        'password': password,
        'name': name,
        'email': email,
      }),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final token = resp.headers['authorization'];
      if (token != null) await _storage.write(key: 'accessToken', value: token);
      return Profile(
        id:       '',
        name:     name,
        username: username,
        email:    email,
      );
    }
    throw Exception('회원가입 실패 (${resp.statusCode}): ${resp.body}');
  }

  /// Log in an existing user, store JWT, and return their profile
  Future<Profile> login({
    required String loginId,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/login');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loginId': loginId,
        'password': password,
      }),
    );
    if (resp.statusCode == 200) {
      final token   = resp.headers['authorization'];
      final refresh = resp.headers['refresh'];
      if (token   != null) await _storage.write(key: 'accessToken', value: token);
      if (refresh != null) await _storage.write(key: 'refreshToken', value: refresh);
      return fetchProfile();
    }
    throw Exception('로그인 실패 (${resp.statusCode}): ${resp.body}');
  }

  /// GET /api/user/info
  Future<Profile> fetchProfile() async {
    final uri   = Uri.parse('$baseUrl/api/user/info');
    final token = await _bearerToken();

    final resp = await http.get(
      uri,
      headers: {
        'Authorization': token,
        'Accept':        'application/json',
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return Profile.fromJson(data);
    } else {
      throw Exception('프로필 로드 실패 (${resp.statusCode}): ${resp.body}');
    }
  }

  /// Retrieve the user’s current coin balance
  Future<int> fetchCoin() async {
    final token = await _bearerToken();
    final uri   = Uri.parse('$baseUrl/api/user/coin');
    final resp  = await http.get(uri, headers: {'Authorization': token});
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return (body['userCoin'] as num).toInt();
    }
    throw Exception('코인 조회 실패 (${resp.statusCode}): ${resp.body}');
  }

  /// Submit full onboarding preferences
  Future<void> submitOnboardingPreferences({
    required String detailPreference,
    required String workPace,
    required List<String> interestedTags,
  }) async {
    final token = await _bearerToken();
    final uri   = Uri.parse('$baseUrl/api/user/onboarding');
    final resp  = await http.post(
      uri,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'detailPreference': detailPreference,
        'workPace':         workPace,
        'interestedTags':   interestedTags,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('온보딩 제출 실패 (${resp.statusCode}): ${resp.body}');
    }
  }

  /// PATCH /api/user/detail-preference
  Future<void> updateDetailPreference(String detailPreference) async {
    final uri   = Uri.parse('$baseUrl/api/user/users/detail-preference');
    final token = await _bearerToken();
    final resp  = await http.patch(
      uri,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': token,
      },
      body: jsonEncode({'detailPreference': detailPreference}),
    );
    if (resp.statusCode != 200) {
      throw Exception('세분화 선호도 수정 실패 (${resp.statusCode}): ${resp.body}');
    }
  }

  /// PATCH /api/user/work-pace
  Future<void> updateTimePreference(String timePreference) async {
    final uri   = Uri.parse('$baseUrl/api/user/users/work-pace');
    final token = await _bearerToken();
    final resp  = await http.patch(
      uri,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': token,
      },
      body: jsonEncode({'workPace': timePreference}),
    );
    if (resp.statusCode != 200) {
      throw Exception('시간 선호도 수정 실패 (${resp.statusCode}): ${resp.body}');
    }
  }

  /// Change the user’s password
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await _bearerToken();
    final uri   = Uri.parse('$baseUrl/api/user/password');
    final resp  = await http.put(
      uri,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': token,
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

  /// Draw (get) a random item for the user
  Future<void> drawItem() async {
    final token = await _bearerToken();
    final uri   = Uri.parse('$baseUrl/api/user/draw');
    final resp  = await http.put(uri, headers: {'Authorization': token});
    if (resp.statusCode != 200) {
      throw Exception('아이템 뽑기 실패 (${resp.statusCode}): ${resp.body}');
    }
  }

  /// Upload a custom character file
  Future<void> uploadCharacterFile(File file) async {
    final token  = await _bearerToken();
    final uri    = Uri.parse('$baseUrl/api/user/character/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = token
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final resp = await request.send();
    if (resp.statusCode != 200) {
      throw Exception('캐릭터 업로드 실패 (${resp.statusCode})');
    }
  }

  /// Fetch the URL of the user’s current character file
  Future<String> fetchCharacterUrl() async {
    final token = await _bearerToken();
    final uri   = Uri.parse('$baseUrl/api/user/character/url');
    final resp  = await http.get(
      uri,
      headers: {'Authorization': token},
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['characterUrl'] as String;
    }
    throw Exception('캐릭터 URL 조회 실패 (${resp.statusCode}): ${resp.body}');
  }

  /// Delete (withdraw) the user’s account
  Future<void> deleteAccount() async {
    final token = await _bearerToken();
    final uri   = Uri.parse('$baseUrl/api/user/delete');
    final resp  = await http.delete(uri, headers: {'Authorization': token});
    if (resp.statusCode != 200) {
      throw Exception('회원탈퇴 실패 (${resp.statusCode}): ${resp.body}');
    }
  }
}
