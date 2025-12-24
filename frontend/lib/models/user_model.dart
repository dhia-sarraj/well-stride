class UserModel {
  final String id;
  final String username;
  final String? email; // Nullable since profile API doesn't return it
  final String? photoUrl;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final int goal; // Changed from targetSteps to goal
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.photoUrl,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.goal, // Now required with default in fromJson
    this.createdAt,
  });

  /// Create UserModel from API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Parsing UserModel from JSON: $json');

    return UserModel(
      id: json['user_id'] ?? json['userId'] ?? json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? 'User',
      email: json['email'],
      photoUrl: json['photo_url'] ?? json['photoUrl'],
      age: _parseInt(json['age']) ?? 18,
      gender: json['gender'] ?? 'Unknown',
      // Handle both height_cm and height field names, and string values
      height: _parseDouble(json['height_cm'] ?? json['height']) ?? 170.0,
      // Handle both weight_kg and weight field names, and string values
      weight: _parseDouble(json['weight_kg'] ?? json['weight']) ?? 70.0,
      goal: _parseInt(json['goal']) ?? 10000, // Changed from targetSteps
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
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
      'goal': goal, // Changed from targetSteps
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
    int? goal, // Changed from targetSteps
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
      goal: goal ?? this.goal, // Changed from targetSteps
      createdAt: createdAt ?? this.createdAt,
    );
  }
}