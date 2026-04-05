class UserModel {
  final String id;
  final String username;
  final String password;
  final String companyCode;
  final String role;
  final bool isLoggedIn;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.companyCode,
    required this.role,
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'companyCode': companyCode,
    'role': role,
    'isLoggedIn': isLoggedIn,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    companyCode: json['companyCode'] as String,
    role: json['role'] as String,
    isLoggedIn: json['isLoggedIn'] as bool? ?? false,
  );
}
