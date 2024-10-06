import 'dart:async';
import 'dart:convert';

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/Navigation_HomeView.dart';
import '../bottom_navigation_bar/navigation_home_view/festival_managment/festival_managment_homeView.dart';
import '../bottom_navigation_bar/navigation_home_view/new_bullitin_managment/newBulletin_managmentView.dart';
import '../constants/AppConstants.dart';
import '../homw_view/home_view.dart';

Future<void> addBulletin(BuildContext context, String title, String content,
    bool publishNow, String time, String date) async {
  String choice = "";
  if (publishNow == false) {
    choice = "0";
  } else {
    choice = "1";
  }
  final url = Uri.parse("${AppConstants.baseUrl}/store_bulletin");
  Map<String, dynamic> buletin = {
    'title': title,
    'content': content,
    'publish_now': choice,
    'date': date,
    'time': time,
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
          body: jsonEncode(buletin),
        )
        .timeout(Duration(seconds: 30));
print('Bulletin : $buletin');
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        // Match exact messages for each scenario
        String? message = responseData['Message']; // full qota
        String? message1 = responseData['message'];

        if (message1 == "Bulletin Added Successfully") {
          showSuccessDialog(context, "Bulletin Added Successfully", null,
              AddNewsBullitinHome());
        } else if (message ==
            "You have comsumed your limit of an Standard Account! Please Buy Premium Account to Proceed Further") {
          showSuccessDialog(context, message??"", "Failure", AddNewsBullitinHome());
        } else {
          showErrorDialog(context, message??"", []);
        }
      } else {
        showErrorDialog(
            context, responseData['message'], responseData['errors']);
      }
    } else {
      showErrorDialog(context, "Error: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    print("Error: $error"); // Debugging error
    showErrorDialog(
        context, "Bulletin was not added. Operation failed with: $error", []);
  }
}
