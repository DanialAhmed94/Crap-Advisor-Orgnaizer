import 'package:flutter/material.dart';
import '../api/deleteEvent_api.dart';
import '../api/getEventsCollection_api.dart'; // Import the API method for fetching events
import '../data_model/eventColection_model.dart';

class EventProvider extends ChangeNotifier {
  List<EventData> _events = [];

  List<EventData> get events => _events;

  // Fetch events from the API and notify listeners
  Future<void> fetchEvents(BuildContext context) async {
    final response = await getEventsCollection(context);

    if (response != null) {
      _events = response.data;
      notifyListeners();
    }
  }

  Future<bool> deleteEvent(BuildContext context, String eventId) async {
    final response = await deleteSelectedEvent(context, eventId);
    if (response) {
      notifyListeners();
      return true;
    }
    else{
      return false;
    }
  }
}
