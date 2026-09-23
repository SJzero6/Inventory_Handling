class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String? email;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }
}
