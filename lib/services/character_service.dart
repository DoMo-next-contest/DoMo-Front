import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CharacterService {
  static const _baseUrl = 'http://ec2-15-165-74-79.ap-northeast-2.compute.amazonaws.com:8080';
  static final _storage = FlutterSecureStorage();

  /// Fetches your GLB URL, with debug logging & flexible JSON parsing.
  static Future<String> fetchModelUrl() async {
    final token = await _storage.read(key: 'accessToken');
    debugPrint('🔑 Stored accessToken: $token');
    if (token == null) {
      throw Exception('No access token; please log in.');
    }

    final uri = Uri.parse('$_baseUrl/api/items/1');
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
      throw Exception('Failed to fetch model URL (${resp.statusCode})');
    }

    final dynamic json = jsonDecode(resp.body);
    debugPrint('📦 Parsed JSON: $json');

    String? url;
    if (json is List && json.isNotEmpty) {
      url = (json[0]['itemImageUrl'] ?? json[0]['imageUrl']) as String?;
    } else if (json is Map) {
      url = (json['itemImageUrl'] ?? json['imageUrl']) as String?;
    }

    if (url == null) {
      throw Exception('No `itemImageUrl` or `imageUrl` field found.');
    }

    debugPrint('✅ Resolved model URL: $url');
    return url;
  }
}
