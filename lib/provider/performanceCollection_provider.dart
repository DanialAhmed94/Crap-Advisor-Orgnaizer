import 'package:flutter/material.dart';
import '../api/deletePerformance_api.dart';
import '../api/getPerformanceCollection.dart';
import '../data_model/performanceCollection_model.dart';

class PerformanceProvider extends ChangeNotifier {
  List<Performance> _performances = [];

  List<Performance> get performances => _performances;



  Future<void> fetchPerformances(BuildContext context) async {
    final response = await getPerformanceCollection(context);

    if (response != null) {
      _performances = response.data;

      notifyListeners();
    }
  }

  Future<void> deletePerformance(BuildContext context, String performanceId) async {
    final response = await deleteSelectedPerformance(context, performanceId);
    if (response) {
      notifyListeners();
    }
  }
}
