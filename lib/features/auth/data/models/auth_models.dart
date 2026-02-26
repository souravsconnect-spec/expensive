class AuthResponseModel {
  final String status;
  final String? otp;
  final bool? userExists;
  final String? nickname;
  final String? token;
  final String? userId;

  AuthResponseModel({
    required this.status,
    this.otp,
    this.userExists,
    this.nickname,
    this.token,
    this.userId,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status'] ?? '',
      otp: json['otp'],
      userExists: json['user_exists'],
      nickname: json['nickname'],
      token: json['token'],
      userId: json['user_id'],
    );
  }
}

class CreateAccountResponseModel {
  final String status;
  final String token;
  final String? userId;

  CreateAccountResponseModel({
    required this.status,
    required this.token,
    this.userId,
  });

  factory CreateAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponseModel(
      status: json['status'] ?? '',
      token: json['token'] ?? '',
      userId: json['user_id'],
    );
  }
}
