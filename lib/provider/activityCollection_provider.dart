import 'package:flutter/material.dart';
import '../api/deleteActivity_api.dart';
import '../api/getActivitiesCollection_api.dart';
import '../api/getBulletinCollection.dart';
import '../api/getPerformanceCollection.dart';
import '../data_model/activityCollection_model.dart';
import '../data_model/bulletinCollection_model.dart';
import '../data_model/performanceCollection_model.dart';
class ActivityProvider extends ChangeNotifier {

  List<Activity> _activities = [];

  List<Activity> get activities => _activities;
  Future<void> fetchActivities(BuildContext context) async {
    final response = await getActivitiesCollection(context);

    if (response != null) {
      _activities = response.data;

      notifyListeners();
    }
  }

  Future<void> deleteActivity(BuildContext context, String activitytId) async {
    final response = await deleteSelectedActivity(context, activitytId);
    if (response) {
      notifyListeners();
    }
  }
}