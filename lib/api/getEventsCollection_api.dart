import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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
    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity != ConnectivityResult.none;

    if (hasConnection) {
      final isInternetSlow = !(await _hasGoodConnection());
      if (isInternetSlow) {
        showErrorDialog(context, "Slow internet connection detected.", []);
      } else {
        showErrorDialog(context, "Server is taking too long to respond.", []);
      }
    } else {
      showErrorDialog(context, "No internet connection.", []);
    }
  } on SocketException catch (_) {
    showErrorDialog(context, "No Internet connection. Please check your network and try again.", []);

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
  }catch (error) {
    showErrorDialog(context, "Operation failed with while fetching events: $error", []); // Handle other errors
    print("error: $error"); // Print the error for debugging
  }
  return null;
}
Future<bool> _hasGoodConnection() async {
  try {
    final response = await http.get(
      Uri.parse('https://www.google.com'),
    ).timeout(Duration(seconds: 2));
    return true;
  } catch (_) {
    return false;
  }
}