class NotificationsResponse {
  final int status;
  final List<NotificationData> data;
  final String message;

  NotificationsResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  // Factory constructor to create an instance of NotificationsResponse from JSON
  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      status: json['status'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => NotificationData.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String,
    );
  }

  // Method to convert NotificationsResponse instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
    };
  }
}

class NotificationData {
  final int id;
  final String message;
  final String userId;
  final String createdAt;
  final String updatedAt;

  NotificationData({
    required this.id,
    required this.message,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create an instance of NotificationData from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as int,
      message: json['message'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  // Method to convert NotificationData instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
