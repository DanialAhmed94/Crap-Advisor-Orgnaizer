import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
import '../bottom_navigation_bar/navigation_home_view/Navigation_HomeView.dart';
import 'package:http/http.dart' as http;

import '../bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/stage_management_homeView.dart';
import '../constants/AppConstants.dart';
import '../homw_view/home_view.dart';

Future<void> addPerformance(
    BuildContext context,
    String? festId,
    String startDate,
    String endDate,
    String title,
    String band,
    String artist,
    String participants,
    String specialGuests,
    String startTime,
    String endTime,
    String lighting,
    String sound,
    String stageSetup,
    String transitionDetail,
    String specialNotes,
    String? event_id
    ) async {
  final url = Uri.parse("${AppConstants.baseUrl}/store_performance");

  final Map<String, dynamic> performance = {
    'festival_id': festId ?? "",
    'band_name': "." ,
    'artist_name': artist ,
    'technical_rquirement_lightening': lighting,
    'technical_rquirement_sound': sound,
    'technical_rquirement_stage_setup': stageSetup,
    'technical_rquirement_special_notes':
        specialNotes,
    'participant_name': participants,
    'special_guests': specialGuests,
    'start_time': startTime,
    'end_time': endTime,
    'start_date': startDate,
    'end_date': endDate,
    'performance_title': title,
    'transition_detail': transitionDetail,
    'event_id': event_id,
  };

  try {
    final bearerToken = await getToken();
    print("Bearer Token: $bearerToken"); // Debugging token
    print("Performance Data: $performance"); // Debugging data

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(performance),).timeout(Duration(seconds: 30));

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        // Match exact messages for each scenario
        String? message = responseData['Message'];// full qota
        String? message1 = responseData['message'];

        if (message1 == "Performance Created Successfully") {
          showSuccessDialog(context, "Performance added successfully!", null,
              AddPerformanceHome());
        } else if (message ==
            "You have comsumed your limit of an Standard Account! Please Buy Premium Account to Proceed Further")
        {
          showSuccessDialog(context, message??"", "Attention",   AddPerformanceHome());

          // showSuccessDialog(context, message??"", "Attention",  BotomPremiumView());
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
  }
  on TimeoutException catch (_) {
    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity != ConnectivityResult.none;

    if (hasConnection) {
      final isInternetSlow = !(await _hasGoodConnection());
      if (isInternetSlow) {
        showErrorDialog(context, "Slow internet connection detected.", []);
      } else {
        showErrorDialog(context, "Server is taking too long to respond.", []);
      }
    } else {
      showErrorDialog(context, "No internet connection.", []);
    }
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
  }
  catch (error) {
    print("Error: $error"); // Debugging error
    showErrorDialog(context,
        "Performance was not added. Operation failed with: $error", []);
  }
}

Future<bool> _hasGoodConnection() async {
  try {
    final response = await http
        .get(
      Uri.parse('https://www.google.com'),
    )
        .timeout(Duration(seconds: 2));
    return true;
  } catch (_) {
    return false;
  }
}
