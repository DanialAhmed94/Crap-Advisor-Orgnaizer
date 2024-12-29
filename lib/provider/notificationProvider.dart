import 'package:flutter/material.dart';

// Replace these imports with the actual API calls and data models
import '../api/getNotifications.dart';
import '../data_model/responseCollectionModel.dart';

class NotificationsCollectionProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<NotificationData> _notifications = [];

  // Getter to expose the list of notifications
  List<NotificationData> get notifications => _notifications;
  bool get isLoading => _isLoading;
  /// Fetch notifications from the API and update the state.
  Future<void> fetchNotifications(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await getNotifications(context);

      if (response != null) {
        _notifications = response.data;
      }
    } catch (e) {
      // Handle errors if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
