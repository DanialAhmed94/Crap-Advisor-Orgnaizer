import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart';

Future<bool> deleteSelectedActivity(BuildContext context, String activityId) async {
  final url = Uri.parse("${AppConstants.baseUrl}/delete_activity/$activityId");

  try {
    final bearerToken = await getToken(); // Fetch the bearer token
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Successfully deleted
      return true;
    } else {
      // Try to parse error message from the server
      final data = json.decode(response.body);
      showErrorDialog(
        context,
        data['message'] ?? "An error occurred while deleting the activity.",
        data['errors'] ?? [],
      );
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on SocketException catch (_) {
    showErrorDialog(context, "No internet connection. Please check your connection and try again.", []);
  } catch (error) {
    showErrorDialog(
      context,
      "Operation failed while deleting activity: $error",
      [],
    );
    print("Error deleting activity: $error"); // Debugging log
  }

  return false;
}
