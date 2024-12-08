
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart'; // getToken, showErrorDialog, etc.

Future<bool> deleteSelectedFestival(BuildContext context, String festivalId) async {

  final url = Uri.parse("${AppConstants.baseUrl}/delete_festivals/$festivalId");

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
        data['message'] ?? "An error occurred while deleting the user.",
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
      "Operation failed while deleting user: $error",
      [],
    );
    print("Error deleting user: $error"); // Debugging log
  }

  return false;
}
