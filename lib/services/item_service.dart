// item_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:domo/models/item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles all item-related API calls: draw, equip, and fetch.
class ItemService {
  static const _baseUrl = 'https://15.165.74.79.nip.io';
  static final _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> drawItem() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token; please log in.');

    final uri = Uri.parse('$_baseUrl/api/user/draw');
    debugPrint('📡 PUT $uri');
    final resp = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final raw = utf8.decode(resp.bodyBytes);
    debugPrint('📨 ${resp.statusCode}: $raw');

    if (resp.statusCode != 200) {
      throw Exception(raw);
    }

    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) return data;
      throw Exception('Unexpected response: $raw');
    } catch (_) {
      throw Exception('Invalid JSON response: $raw');
    }
  }

  /// Equips the given itemId for the user.
  static Future<void> equipItem(int itemId) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token; please log in.');

    final uri = Uri.parse('$_baseUrl/api/user-items/$itemId');
    debugPrint('📡 POST $uri');
    final resp = await http.post(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    debugPrint('📨 ${resp.statusCode}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to equip item ($itemId): ${resp.statusCode}');
    }
  }

  /// Fetches the list of items the user owns.
  static Future<List<Item>> getUserItems() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token; please log in.');

    final uri = Uri.parse('$_baseUrl/api/user-items/store');
    debugPrint('📡 GET $uri');
    final resp = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    debugPrint('📨 ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch user items (${resp.statusCode})');
    }
    final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
    return data.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns only the IDs of the items the user owns.
  static Future<Set<int>> getOwnedItemIds() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token; please log in.');
    
    final uri  = Uri.parse('$_baseUrl/api/user-items/store');
    debugPrint('📡 GET $uri');
    final resp = await http.get(
      uri,
      headers: {
        'Accept':        'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint('📨 ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch user-items (${resp.statusCode})');
    }
    
    final List<dynamic> list = jsonDecode(resp.body) as List<dynamic>;
    // filter only those with hasItem == true
    return list
      .where((e) => e['hasItem'] == true)
      .map((e) => e['id'] as int)
      .toSet();
  }

  /// Fetches all available items.
  static Future<List<Item>> getAllItems() async {
    final token = await _storage.read(key: 'accessToken');
    final uri = Uri.parse('$_baseUrl/api/items');
    debugPrint('📡 GET $uri');
    final resp = await http.get(uri, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    debugPrint('📨 ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch all items (${resp.statusCode})');
    }
    final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
    return data.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches detail for a specific item by its ID.
  static Future<Item> getItemById(int id) async {
    final token = await _storage.read(key: 'accessToken');
    final uri = Uri.parse('$_baseUrl/api/items/$id');
    debugPrint('📡 GET $uri');
    final resp = await http.get(uri, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    debugPrint('📨 ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch item $id (${resp.statusCode})');
    }
    return Item.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  /// 유저 보유 코인 조회
  static Future<int> getUserCoins() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception('No access token; please log in.');

    final uri = Uri.parse('$_baseUrl/api/user/coin');
    debugPrint('📡 GET $uri');
    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint('📨 Response ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch coin (${resp.statusCode})');
    }

    // 서버가 단순 정수(예: 120)로 응답하므로, jsonDecode 없이 직접 파싱해도 됩니다.
    return int.tryParse(resp.body) ?? 0;
  }

  static Future<Item> fetchRecentEquippedItem() async {
  final token = await _storage.read(key: 'accessToken');
  if (token == null) throw Exception('Not logged in');

  final uri = Uri.parse('$_baseUrl/api/user-items/recent');
  final resp = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch recent item: ${resp.body}');
  }

  final data = jsonDecode(utf8.decode(resp.bodyBytes));
  return Item.fromJson(data); // ✅ Your existing model handles this
}

}
