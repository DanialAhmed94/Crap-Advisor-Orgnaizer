import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  }on SocketException catch (_) {
    showErrorDialog(context, "No Internet connection. Please check your network and try again.", []);

  }on TimeoutException catch (_) {
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
  } catch (error) {
    showErrorDialog(context, "Operation failed with while fetching activities: $error", []);
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