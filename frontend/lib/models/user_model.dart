class UserModel {
  final String id;
  final String username;
  final String? email; // Make email nullable since profile API doesn't return it
  final String? photoUrl;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final int? targetSteps;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.email, // Now nullable
    this.photoUrl,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.targetSteps,
    this.createdAt,
  });

  /// Create UserModel from API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Parsing UserModel from JSON: $json'); // Debug print

    return UserModel(
      id: json['userId'] ?? json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? 'User',
      email: json['email'], // Can be null
      photoUrl: json['photoUrl'],
      age: _parseInt(json['age']) ?? 18,
      gender: json['gender'] ?? 'Unknown',
      height: _parseDouble(json['height']) ?? 170.0,
      weight: _parseDouble(json['weight']) ?? 70.0,
      targetSteps: _parseInt(json['targetSteps']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  // Helper methods to safely parse numbers
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Convert to JSON (for updates / profile creation)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'photoUrl': photoUrl,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
    };
  }

  /// Copy with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
    int? targetSteps,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetSteps: targetSteps ?? this.targetSteps,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}