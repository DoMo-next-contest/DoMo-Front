// lib/models/profile.dart

class Profile {
  String id;
  String name;
  String username;
  String email;
  int coins;
  String? subtaskPreference; // user‐facing Korean label
  String? timePreference;    // user‐facing Korean label
  List<String>? categories;

  Profile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.coins = 0,
    this.subtaskPreference,
    this.timePreference,
    this.categories,
  });

  /// Create a new Profile with some fields replaced.
  Profile copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    int? coins,
    String? subtaskPreference,
    String? timePreference,
    List<String>? categories,
  }) {
    return Profile(
      id:                 id ?? this.id,
      name:               name ?? this.name,
      username:           username ?? this.username,
      email:              email ?? this.email,
      coins:              coins ?? this.coins,
      subtaskPreference:  subtaskPreference ?? this.subtaskPreference,
      timePreference:     timePreference  ?? this.timePreference,
      categories:         categories      ?? this.categories,
    );
  }

  /// Map JSON from `/api/user/info` → our fields
  factory Profile.fromJson(Map<String, dynamic> json) {
    // raw API codes:
    final rawDetail = json['detailPreference'] as String?;
    final rawPace   = json['workPace']         as String?;

    return Profile(
      id:                  (json['id'] ?? '').toString(),
      name:                (json['name'] ?? '').toString(),
      username:            (json['loginId'] ?? '').toString(),
      email:               (json['email'] ?? '').toString(),
      coins:               (json['userCoin'] as num?)?.toInt() ?? 0,
      subtaskPreference:   rawDetail == null
                               ? null
                               : _detailLabelFromApi(rawDetail),
      timePreference:      rawPace   == null
                               ? null
                               : _timeLabelFromApi(rawPace),
      categories:          (json['categories'] as List<dynamic>?)
                               ?.map((e) => e.toString())
                               .toList(),
    );
  }

  /// Helpers to translate API codes → Korean labels
  static String _detailLabelFromApi(String code) {
    switch (code) {
      case 'MANY_TASKS':   return '구체적으로';
      case 'BALANCED_TASKS': return '보통으로';
      case 'FEW_TASKS':    return '대략적으로';
      default:             return code;
    }
  }
  static String _timeLabelFromApi(String code) {
    switch (code) {
      case 'TIGHT':     return '타이트하게';
      case 'BALANCED':  return '적당하게';
      case 'RELAXED':   return '여유롭게';
      default:          return code;
    }
  }

  /// Convert back to JSON (e.g. for PUT) if needed
  Map<String, dynamic> toJson() {
    return {
      'id':                id,
      'loginId':           username,
      'name':              name,
      'email':             email,
      'userCoin':          coins,
      if (subtaskPreference != null)
        'detailPreference': _detailCodeForLabel(subtaskPreference!),
      if (timePreference    != null)
        'workPace':          _paceCodeForLabel(timePreference!),
      if (categories        != null)
        'categories':        categories,
    };
  }

  static String _detailCodeForLabel(String label) {
    switch (label) {
      case '구체적으로':   return 'MANY_TASKS';
      case '보통으로':     return 'BALANCED_TASKS';
      case '대략적으로':   return 'FEW_TASKS';
      default:             return label;
    }
  }
  static String _paceCodeForLabel(String label) {
    switch (label) {
      case '타이트하게':   return 'TIGHT';
      case '적당하게':     return 'BALANCED';
      case '여유롭게':     return 'RELAXED';
      default:             return label;
    }
  }

  @override
  String toString() {
    return 'Profile(id: $id, username: $username, coins: $coins, '
           'subtaskPreference: $subtaskPreference, timePreference: $timePreference)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
      other.id == id &&
      other.name == name &&
      other.username == username &&
      other.email == email &&
      other.coins == coins &&
      other.subtaskPreference == subtaskPreference &&
      other.timePreference == timePreference &&
      _listEquals(other.categories, categories);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      username.hashCode ^
      email.hashCode ^
      coins.hashCode ^
      (subtaskPreference?.hashCode ?? 0) ^
      (timePreference?.hashCode ?? 0) ^
      (categories == null ? 0 : _deepHash(categories!));
  }

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _deepHash(List<String> list) {
    return list.fold(0, (prev, elem) => prev ^ elem.hashCode);
  }
}
