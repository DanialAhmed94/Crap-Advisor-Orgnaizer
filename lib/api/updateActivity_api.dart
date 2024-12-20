import 'dart:async';
import 'dart:convert';
import 'dart:io';  // Import for SocketException
import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/kidsManagement_view/k=kidsManagement_homeView.dart';
import '../constants/AppConstants.dart';

Future<void> updateActivity(
    BuildContext context,
    String activityId,
    String festId,
    String title,
    String image,
    String content,
    String latitude,
    String longitude,
    String startTime,
    String endTime,
    ) async {
  final url = Uri.parse("${AppConstants.baseUrl}/update_activity/$activityId");

  final Map<String, dynamic> activityData = {
    "festival_id": festId,
    "activity_title": title,
    "image": image,
    "description": content,
    "latitude": latitude,
    "longitude": longitude,
    "start_time": startTime,
    "end_time": endTime,
  };

  try {
    final bearerToken = await getToken();
    final response = await http
        .post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(activityData),
    )
        .timeout(const Duration(seconds: 30));
print("token $bearerToken");
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      showSuccessDialog(
        context,
        "Activity updated successfully",
        null,
        AddKidsActivityHome(),
      );
    } else if (response.statusCode == 400) {
      // Validation errors
      final responseData = jsonDecode(response.body);
      showErrorDialog(
        context,
        responseData['message'] ?? "Validation Error",
        responseData['errors'] ?? [],
      );
    } else {
      // Other unexpected status codes
      showErrorDialog(
        context,
        "Unexpected error",
        ["An unexpected error occurred. Please try again later."],
      );
    }
  } on TimeoutException {
    showErrorDialog(
      context,
      "Request timed out. Please try again later.",
      [],
    );
  } on SocketException {
    // Handle Internet connection issues
    showErrorDialog(
      context,
      "No Internet Connection",
      ["Please check your internet connection and try again."],
    );
  } catch (error) {
    // Generic exception handling
    showErrorDialog(
      context,
      "Activity was not updated. Operation failed with: $error",
      [],
    );
    print("error: $error");
  }
}
