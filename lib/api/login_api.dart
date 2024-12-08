import 'package:crap_advisor_orgnaizer/homw_view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
import 'dart:convert';
import 'dart:async';
import '../annim/transition.dart';
import '../bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
import '../premium_view/premium_view.dart';
import '../utilities/utilities.dart';

Future<void> LogInApi(
    BuildContext context, String email, String password) async {
  final url = Uri.parse("${AppConstants.baseUrl}/authin");
  final Map<String, dynamic> logInData = {
    'email': email,
    'password': password,
    'app_type':"organizer",

  };
  try {
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json', // Set the content type to JSON
          },
          body: jsonEncode(logInData),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['code'] == 200) {
        final token = responseData['data']['response']['token'];
        final userName = responseData['data']['user']['name'];
        final userEmail = responseData['data']['user']['email'];
        final userPhone = responseData['data']['user']['phone'];
        final isPremiumUser = responseData['data']['user']['premium_user'];
        final userId = responseData['data']['user']['id'];
        final orgName = responseData['data']['user']['organization_name'];
        final orgAddress = responseData['data']['user']['organization_address'];

        await saveToken(token);
        await saveUserName(userName);
        await saveUserEmail(userEmail);
        await saveUserPhone(userPhone);
        await saveIsUserPremum(isPremiumUser);
        await saveOrgName(orgName);
        await saveOrgAddress(orgAddress);
        await setIsLogedIn(true);
        await saveIsUserId(userId);

        print("api hit ${token}");
        Navigator.pushReplacement(
            context, FadePageRouteBuilder(widget: PremiumView()));
      } else {
        // Server-side validation or other errors
        showErrorDialog(
            context, responseData['message'], responseData['errors']);
      }
    } else if (response.statusCode == 400) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    }else if (response.statusCode == 403) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showExpiredAccountErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other HTTP errors
      showErrorDialog(
          context, "Login failed with status code: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Login failed with error: $error", []);
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
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Upgrade'),
            onPressed: () {
             Navigator.push(context, FadePageRouteBuilder(widget:  BotomPremiumView(),));
            },
          ),
        ],
      );
    },
  );
}