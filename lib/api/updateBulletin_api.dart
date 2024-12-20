import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/new_bullitin_managment/newBulletin_managmentView.dart';
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart';

Future<void> updateBulletin(
    BuildContext context,
    String bulletinId,
    String title,
    String content,
    bool publishNow,
    String time,
    String date,
    ) async {
  String choice = publishNow ? "1" : "0"; // Determine publish choice
  final url = Uri.parse("${AppConstants.baseUrl}/update_bulletin/$bulletinId");

  Map<String, dynamic> bulletin = {
    'title': title,
    'content': content,
    'publish_now': choice,
    'date': date,
    'time': time,
  };

  try {
    final bearerToken = await getToken(); // Fetch the bearer token

    final response = await http
        .post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(bulletin),
    )
        .timeout(Duration(seconds: 30));

    print('Bulletin Update Payload: $bulletin');
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        // Match exact messages for success scenarios
        String? message = responseData['message'];

        if (message == "Bulletin Updated Successfully") {
          showSuccessDialog(
            context,
            "Bulletin Updated Successfully",
            null,
            AddNewsBullitinHome(),
          );
        } else {
          showErrorDialog(context, message ?? "Unknown error occurred.", []);
        }
      } else {
        // Handle error responses
        showErrorDialog(
            context, responseData['message'], responseData['errors']);
      }
    } else {
      showErrorDialog(context, "Error: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on SocketException catch (_) {
    showErrorDialog(
        context,
        "No internet connection. Please check your network settings and try again.",
        []);
  } catch (error) {
    print("Error: $error"); // Debugging error
    showErrorDialog(
        context, "Bulletin was not updated. Operation failed with: $error", []);
  }
}
