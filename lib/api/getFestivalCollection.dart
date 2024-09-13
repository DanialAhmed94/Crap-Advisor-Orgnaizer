import 'dart:async';
import 'dart:convert';

import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/AppConstants.dart';
import '../data_model/festivalCollection_model.dart';

Future<FestivalResponse?> getFestivalCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/festivals");
  try {
    final bearerToken = await getToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json', // Set the content type to JSON
      },
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FestivalResponse.fromJson(data);
    }
    else {
      final data = json.decode(response.body);
      showErrorDialog(context, data['message'], data['errors']);
    }
  }
   on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Operation failed with while fetching festivals: $error", []);
    print("error123: $error");
  }
}
