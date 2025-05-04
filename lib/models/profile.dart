// lib/models/profile.dart

class Profile {
  String id;
  String name;
  String username;
  String email;
  int coins;
  String? subtaskPreference;
  String? timePreference;
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
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      subtaskPreference: subtaskPreference ?? this.subtaskPreference,
      timePreference: timePreference ?? this.timePreference,
      categories: categories ?? this.categories,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      subtaskPreference: json['subtaskPreference'] as String?,
      timePreference: json['timePreference'] as String?,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'coins': coins,
    };
    if (subtaskPreference != null) map['subtaskPreference'] = subtaskPreference;
    if (timePreference    != null) map['timePreference']    = timePreference;
    if (categories        != null) map['categories']        = categories;
    return map;
  }

  @override
  String toString() {
    return 'Profile(id: $id, username: $username, coins: $coins)';
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
