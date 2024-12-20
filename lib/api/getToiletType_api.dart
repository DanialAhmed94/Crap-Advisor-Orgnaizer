import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/AppConstants.dart';
import '../data_model/toiletTypeCollection_model.dart';
import '../utilities/utilities.dart'; // For getting token and error handling
Future<ToiletTypeResponse?> getToiletTypeCollection(BuildContext context) async {
  final url = Uri.parse(AppConstants.toiletTpeBaseUrl);
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final responseData = jsonDecode(response.body);
          return ToiletTypeResponse.fromJson(responseData);
        } catch (e) {
          showErrorDialog(context, "Failed to parse toilet types.", []);
        }
      } else {
        showErrorDialog(context, "Received empty response for toilet types.", []);
      }
    } else {
      print("Non-200 response for toilet types: ${response.body}");
      try {
        final responseData = jsonDecode(response.body);
        showErrorDialog(context, responseData['message'], responseData['errors']);
      } catch (e) {
        showErrorDialog(context, "Failed to parse error response for toilet types.", []);
      }
    }
  } on TimeoutException {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on SocketException {
    showErrorDialog(context, "No internet connection. Please check your network and try again.", []);
  } catch (error) {
    showErrorDialog(context, "Failed to load toilet types. Error", []);
    print("Error: $error");
  }
  return null;
}
// Future<ToiletTypeResponse?> getToiletTypeCollection(BuildContext context) async {
//   final url = Uri.parse("${AppConstants.toiletTpeBaseUrl}");
//
//   try {
//     final response = await http.get(
//       url,
//       headers: {
//
//         'Content-Type': 'application/json',
//       },
//     ).timeout(const Duration(seconds: 30)); // Set timeout to 30 seconds
//
//     // Decode the response body
//     Map<String, dynamic> responseData = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       // Success, return ToiletTypeResponse
//       return ToiletTypeResponse.fromJson(responseData);
//     } else {
//       // Server-side validation or other errors
//       showErrorDialog(context, responseData['message'], responseData['errors']);
//       return null;
//     }
//   } on TimeoutException catch (_) {
//     showErrorDialog(context, "Request timed out. Please try again later.", []);
//     return null;
//   } catch (error) {
//     showErrorDialog(context, "Failed to load toilet types. Error: $error", []);
//     print("Error: $error");
//     return null;
//   }
// }
