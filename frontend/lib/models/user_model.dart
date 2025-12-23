class UserModel {
  final String? id;
  final String email;
  final String username;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String sex; // 'Male', 'Female'
  final int targetSteps;
  final String? photoUrl;

  UserModel({
    this.id,
    required this.email,
    required this.username,
    required this.age,
    required this.weight,
    required this.height,
    required this.sex,
    this.targetSteps = 10000,
    this.photoUrl,
  });

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'username': username,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': sex, // Backend uses 'gender' not 'sex'
      'targetSteps': targetSteps,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  /// Create from JSON (backend response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      email: json['email'] ?? '',
      username: json['username'] ?? 'User',
      age: json['age'] ?? 25,
      weight: (json['weight'] ?? 70).toDouble(),
      height: (json['height'] ?? 170).toDouble(),
      sex: json['gender'] ?? json['sex'] ?? 'Male', // Handle both field names
      targetSteps: json['targetSteps'] ?? 10000,
      photoUrl: json['photoUrl'],
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    int? age,
    double? weight,
    double? height,
    String? sex,
    int? targetSteps,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      sex: sex ?? this.sex,
      targetSteps: targetSteps ?? this.targetSteps,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}