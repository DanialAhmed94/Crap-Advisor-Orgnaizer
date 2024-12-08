import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/stage_management_homeView.dart';
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart'; // Ensure this includes getToken, showSuccessDialog, showErrorDialog

Future<void> updatePerformance(
    BuildContext context,
    String performanceId, // Performance ID as a required parameter
    String? festId,
    String startDate,
    String endDate,
    String title,
    String band,
    String artist,
    String participants,
    String specialGuests,
    String startTime,
    String endTime,
    String lighting,
    String sound,
    String stageSetup,
    String transitionDetail,
    String specialNotes,
    String? event_id,
    ) async {
  // Define the API endpoint. Adjust if your API uses a different path or method.
  final url = Uri.parse("${AppConstants.baseUrl}/update_performance/$performanceId");

  // Construct the performance data payload
  final Map<String, dynamic> performance = {
    'festival_id': festId ?? "",
    'band_name': ".",
    'artist_name': artist,
    'technical_rquirement_special_notes': specialNotes,
    'participant_name': participants,
    'special_guests': specialGuests,
    'start_time': startTime,
    'end_time': endTime,
    'start_date': startDate,
    'end_date': endDate,
    'performance_title': title,
    'event_id': event_id,
  };

  try {
    // Retrieve the bearer token securely
    final bearerToken = await getToken();
    if (bearerToken == null || bearerToken.isEmpty) {
      showErrorDialog(context, "Authentication failed. Please log in again.", []);
      return;
    }

    print("Bearer Token: $bearerToken"); // Debugging token
    print("Performance Data: $performance"); // Debugging data

    // Make the PUT request with a timeout of 30 seconds
    final response = await http
        .post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(performance),
    )
        .timeout(Duration(seconds: 30));

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    // Parse the response
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        // Extract messages from the response
        String? message = responseData['Message'] ?? responseData['message'];


          // Success scenario
          showSuccessDialog(
            context,
            "Performance updated successfully!",
            null,
            AddPerformanceHome(), // Adjust the navigation target as needed
          );

      } else {
        // API returned a status other than 200
        String errorMessage = responseData['message'] ?? "Unknown error occurred.";
        List<dynamic> errors = responseData['errors'] ?? [];
        showErrorDialog(context, errorMessage, errors);
      }
    } else {
      // Handle non-200 HTTP responses
      String errorDetail = "Error: ${response.statusCode}";
      try {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        errorDetail += "\n${errorData['message'] ?? ''}";
      } catch (e) {
        // Response is not JSON
      }
      showErrorDialog(context, errorDetail, []);
    }
  } on SocketException {
    // Handles network connectivity issues
    showErrorDialog(context, "No Internet connection. Please check your network and try again.", []);
  } on TimeoutException {
    // Handles request timeout
    showErrorDialog(context, "The request timed out. Please try again later.", []);
  } on FormatException {
    // Handles invalid JSON format
    showErrorDialog(context, "Bad response format from server.", []);
  } catch (error) {
    // Handles any other exceptions
    print("Error: $error"); // Debugging error
    showErrorDialog(context, "An unexpected error occurred: $error", []);
  }
}
