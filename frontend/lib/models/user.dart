class User {
  final int? userID;
  final String name;
  final String email;
  final String role;

  const User({
    this.userID,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}