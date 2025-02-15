import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
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
    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity != ConnectivityResult.none;

    if (hasConnection) {
      final isInternetSlow = !(await _hasGoodConnection());
      if (isInternetSlow) {
        showErrorDialog(context, "Slow internet connection detected. Try again?", []);
      } else {
        showErrorDialog(context, "Server is taking too long to respond.", []);
      }
    } else {
      showErrorDialog(context, "No internet connection.", []);
    }
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
      "Operation failed while deleting activity: $error",
      [],
    );
    print("Error deleting activity: $error"); // Debugging log
  }

  return false;
}
Future<bool> _hasGoodConnection() async {
  try {
    final response = await http
        .get(
      Uri.parse('https://www.google.com'),
    )
        .timeout(Duration(seconds: 2));
    return true;
  } catch (_) {
    return false;
  }
}
