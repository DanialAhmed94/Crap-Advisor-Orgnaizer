import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For handling SocketException

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../bottom_navigation_bar/navigation_home_view/festival_managment/festival_managment_homeView.dart';
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart';

Future<void> updateFestival(
    BuildContext context,
    String festivalId,
    String name,
    String image,
    String lat,
    String long,
    String startDate,
    String endDate,
    String description) async {
  final url = Uri.parse("${AppConstants.baseUrl}/update_festivals/$festivalId");

  final Map<String, dynamic> festival = {
    'ending_date': endDate,
    'starting_date': startDate,
    'longitude': long,
    'latitude': lat,
    'image': image,
    'description': "N/A",
    'description_organizer': description,
    'name_organizer': name,
  };

  try {
    final bearerToken = await getToken();
    final response = await http
        .post(
      url, // or .put if your API expects a PUT request for updates
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(festival),
    )
        .timeout(const Duration(seconds: 30));

    Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['Message'] != null &&
          responseData['Message'].contains(
              '"You have consumed your limit of a Standard Account! Please buy a Premium Account to proceed further."')) {
        showSuccessDialog(
            context,
            "You have consumed your limit of a Standard Account! Please buy a Premium Account to proceed further.",
            "Failure",
            AddFestivalHome());
      } else  {
        showSuccessDialog(
            context, "Festival updated successfully", null, AddFestivalHome());
        print('Festival updated successfully!');
      }
    } else {
      // Server-side validation or other errors
      showErrorDialog(context, responseData['message'], responseData['errors']);
    }
  } on SocketException {
    // Handle no internet connection
    showErrorDialog(context, "No internet connection. Please check your network and try again.", []);
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
  }on TimeoutException {
    // Handle request timeout
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    // Handle other errors
    showErrorDialog(
        context, "Festival was not updated. Operation failed with: $error", []);
    print("error: $error");
  }
}
