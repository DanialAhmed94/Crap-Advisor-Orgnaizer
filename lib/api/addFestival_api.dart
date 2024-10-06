import 'dart:async';
import 'dart:convert';

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
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
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Festival was not added. Operation failed with: $error", []);
    print("error: $error");
  }
}
