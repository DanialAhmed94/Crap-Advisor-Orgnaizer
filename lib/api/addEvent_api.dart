import 'dart:async';
import 'dart:convert';

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../annim/transition.dart';
import '../bottom_navigation_bar/navigation_home_view/eventMangement_view/eventManagement_homeView.dart';
import '../bottom_navigation_bar/navigation_home_view/eventMangement_view/invoice_view.dart';
import '../constants/AppConstants.dart';

Future<void> addEvent(
    BuildContext context,
    String title,
    String? festId,
    String description,
    String capacity,
    String price,
    String total,
    String tax,
    String startTime,
    String endTime,
    String date) async {
  final url = Uri.parse("${AppConstants.baseUrl}/store_events");
  final Map<String, dynamic> event = {
    "festival_id": festId,
    "event_title": title,
    "event_description": description,
    "start_time": startTime,
    "end_time": endTime,
    "start_date": date,
    "crowd_capacity": capacity, // need to add
    "price_per_person": price, //need to add
    "tax_percentage": tax, //need to add
    "grand_total": total,
  };
  try {
    final bearerToken = await getToken();
    print("${event}");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(event),
    );
    // .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 200) {
        await saveEventId(responseData['data']['id']);

      //   showSuccessDialog1(
      //       context,
      //       responseData['message'],
      //       null,
      //       InvoiceView(
      //           eventId: await getEventId(),
      //           crowdCapacity: capacity,
      //           pricePerPerson: price,
      //           total: total,
      //           tax: tax));
      // }
        showSuccessDialog2(
            context,
            responseData['message'],
            null,
            AddEventManagementView());
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
  }
  // on TimeoutException catch (_) {
  //   showErrorDialog(context, "Request timed out. Please try again later.", []);
  // }
  catch (error) {
    showErrorDialog(
        context, "Event was not added. Operation failed with: $error", []);
    print("error123: $error");
  }
}
void showSuccessDialog2<T>(
    BuildContext context,
    String message,
    String? choice,
    T navigateTo,
    ) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: choice != null
            ? Text(
          'Failure',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
            : Text(
          'Success',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRouteBuilder(widget: navigateTo as Widget), (route) => route.isFirst,
              );
            },
          ),
        ],
      );
    },
  );
}
void showSuccessDialog1<T>(
  BuildContext context,
  String message,
  String? choice,
  T navigateTo,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: choice != null
            ? Text(
                'Failure',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                'Success',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                FadePageRouteBuilder(widget: navigateTo as Widget),
              );
            },
          ),
        ],
      );
    },
  );
}
