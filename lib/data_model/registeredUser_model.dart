class RegisteredUsersResponse {
  final int? status;
  final List<RegisteredUser>? data;
  final String? message;

  RegisteredUsersResponse({
    this.status,
    this.data,
    this.message,
  });

  factory RegisteredUsersResponse.fromJson(Map<String, dynamic> json) {
    return RegisteredUsersResponse(
      status: json['status'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RegisteredUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class RegisteredUser {
  final int? id;
  final int? userId;
  final int? eventId;
  final int? eventOwnerId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? createdAt;
  final String? updatedAt;

  RegisteredUser({
    this.id,
    this.userId,
    this.eventId,
    this.eventOwnerId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      eventId: json['event_id'] as int?,
      eventOwnerId: json['event_owner_id'] as int?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      userPhone: json['user_phone'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'event_owner_id': eventOwnerId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
