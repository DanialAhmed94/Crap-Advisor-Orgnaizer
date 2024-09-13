import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/AppConstants.dart';
import '../data_model/eventColection_model.dart';
import '../utilities/utilities.dart'; // For showErrorDialog and other utilities

Future<EventResponse?> getEventsCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/events"); // Your API endpoint
  try {
    final bearerToken = await getToken(); // Fetch the bearer token
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 30)); // Set a timeout for the request

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decode the JSON response
      return EventResponse.fromJson(data); // Parse and return the EventResponse object
    } else {
      final data = json.decode(response.body); // Decode error response
      showErrorDialog(context, data['message'], data['errors']); // Show error dialog
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []); // Handle timeout
  } catch (error) {
    showErrorDialog(context, "Operation failed with while fetching events: $error", []); // Handle other errors
    print("error: $error"); // Print the error for debugging
  }
  return null;
}
