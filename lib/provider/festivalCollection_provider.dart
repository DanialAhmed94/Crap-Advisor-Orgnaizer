import 'package:flutter/material.dart';

import '../api/deleteFestival_api.dart';
import '../api/getFestivalCollection.dart';
import '../data_model/festivalCollection_model.dart';

// Import your model

class FestivalProvider extends ChangeNotifier {
  List<Festival> _festivals = [];
  int _totalFestivals = 0;
  int _totalAttendees = 0;

  List<Festival> get festivals => _festivals;

  int get totalFestivals => _totalFestivals;

  int get totalAttendees => _totalAttendees;

  // Fetch festivals and update the list, total attendees, and total festivals
  Future<void> fetchFestivals(BuildContext context) async {
    final response = await getFestivalCollection(context);

    if (response != null) {
      _festivals = response.data;
      _totalFestivals = response.count;
      _totalAttendees = response.attendies;

      notifyListeners(); // Notify listeners when data is updated
    }
  }

  Future<void> deleteFestival(BuildContext context, String festivalId) async {
    final response = await deleteSelectedFestival(context, festivalId);
    if (response) {
      notifyListeners();
    }
  }
}
