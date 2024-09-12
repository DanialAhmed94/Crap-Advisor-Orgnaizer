import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/AppConstants.dart';  // Your app constants file
import '../data_model/invoiceCollection_model.dart';
import '../utilities/utilities.dart';  // Utilities for token and error handling

Future<InvoiceResponse?> getInvoiceCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/invoice");  // Replace with your API endpoint
  try {
    final bearerToken = await getToken();  // Fetch the bearer token
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );
        // .timeout(Duration(seconds: 30));  // Timeout after 30 seconds

    if (response.statusCode == 200) {
      final data = json.decode(response.body);  // Decode the JSON response
      return InvoiceResponse.fromJson(data);  // Return the parsed response
    } else {
      final data = json.decode(response.body);  // Decode error response
      showErrorDialog(context, data['message'], data['errors']);  // Show error dialog if any
    }
  }
  // on TimeoutException catch (_) {
  //   showErrorDialog(context, "Request timed out. Please try again later.", []);  // Timeout error
  // }
  catch (error) {
    showErrorDialog(context, "Operation failed with: $error", []);  // Generic error
    print("error: $error");  // Print the error for debugging
  }
  return null;
}
