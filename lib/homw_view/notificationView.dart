import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/AppConstants.dart';
import '../provider/notificationProvider.dart';
import '../data_model/responseCollectionModel.dart'; // For NotificationData model

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  /// Fetches notifications using the NotificationsProvider
  void _fetchNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NotificationsCollectionProvider>()
          .fetchNotifications(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final notificationsProvider =
    context.watch<NotificationsCollectionProvider>();
    final notifications = notificationsProvider.notifications;
    final isLoading = notificationsProvider.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),

          /// Main Content
          if (isLoading)
          /// Loading indicator
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (notifications.isEmpty)
          /// No data
            const Center(
              child: Text(
                "There is nothing to show here",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          else
          /// Notifications List
            ListView.builder(
              padding: const EdgeInsets.only(top: 40, bottom: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final NotificationData notification = notifications[index];
                return SafeArea(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: Colors.blueAccent,
                          size:  30,
                        ),
                        title: Text(
                          notification.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(notification.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Helper method to format the date string
  String _formatDate(String dateStr) {
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return dateStr;
    }
  }
}
