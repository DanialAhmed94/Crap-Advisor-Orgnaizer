import 'dart:async';
import 'dart:convert';

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/Navigation_HomeView.dart';
import '../bottom_navigation_bar/navigation_home_view/kidsManagement_view/k=kidsManagement_homeView.dart';
import '../constants/AppConstants.dart';
import '../homw_view/home_view.dart';

Future<void> addActivity(BuildContext context, String? festId, String title,
    String image, String content,String latitude, String longitude, String startTime, String endTime) async {
  final url = Uri.parse("${AppConstants.baseUrl}/store_activity");
  final Map<String, dynamic> activity = {
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
    print(" token $bearerToken  token end");
    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json', // Set the content type to JSON
          },
          body: jsonEncode(activity),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      // Parse the response
      final responseData = jsonDecode(response.body);
      showSuccessDialog(
          context, responseData['message'], null, AddKidsActivityHome());
    } else if (response.statusCode == 400) {
      // Handle validation errors
      final responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other status codes (e.g., 500)
      showErrorDialog(context, "Unexpected error",
          ["An unexpected error occurred. Please try again later."]);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(
        context, "Festival was not added. Operation failed with: $error", []);
    print("error: $error");
  }
}
