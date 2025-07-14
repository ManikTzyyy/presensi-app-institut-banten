import 'dart:convert';

SavePresensiResponseModel savePresensiResponseModelFromJson(String str) =>
    SavePresensiResponseModel.fromJson(json.decode(str));

String savePresensiResponseModelToJson(SavePresensiResponseModel data) =>
    json.encode(data.toJson());

class SavePresensiResponseModel {
  bool success;
  String message;
  Data data;

  SavePresensiResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SavePresensiResponseModel.fromJson(Map<String, dynamic> json) =>
      SavePresensiResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : Data.empty(),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  int userId;
  String latitude;
  String longitude;
  DateTime tanggal;
  String masuk;
  dynamic pulang;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Data({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.tanggal,
    required this.masuk,
    required this.pulang,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Data.empty() => Data(
        userId: 0,
        latitude: '',
        longitude: '',
        tanggal: DateTime.now(),
        masuk: '',
        pulang: null,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        id: 0,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"] ?? 0,
        latitude: json["latitude"] ?? '',
        longitude: json["longitude"] ?? '',
        tanggal: json["tanggal"] != null
            ? DateTime.parse(json["tanggal"])
            : DateTime.now(),
        masuk: json["masuk"] ?? '',
        pulang: json["pulang"],
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        id: json["id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "latitude": latitude,
        "longitude": longitude,
        "tanggal":
            "${tanggal.year.toString().padLeft(4, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
        "masuk": masuk,
        "pulang": pulang,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "id": id,
      };
}
