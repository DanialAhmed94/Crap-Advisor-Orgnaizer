import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../annim/transition.dart';
import '../auth_view/login_view.dart';

void showErrorDialog(
    BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(error.toString(),
                        style: TextStyle(color: Colors.red)))
                    .toList(),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showSuccessDialog<T>(
  BuildContext context,
  String message,
  String? choice,
  T navigateTo,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: choice != null
            ? Text(
                'Failure',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                'Success',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                FadePageRouteBuilder(widget: navigateTo as Widget),
              );
            },
          ),
        ],
      );
    },
  );
}

Future<void> setIsLogedIn(bool isLogedIn) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('user_isLogedIn', isLogedIn);
}
Future<bool?> getIsLogedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('user_isLogedIn');
}
Future<void> saveEventId(int eventId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_eventId', eventId);
}

Future<int?> getEventId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('user_eventId');
}


Future<void> saveToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> saveUserName(String name) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_name', name);
}

Future<String?> getUserName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_name');
}

Future<void> saveUserEmail(String email) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_email', email);
}

Future<String?> getUserEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email');
}

Future<void> saveUserPhone(String phone) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_phone', phone);
}

Future<String?> getUserPhone() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_phone');
}

Future<void> saveIsUserPremum(String isPremiumUser) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_isPremium', isPremiumUser);
}

Future<String?> getIsUserPremum() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userisPremium');
}

Future<void> saveIsUserId(int userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_id', userId);
}

Future<int?> getIsUserId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('user_id');
}



Future<void> saveOrgName(String orgName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_orgName', orgName);
}

Future<String?> getOrgName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_orgName');
}

Future<void> saveOrgAddress(String orgAddress) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_orgAddress', orgAddress);
}

Future<String?> getOrgAddress() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_orgAddress');
}



Future<String> convertImageToBase64(XFile? imageFile) async {
  if (imageFile == null) {
    throw ArgumentError('Image file cannot be null');
  }

  // Read the file as bytes
  final bytes = await imageFile.readAsBytes();

  // Convert bytes to base64 string
  String base64Image = base64Encode(bytes);

  return base64Image;
}
