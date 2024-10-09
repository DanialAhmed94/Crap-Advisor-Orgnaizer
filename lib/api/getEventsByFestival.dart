import 'dart:async';
import 'dart:convert';

import '../constants/AppConstants.dart';
import '../utilities/utilities.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, String>>> getEventsByFestival(String? fest_id) async {
  final url = Uri.parse(
      "${AppConstants.baseUrl}/events_by_festival?festival_id=$fest_id");

  try {
    final bearerToken = await getToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Check if data is null, if yes return an empty list
      if (jsonData['data'] == null) {
        return [];
      }

      // Extract event id and titles from the data array and store them in a list of maps
      List<Map<String, String>> events = (jsonData['data'] as List)
          .map((event) => {
        'event_id': event['id'].toString(),
        'event_title': event['event_title'] as String,
      })
          .toList();

      return events;
    } else {
      // Throw an exception for non-200 status codes
      throw Exception('Failed to load events, status code: ${response.statusCode}');
    }
  } on TimeoutException catch (_) {
    // Re-throw the timeout exception so that FutureBuilder can catch it
    throw TimeoutException('Request timed out. Please try again later.');
  } catch (e) {
    // Handle any other type of exceptions and rethrow them
    throw Exception('Unexpected error occurred: $e');
  }
}
