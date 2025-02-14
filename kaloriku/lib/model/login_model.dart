/// DIGUNAKAN UNTUK FORM LOGIN
class LoginInput {
  final String username;
  final String password;

  LoginInput({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
      };
}

/// DIGUNAKAN UNTUK RESPONSE
class LoginResponse {
  final String? token;
  final String message;
  final int status;
  final String role;
  final String fullname;
  final String phone;

  LoginResponse({
    this.token,
    required this.message,
    required this.status,
    required this.role,
    required this.fullname,
    required this.phone,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json["token"],
        message: json["message"],
        status: json["status"],
        role: json["role"],
        fullname: json["fullname"],
        phone: json["phone"],
      );
}