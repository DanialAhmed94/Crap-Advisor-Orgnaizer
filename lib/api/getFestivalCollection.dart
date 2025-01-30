import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for SocketException

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../annim/transition.dart';
import '../bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
import '../constants/AppConstants.dart';
import '../data_model/festivalCollection_model.dart';

Future<FestivalResponse?> getFestivalCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/festival");
  const timeoutDuration = Duration(seconds: 30); // Define a timeout duration

  try {
    final bearerToken = await getToken();
    final response = await http
        .get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json', // Set the content type to JSON
      },
    )
        .timeout(timeoutDuration); // Apply timeout to the request

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FestivalResponse.fromJson(data);
    } else if (response.statusCode == 403) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showExpiredAccountErrorDialog(
          context, responseData['message'], responseData['errors']);
    } else {
      final data = json.decode(response.body);
      showErrorDialog(context, data['message'], data['errors']);
    }
  } on TimeoutException catch (_) {
    // Handle timeout exceptions
    showErrorDialog(
        context, "The request timed out. Please try again later.", []);
  } on SocketException catch (_) {
    // Handle internet connectivity issues
    showErrorDialog(context,
        "No Internet connection. Please check your network and try again.", []);
  } catch (error) {
    // Handle any other exceptions
    showErrorDialog(context,
        "An unexpected error occurred while fetching festivals: $error", []);
    print("Error fetching festivals: $error");
  }
}

void showExpiredAccountErrorDialog(
    BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(error.toString(),
                    style: TextStyle(color: Colors.red)))
                    .toList(),
              ),
          ],
        ),
        actions: <Widget>[
          // TextButton(
          //   child: Text('Cancel'),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          // ),
          // TextButton(
          //   child: Text('Upgrade'),
          //   onPressed: () {
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       FadePageRouteBuilder(
          //         widget: BotomPremiumView(),
          //       ),
          //           (Route<dynamic> route) => false,
          //     );
          //   },
          // ),
        ],
      );
    },
  );
}

void showErrorDialog(BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(error.toString(),
                    style: TextStyle(color: Colors.red)))
                    .toList(),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
