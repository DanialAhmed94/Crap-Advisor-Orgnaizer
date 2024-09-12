import 'package:crap_advisor_orgnaizer/splash.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
import 'dart:convert';
import 'dart:async';
import '../annim/transition.dart';
import '../premium_view/premium_view.dart';
import '../utilities/utilities.dart';

Future<void> LogoutApi(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/logout");
  final bearerToken = await getToken();

  try {
    final response = await http
        .post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    )
        .timeout(const Duration(seconds: 30));

    // Parse the response
    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Check the message or code for success
      if (responseBody['code'] == 200) {
        // Handle successful logout

        await saveToken("");
        await saveUserName("");
        await saveUserEmail("");
        await saveUserPhone("");
        await saveIsUserPremum("");
        await saveIsUserId(0);
        await setIsLogedIn(false);
        await saveOrgName("");
        await saveOrgAddress("");
        // Navigate to a different screen, e.g., HomeView
        Navigator.pushReplacement(
          context,
         FadePageRouteBuilder(widget: SplashView())
        );
      } else {
        // Handle other success codes if needed
        showErrorDialog(context, 'Unexpected response code: ${responseBody['code']}');
      }
    } else {
      // Handle server error responses
      showErrorDialog(context, 'Server error: ${response.statusCode}');
    }
  }on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.",);}

  catch (error) {
    // Handle network or other errors
    showErrorDialog(context, 'An error occurred: $error');
  }
}


void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
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
