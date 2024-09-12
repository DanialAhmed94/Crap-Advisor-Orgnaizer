import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/AppConstants.dart';
import '../data_model/activityCollection_model.dart';
import '../data_model/bulletinCollection_model.dart';
import '../data_model/performanceCollection_model.dart';
import '../utilities/utilities.dart';

Future<ActivityResponse?> getActivitiesCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/activity");
  try {
    final bearerToken = await getToken(); // Fetch the bearer token
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decode the JSON response
      return ActivityResponse.fromJson(data); // Return the ApiResponse object
    } else {
      final data = json.decode(response.body); // Decode error response
      showErrorDialog(
          context, data['message'], data['errors']); // Show error dialog
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Operation failed with: $error", []);
    print("error: $error"); // Print the error for debugging
  }
  return null;
}
