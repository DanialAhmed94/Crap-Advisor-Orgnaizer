import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/Navigation_HomeView.dart';
import '../bottom_navigation_bar/navigation_home_view/festival_managment/festival_managment_homeView.dart';
import '../constants/AppConstants.dart';
import '../homw_view/home_view.dart';

Future<void> addFestival(
    BuildContext context,
    String name,
    String image,
    String lat,
    String long,
    String startDate,
    String endDate,
    String description) async {
  final url = Uri.parse("${AppConstants.baseUrl}/store_festivals");

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
          url,
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json', // Set the content type to JSON
          },
          body: jsonEncode(festival),
        )
        .timeout(const Duration(seconds: 30));
    Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['Message'] != null &&
          responseData['Message'].contains(
              '"You have comsumed your limit of an Standard Account! Please Buy Premium Account to Proceed Further')) {
        showSuccessDialog(
            context,
            "You have comsumed your limit of an Standard Account! Please Buy Premium Account to Proceed Further",
            "Failure",
            AddFestivalHome());
      } else if (responseData['message'] == 'Festival Created Successfully') {
        showSuccessDialog(
            context, "Festival added successfully", null, AddFestivalHome());
        print('Festival created successfully!');
      }
    } else {
      // Server-side validation or other errors
      showErrorDialog(context, responseData['message'], responseData['errors']);
    }
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
  }on SocketException catch (_) {
    showErrorDialog(context, "No Internet connection. Please check your network and try again.", []);

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
  }
  catch (error) {
    showErrorDialog(context, "Festival was not added. Operation failed with: $error", []);
    print("error: $error");
  }
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
