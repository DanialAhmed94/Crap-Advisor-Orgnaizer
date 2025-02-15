import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../constants/AppConstants.dart';
import '../data_model/toiletCollection_model.dart';
import '../utilities/utilities.dart'; // Assuming you have a utility for token and showing dialogs
Future<ToiletResponse?> getToiletCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/toilets");
  try {
    final bearerToken = await getToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          return ToiletResponse.fromJson(data);
        } catch (e) {
          showErrorDialog(context, "Failed to parse response from server.", []);
        }
      } else {
        showErrorDialog(context, "Received empty response from server.", []);
      }
    } else {
      // Handle non-200 responses
      print("Non-200 response: ${response.body}");
      try {
        final data = json.decode(response.body);
        showErrorDialog(context, data['message'] ?? "Unknown error", data['errors'] ?? []);
      } catch (e) {
        showErrorDialog(context, "Failed to parse error response.", []);
      }
    }
  }
  on TimeoutException catch (_) {
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
  }
  on TimeoutException {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Operation failed while fetching toilets", []);
    print("Error: $error");
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
