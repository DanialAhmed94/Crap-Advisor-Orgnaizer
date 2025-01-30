import 'dart:io';

import 'package:crap_advisor_orgnaizer/provider/activityCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/bulletinCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/eventCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/festivalCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/invoiceCOLLECTION-provider.dart';
import 'package:crap_advisor_orgnaizer/provider/notificationProvider.dart';
import 'package:crap_advisor_orgnaizer/provider/performanceCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/toiletCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/toiletTypeCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_view/login_view.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'homw_view/home_view.dart';
import 'provider/refreshNotifier_provider.dart';
import 'utilities/utilities.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    // The system will handle displaying the notification.
    // No need to manually display it.
    print('Message contains a notification payload. System will display it.');
  } else {
    // If it's a data-only message, you can display a notification manually.

  }
}
Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'organizer_high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher_user', // <- small icon
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher_user'), // Custom large icon
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('@mipmap/ic_launcher_user'),)
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
}
Future<void> _navigateToAppropriateScreen() async {
  bool isLoggedIn = (await getIsLogedIn()) ?? false;

  final notificationProvider = Provider.of<NotificationProvider>(
      navigatorKey.currentContext!,
      listen: false);

  if (isLoggedIn) {
    notificationProvider.setShouldRefreshHome(true);
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeView()),
          (route) => false,
    );
  } else {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginView()),
          (route) => false,
    );
  }
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeLocalNotifications();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions for iOS
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Enable auto-initialization on Android
  if (Platform.isAndroid) {
    await messaging.setAutoInitEnabled(true);
  }

  // Retrieve and save the FCM token
  String? token = await messaging.getToken();
  print('FCM Registration Token ***********************: $token');
  await saveFcmTokenToPrefs(token);
  // Set up system UI overlay styles
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );


  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => FestivalProvider()),
    ChangeNotifierProvider(create: (_) =>PerformanceProvider()),
    ChangeNotifierProvider(create: (_) =>BulletinProvider()),
    ChangeNotifierProvider(create: (_) =>ActivityProvider()),
    ChangeNotifierProvider(create: (_) =>EventProvider()),
    ChangeNotifierProvider(create: (_) =>InvoiceProvider()),
    ChangeNotifierProvider(create: (_) =>ToiletTypeProvider()),
    ChangeNotifierProvider(create: (_) =>ToiletProvider()),
    ChangeNotifierProvider(create: (_) =>NotificationProvider()),
    ChangeNotifierProvider(create: (_) =>NotificationsCollectionProvider()),
  ], child: const MyApp()));
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher_user');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async{
      print("Notification clicked with payload: ${response.payload}");
// Handle navigation when notification is tapped
      await _navigateToAppropriateScreen();
    },
  );

  // Create notification channel for Android 8.0+
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'organizer_high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  Future<void> setupFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showNotification(
          notification.title ?? 'No Title',
          notification.body ?? 'No Body',
        );
      }
    });

    // Handle notification tap when the app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app from background or terminated state: ${message.messageId}');
      _handleNotificationClick(message);
    });

    // Handle app launch from a terminated state with a notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state with notification: ${message.messageId}');
        _handleNotificationClick(message);
      }
    });
  }
  Future<void> _handleNotificationClick(RemoteMessage message) async {
    await _navigateToAppropriateScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Organizer Toolkit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashView(),
    );
  }
}
