import 'festivalCollection_model.dart';

class ActivityResponse {
  final int status;
  final List<Activity> data;
  final String message;

  ActivityResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      status: json['status'],
      data: (json['data'] as List).map((item) => Activity.fromJson(item)).toList(),
      message: json['message'],
    );
  }


}

class Activity {
  final int id;
  final int festivalId;
  final int userId;
  final String activityTitle;
  final String image;
  final String description;
  final String? latitude;
  final String? longitude;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Festival? festival;
  Activity({
    required this.id,
    required this.festivalId,
    required this.userId,
    required this.activityTitle,
    required this.image,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    required this.festival,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      festivalId: json['festival_id'],
      userId: json['user_id'],
      activityTitle: json['activity_title'],
      image: json['image'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      festival: json['festival'] != null
          ? Festival.fromJson(json['festival'])
          : null, // Parse festival using Festival model
    );
  }


}
