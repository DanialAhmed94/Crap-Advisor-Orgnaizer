import 'package:flutter/material.dart';
import '../api/deleteToilet_api.dart';
import '../api/getToiletCollection_api.dart';
import '../data_model/toiletCollection_model.dart';

class ToiletProvider extends ChangeNotifier {
  List<ToiletData> _toilets = [];
  int _totalToilets = 0;

  List<ToiletData> get toilets => _toilets;
  int get totalToilets => _totalToilets;

  // Fetch toilets and update the list and total count
  Future<void> fetchToilets(BuildContext context) async {
    final response = await getToiletCollection(context); // Assuming getToiletCollection is your API method

    if (response != null) {
      _toilets = response.data;
      _totalToilets = response.data.length; // Assuming total is the length of the data array
      notifyListeners(); // Notify listeners when data is updated
    }
  }

  Future<void> deleteToilet(BuildContext context, String toiletId) async {
    final response = await deleteSelectedToilet(context, toiletId);
    if (response) {
      notifyListeners();
    }
  }
}
