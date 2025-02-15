import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Needed for SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

// Replace these with your actual imports
import '../constants/AppConstants.dart';
import '../data_model/responseCollectionModel.dart';
import '../utilities/utilities.dart';

Future<NotificationsResponse?> getNotifications(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/notifications");
  try {
    final bearerToken = await getToken(); // Method that fetches the bearer token
    final response = await http
        .get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      // Decode the JSON response
      final data = json.decode(response.body);

      // Return the NotificationsResponse object
      return NotificationsResponse.fromJson(data);
    } else {
      // Decode error response
      final data = json.decode(response.body);

      // Show error dialog if needed
      showErrorDialog(
        context,
        data['message'] ?? 'Unknown error',
        data['errors'] ?? [],
      );
    }
  } on SocketException catch (_) {
    // This handles the no-internet scenario
    showErrorDialog(
      context,
      "No internet connection. Please try again later.",
      [],
    );
  }on ClientException catch (e) {
    final errorString = e.toString(); // or e.message

    // Check if it contains "SocketException"
    if (errorString.contains('SocketException')) {
      // Handle the wrapped SocketException here
      showErrorDialog(
        context,
        "Network error: failed to reach server. Please check your connection.",
        [],
      );
    } else {
      // Otherwise handle any other client exception
      showErrorDialog(
        context,
        "A client error occurred: ${e.message}",
        [],
      );
    }
  } on TimeoutException catch (_) {
    showErrorDialog(
      context,
      "Request timed out. Please try again later.",
      [],
    );
  } catch (error) {
    showErrorDialog(
      context,
      "Failed while fetching notifications: $error",
      [],
    );
    debugPrint("Error: $error"); // Print the error for debugging
  }
  return null;
}
