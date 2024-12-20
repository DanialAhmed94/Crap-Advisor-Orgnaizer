import 'package:flutter/material.dart';
import '../api/deleteBulletin_api.dart';
import '../api/getBulletinCollection.dart';
import '../api/getPerformanceCollection.dart';
import '../data_model/bulletinCollection_model.dart';
import '../data_model/performanceCollection_model.dart';

class BulletinProvider extends ChangeNotifier {

  List<Bulletin> _bulletins = [];

  List<Bulletin> get bulletins => _bulletins;

  Future<void> fetchBulletins(BuildContext context) async {
    final response = await getBulletinCollection(context);

    if (response != null) {
      _bulletins = response.data;

      notifyListeners();
    }
  }
  Future<void> deleteBulletin(BuildContext context, String bulletintId) async {
    final response = await deleteSelectedBulletin(context, bulletintId);
    if (response) {
      notifyListeners();
    }
  }
}
