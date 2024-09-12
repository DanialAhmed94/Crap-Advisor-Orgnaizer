import 'festivalCollection_model.dart';

class ToiletResponse {
  int status;
  List<ToiletData> data;
  String message;

  ToiletResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ToiletResponse.fromJson(Map<String, dynamic> json) {
    return ToiletResponse(
      status: json['status'],
      data: List<ToiletData>.from(json['data'].map((x) => ToiletData.fromJson(x))),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'message': message,
    };
  }
}

class ToiletData {
  int id;
  int userId;
  int festivalId;
  int toiletTypeId;
  String latitude;
  String longitude;
  String? what3Words;
  String image;
  String createdAt;
  String updatedAt;
  Festival festival; // Assuming you already have the Festival model

  ToiletData({
    required this.id,
    required this.userId,
    required this.festivalId,
    required this.toiletTypeId,
    required this.latitude,
    required this.longitude,
    this.what3Words,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.festival,
  });

  factory ToiletData.fromJson(Map<String, dynamic> json) {
    return ToiletData(
      id: json['id'],
      userId: json['user_id'],
      festivalId: json['festival_id'],
      toiletTypeId: json['toilet_type_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      what3Words: json['what_3_words'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      festival: Festival.fromJson(json['festival']), // Reference existing model
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'festival_id': festivalId,
      'toilet_type_id': toiletTypeId,
      'latitude': latitude,
      'longitude': longitude,
      'what_3_words': what3Words,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'festival': festival.toJson(), // Reference existing model's toJson()
    };
  }
}
