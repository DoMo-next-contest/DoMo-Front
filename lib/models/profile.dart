// lib/models/profile.dart

class Profile {
  final String id;
  final String name;
  final String username;
  final String email;

  /// New: how many coins the user has
  int coins;

  String? subtaskPreference;
  String? timePreference;
  List<String>? categories;

  Profile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.coins = 0,                  // ← default to zero
    this.subtaskPreference,
    this.timePreference,
    this.categories,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      coins: json['coins'] != null
          ? (json['coins'] as num).toInt()
          : 0,
      subtaskPreference: json['subtaskPreference'] as String?,
      timePreference: json['timePreference'] as String?,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'coins': coins,  // ← include coins
    };
    if (subtaskPreference != null) {
      data['subtaskPreference'] = subtaskPreference;
    }
    if (timePreference != null) {
      data['timePreference'] = timePreference;
    }
    if (categories != null) {
      data['categories'] = categories;
    }
    return data;
  }
}
