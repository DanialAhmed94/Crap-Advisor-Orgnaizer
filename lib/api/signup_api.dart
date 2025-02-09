import 'dart:async';
import 'dart:convert';
import 'package:crap_advisor_orgnaizer/auth_view/login_view.dart';
import 'package:http/http.dart' as http;
import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../annim/transition.dart';
import '../utilities/utilities.dart';

Future<void> signUp(
    BuildContext context,
    String fullName,
    String email,
    String phone,
    Future<List<String>> images,
    String organization,
    String organization_address,
    String password) async {
  final url = Uri.parse("${AppConstants.baseUrl}/authup");

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId= await prefs.getString("fcm_token");

  List<String> uploadedImages = await images;
  final Map<String, dynamic> signUpData = {
    'name': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'organization_name': organization,
    'organization_address': organization_address,
    'image': uploadedImages.isNotEmpty ? uploadedImages[0] : null,
    'image2': uploadedImages.length > 1 ? uploadedImages[1] : null,
    'image3': uploadedImages.length > 2 ? uploadedImages[2] : null,
    'app_type':"organizer",
    'device_token': deviceId,

  };

  try {
    // Send the POST request with a timeout
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json', // Set the content type to JSON
          },
          body: jsonEncode(signUpData), // Encode the data to JSON format
        )
        .timeout(const Duration(seconds: 30)); // Set a timeout duration

    // Handle the response
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['code'] == 200) {
        // Signup successful
        print('Signup successful: ${responseData['message']}');
        print('Token: ${responseData['data']['response']['token']}');
        print('User: ${responseData['data']['user']}');
        showSuccessDialog(context,"Your account has been created successfully!",null,LoginView());

      } else {
        // Server-side validation or other errors
        showErrorDialog(
            context, responseData['message'], responseData['errors']);
      }
    } else if (response.statusCode == 400) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other HTTP errors
      showErrorDialog(context,
          "Signup failed with status code: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Signup failed with error: $error", []);
  }
}




