import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart'; // Assume this contains getToken and showErrorDialog

Future<bool> deleteSelectedBulletin(BuildContext context, String bulletinId) async {
  final url = Uri.parse("${AppConstants.baseUrl}/delete_bulletin/$bulletinId");

  try {
    final bearerToken = await getToken(); // Fetch the bearer token
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));
print(" bulletin id $bulletinId");
    if (response.statusCode == 200 || response.statusCode == 204) {
      // Successfully deleted
      return true;
    } else {
      // Try to parse error message from the server
      final data = json.decode(response.body);
      showErrorDialog(
        context,
        data['message'] ?? "An error occurred while deleting the bulletin.",
        data['errors'] ?? [],
      );
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on SocketException catch (_) {
    showErrorDialog(context, "No internet connection. Please check your connection and try again.", []);
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
  } catch (error) {
    showErrorDialog(
      context,
      "Operation failed while deleting bulletin: $error",
      [],
    );
    print("Error deleting bulletin: $error"); // Debugging log
  }

  return false;
}
