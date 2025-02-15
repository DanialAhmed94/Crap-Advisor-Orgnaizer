import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for SocketException

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../annim/transition.dart';
import '../bottom_navigation_bar/navigation_home_view/eventMangement_view/eventManagement_homeView.dart';
import '../bottom_navigation_bar/navigation_home_view/eventMangement_view/invoice_view.dart';
import '../constants/AppConstants.dart';
import 'addEvent_api.dart'; // Ensure this import includes necessary utility functions

Future<void> updateEvent(
    BuildContext context,
    String eventId, // Added eventId parameter
    String title,
    String? festId,
    String description,
    String capacity,
    String price,
    String total,
    String tax,
    String startTime,
    String endTime,
    String date,
    ) async {
  final url = Uri.parse("${AppConstants.baseUrl}/update_events/$eventId"); // Updated endpoint
  final Map<String, dynamic> event = {
    "festival_id": festId,
    "event_title": title,
    "event_description": description,
    "start_time": startTime,
    "end_time": endTime,
    "start_date": date,
    "crowd_capacity": capacity,
    "price_per_person": price,
    "tax_percentage": tax,
    "grand_total": total,
  };

  try {
    final bearerToken = await getToken();
    print("token: $bearerToken");

    print("Updating Event: $event");
    print(" EventId: $eventId");

    final response = await http
        .post( // Changed to PUT method for updating
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event),
    )
        .timeout(Duration(seconds: 30)); // Set a timeout duration

    // Parse the response
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData['status'] == 200) {
        // Assuming the response contains the updated event data
    //    await saveEventId(responseData['data']['id']);

        // showSuccessDialog1(
        //   context,
        //   responseData['message'],
        //   null,
        //   InvoiceView(
        //     eventId: int.parse(eventId),
        //     crowdCapacity: capacity,
        //     pricePerPerson: price,
        //     total: total,
        //     tax: tax,
        //   ),
        // );
        showSuccessDialog2(
          context,
          responseData['message'],
          null,
            AddEventManagementView(),
        );
      } else {
        // Handle cases where statusCode is 200 but 'status' is not 200
        showErrorDialog(
          context,
          responseData['message'] ?? "Update failed.",
          responseData['errors'] ?? [],
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
    // Handle timeout specifically
    showErrorDialog(
      context,
      "Request timed out. Please check your internet connection and try again.",
      [],
    );
  } on SocketException catch (_) {
    // Handle network errors
    showErrorDialog(
      context,
      "Network error. Please ensure you are connected to the internet and try again.",
      [],
    );
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
  }on FormatException catch (_) {
    // Handle JSON format errors
    showErrorDialog(
      context,
      "Data format error. Please try again later.",
      [],
    );
  } catch (error) {
    // Handle any other exceptions
    showErrorDialog(
      context,
      "Event was not updated. Operation failed with: $error",
      [],
    );
    print("Update Error: $error");
  }
}
