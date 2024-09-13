import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/AppConstants.dart';
import '../data_model/toiletCollection_model.dart';
import '../utilities/utilities.dart'; // Assuming you have a utility for token and showing dialogs

Future<ToiletResponse?> getToiletCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/toilets"); // Adjust endpoint accordingly
  try {
    final bearerToken = await getToken(); // Fetch token from utility
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json', // Set the content type to JSON
      },
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ToiletResponse.fromJson(data); // Parse the response
    } else {
      final data = json.decode(response.body);
      showErrorDialog(context, data['message'], data['errors']);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } catch (error) {
    showErrorDialog(context, "Operation failed with while fetching toilets: $error", []);
    print("error: $error");
  }
  return null;
}
