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

Future<void> addToilet(BuildContext context, String? festId,
    String? toiletTypeId, String lat, String long, String image, String name) async {
  final url = Uri.parse("${AppConstants.baseUrl}/store_toilets");

  final Map<String, dynamic> toilet = {
    'festival_id': festId,
    'toilet_type_id': toiletTypeId,
    'latitude': lat,
    'longitude': long,
    'image': image,
    'what_3_words': name,
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
          body: jsonEncode(toilet),
        )
        .timeout(const Duration(seconds: 30));
    Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['message'] == 'Toilet Created Successfully') {
        showSuccessDialog(
            context, "Toilet added successfully", null, HomeView());
        print('Toilet created successfully!');
      }
    } else if (response.statusCode == 400) {
      // Handle validation errors
      final responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    }
    else {
      // Handle other status codes (e.g., 500)
      showErrorDialog(context, "Unexpected error",
          ["An unexpected error occurred. Please try again later."]);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(
        context, "Toilet was not added. Operation failed with: $error", []);
    print("error: $error");
  }
}
