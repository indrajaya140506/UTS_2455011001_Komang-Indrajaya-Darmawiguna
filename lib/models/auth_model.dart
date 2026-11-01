class AuthModel {
  final String userId;
  final String? email;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const AuthModel({
    required this.userId,
    this.email,
    this.createdAt,
    this.lastSignInAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['id']?.toString() ?? '',
      email: json['email'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.tryParse(json['last_sign_in_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
    };
  }
}
