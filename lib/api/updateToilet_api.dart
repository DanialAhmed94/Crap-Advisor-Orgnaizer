import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../bottom_navigation_bar/navigation_home_view/toilet_managment/toiletManagement_View.dart';
import '../constants/AppConstants.dart';
import '../utilities/utilities.dart';

Future<void> updateToilet(
    BuildContext context,
    String festId,
    String toiletId,
    String? toiletTypeId,
    String lat,
    String long,
    String image,
    String what3WordsAddress,
    ) async {
  final url = Uri.parse("${AppConstants.baseUrl}/update_toilet/$toiletId");

  final Map<String, dynamic> toiletData = {
    'festival_id': festId,
    'toilet_type_id': toiletTypeId,
    'latitude': lat,
    'longitude': long,
    'image': image,
    'what_3_words': what3WordsAddress,
  };
  print("toiletId $toiletId");
print("updated toilet $toiletData");
  try {
    final bearerToken = await getToken();
    final response = await http
        .post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(toiletData),
    )
        .timeout(const Duration(seconds: 30));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['message'] == 'Toilet Updated Successfully') {
        showSuccessDialog(
          context,
          "Toilet updated successfully",
          null,
          AddToiletHome(),
        );
        print('Toilet updated successfully!');
      } else {
        // Handle unexpected successful responses with a message not matched
        showErrorDialog(
          context,
          "Unexpected response",
          [responseData['message'] ?? "Update successful, but unexpected response format."],
        );
      }
    } else if (response.statusCode == 400) {
      // Handle validation errors
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other status codes (e.g., 500)
      showErrorDialog(
        context,
        "Unexpected error",
        ["An unexpected error occurred. Please try again later."],
      );
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
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
  } catch (error) {
    showErrorDialog(
      context,
      "Toilet was not updated. Operation failed with: $error",
      [],
    );
    print("error: $error");
  }
}
