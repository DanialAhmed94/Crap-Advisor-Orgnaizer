import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../constants/AppConstants.dart';
import '../data_model/registeredUser_model.dart';
import '../utilities/utilities.dart'; // Contains getToken and showErrorDialog

Future<RegisteredUsersResponse?> getRegisteredUsers(BuildContext context, String eventId) async {

  final url = Uri.parse("${AppConstants.baseUrl}/event-registration-list?event_id=$eventId");

  try {
    final bearerToken = await getToken(); // Fetch the bearer token
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decode the JSON response
      return RegisteredUsersResponse.fromJson(data); // Deserialize into your model
    } else {
      // If non-200 status, attempt to decode the error message
      final data = json.decode(response.body);
      showErrorDialog(
        context,
        data['message'] ?? "An error occurred",
        data['errors'] ?? [],
      );
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on SocketException catch (_) {
    showErrorDialog(context, "No internet connection. Please check your connection and try again.", []);
  } on ClientException catch (e) {
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
  }catch (error) {
    showErrorDialog(
      context,
      "Operation failed while fetching registered users: $error",
      [],
    );
    print("Error fetching registered users: $error"); // Debugging log
  }
  return null;
}
