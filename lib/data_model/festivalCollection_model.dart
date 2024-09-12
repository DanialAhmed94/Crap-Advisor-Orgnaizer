class FestivalResponse {
  final String message;
  final List<Festival> data;
  final int count;
  final int attendies;

  FestivalResponse({
    required this.message,
    required this.data,
    required this.count,
    required this.attendies,
  });

  factory FestivalResponse.fromJson(Map<String, dynamic> json) {
    return FestivalResponse(
      message: json['message'],
      data: List<Festival>.from(json['data'].map((festival) => Festival.fromJson(festival))),
      count: json['count'],
      attendies: json['attendies'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': List<dynamic>.from(data.map((festival) => festival.toJson())),
      'count': count,
      'attendies': attendies,
    };
  }
}

class Festival {
  final int id;
  final String? description;
  final String? descriptionOrganizer;
  final String? nameOrganizer;
  final String? image;
  final String? latitude;
  final String? longitude;
  final String? startingDate;
  final String? endingDate;
  final String? time;
  final String? price;
  final String createdAt;
  final String updatedAt;
  final int userId;

  Festival({
    required this.id,
    required this.description,
    required this.descriptionOrganizer,
    required this.nameOrganizer,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.startingDate,
    required this.endingDate,
    this.time,
    this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'],
      description: json['description'],
      descriptionOrganizer: json['description_organizer'],
      nameOrganizer: json['name_organizer'],
      image: json['image'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      startingDate: json['starting_date'],
      endingDate: json['ending_date'],
      time: json['time'],
      price: json['price'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'description_organizer': descriptionOrganizer,
      'name_organizer': nameOrganizer,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'starting_date': startingDate,
      'ending_date': endingDate,
      'time': time,
      'price': price,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
    };
  }
}
