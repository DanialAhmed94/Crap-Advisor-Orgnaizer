class ToiletTypeResponse {
  final String message;
  final List<ToiletType> data;

  ToiletTypeResponse({
    required this.message,
    required this.data,
  });

  // Factory method to create a ToiletTypeResponse from JSON
  factory ToiletTypeResponse.fromJson(Map<String, dynamic> json) {
    return ToiletTypeResponse(
      message: json['message'],
      data: List<ToiletType>.from(json['data'].map((item) => ToiletType.fromJson(item))),
    );
  }

  // Method to convert the ToiletTypeResponse object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': List<dynamic>.from(data.map((item) => item.toJson())),
    };
  }
}

class ToiletType {
  final int id;
  final String name;
  final String image;
  final String createdAt;
  final String updatedAt;

  ToiletType({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a ToiletType from JSON
  factory ToiletType.fromJson(Map<String, dynamic> json) {
    return ToiletType(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Method to convert the ToiletType object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
