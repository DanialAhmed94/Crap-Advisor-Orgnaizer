import 'package:flutter/material.dart';
import '../api/getToiletType_api.dart';
import '../data_model/toiletTypeCollection_model.dart';

class ToiletTypeProvider extends ChangeNotifier {
  List<ToiletType> _toiletTypes = [];

  List<ToiletType> get toiletTypes => _toiletTypes;

  // Fetch toilet types and update the list
  Future<void> fetchToiletTypes(BuildContext context) async {
    final response = await getToiletTypeCollection(context); // Replace this with your actual API call

    if (response != null) {
      _toiletTypes = response.data;
      notifyListeners(); // Notify listeners when data is updated
    }
  }
}
