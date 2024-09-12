import 'package:crap_advisor_orgnaizer/provider/activityCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/bulletinCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/eventCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/festivalCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/invoiceCOLLECTION-provider.dart';
import 'package:crap_advisor_orgnaizer/provider/performanceCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/toiletCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/provider/toiletTypeCollection_provider.dart';
import 'package:crap_advisor_orgnaizer/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => FestivalProvider()),
    ChangeNotifierProvider(create: (_) =>PerformanceProvider()),
    ChangeNotifierProvider(create: (_) =>BulletinProvider()),
    ChangeNotifierProvider(create: (_) =>ActivityProvider()),
    ChangeNotifierProvider(create: (_) =>EventProvider()),
    ChangeNotifierProvider(create: (_) =>InvoiceProvider()),
    ChangeNotifierProvider(create: (_) =>ToiletTypeProvider()),
    ChangeNotifierProvider(create: (_) =>ToiletProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}
