import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../bottom_navigation_bar/navigation_home_view/Navigation_HomeView.dart';
import '../bottom_navigation_bar/navigation_home_view/eventMangement_view/eventManagement_homeView.dart';
import '../constants/AppConstants.dart';
import '../homw_view/home_view.dart';

Future<void> addInvoice(
    BuildContext context,
    int eventID,
    String crowdCapacity,
    String pricePerPerson,
    String tax,
    String grandTotal) async {
  final url = Uri.parse("${AppConstants.baseUrl}/store_invoice");
  final Map<String, dynamic> invoice = {
    "event_id": eventID.toString(),
    "crowd_capacity": crowdCapacity,
    "price_per_person": pricePerPerson,
    "tax_percentage": tax,
    "grand_total": grandTotal,
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
          body: jsonEncode(invoice),
        );
        // .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 200) {
        showSuccessDialog(
            context, "Invoice saved successfully", null, AddEventManagementView());
      }
    } else if (response.statusCode == 400) {
      // Handle validation errors
      final responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other status codes (e.g., 500)
      showErrorDialog(context, "Unexpected error",
          ["An unexpected error occurred. Please try again later."]);
    }
  // } on TimeoutException catch (_) {
  //   showErrorDialog(context, "Request timed out. Please try again later.", []);
  }on SocketException catch (_) {
    showErrorDialog(context, "No Internet connection. Please check your network and try again.", []);

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
        context, "Invoice was not saved. Operation failed with: $error", []);
    print("error: $error");
  }
}
