import 'dart:convert';

class RegisterResponseModel {
  final bool success;
  final String message;
  final RegisterData data;

  RegisterResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'],
      message: json['message'],
      data: RegisterData.fromJson(json['data']),
    );
  }
}

class RegisterData {
  final String token;
  final String name;
  final String email;

  RegisterData({
    required this.token,
    required this.name,
    required this.email,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      token: json['token'],
      name: json['name'],
      email: json['email'],
    );
  }
}
