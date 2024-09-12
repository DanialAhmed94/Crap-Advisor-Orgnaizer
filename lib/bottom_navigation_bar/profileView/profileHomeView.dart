import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/profileView/profileDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../api/deleteUser_api.dart';
import '../../api/logOut_api.dart';
import '../../constants/AppConstants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contactUsView.dart';


class ProfileHomeview extends StatefulWidget {
  const ProfileHomeview({super.key});

  @override
  State<ProfileHomeview> createState() => _ProfileHomeviewState();
}

class _ProfileHomeviewState extends State<ProfileHomeview> {

  bool _isLoading = false;
  void _sendFeedback(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppConstants.feedbackEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Feedback',
        'body': 'Crap Advisor Organizer Feedback:',
      }),
    );

    try {
      bool launched = await launch(emailLaunchUri.toString());

      if (!launched) {
        // If launching the default email client fails, try opening other installed email applications
        await _openOtherEmailApps();
      }
    } catch (error) {
      // If an error occurs during either attempt, show an error message
      _showErrorDialog(
          context, 'An error occurred while trying to send feedback.');
    }
  }

  Future<void> _openOtherEmailApps() async {
    // List of known email application package names on Android
    final List<String> emailApps = [
      'com.google.android.gm', // Gmail
      'com.microsoft.office.outlook', // Outlook
      // Add more package names for other email apps if needed
    ];

    // Iterate through the list of email apps and try to open them
    for (final String packageName in emailApps) {
      final String url = 'package:$packageName';

      if (await canLaunch(url)) {
        await launch(url);
        return;
      }
    }
    // If no known email apps are found, show an error message
    throw 'No email application is available.';
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              centerTitle: true,
              title: Text(
                "Manage Profile",
                style: TextStyle(
                  fontFamily: "Ubuntu",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              backgroundColor: Colors.transparent,
              elevation: 0, // Remove shadow
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.1, // Position below AppBar
            bottom: 0, // Fill remaining space
            left: 0,
            right: 0,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ProfileTile(
                  title: "My Profile",
                  leadingImage: AppConstants.myProfile,
                  onTap: () {
                    Navigator.push(
                        context,
                      FadePageRouteBuilder(widget: ProfileDetailView())
                    );
                  },
                ),
                const Divider(),
                ProfileTile(
                  title: "Contact us",
                  leadingImage: AppConstants.contactUS,
                  onTap: () {
                    Navigator.push(
                        context,
                      FadePageRouteBuilder(widget: ContactDetailView()));
                  },
                ),
                const Divider(),
                ProfileTile(
                  title: "Feedback",
                  leadingImage: AppConstants.feedBack,
                  onTap: () {
                     _sendFeedback(context);
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "Logout",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  leading: Image.asset(
                    "${AppConstants.logout}",
                    height: 35,
                    width: 35,
                  ),
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    LogoutApi(context);
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "Delete Account",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  leading: Image.asset(
                    "${AppConstants.delete}",
                    height: 35,
                    width: 35,
                  ),
                  onTap: () async {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Are you sure you want to delete your account?',
                            style: TextStyle(color: Colors.black),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                deleteUserApi(context);
                              },
                              child: Text('OK'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54, // Semi-transparent background
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String leadingImage;

  const ProfileTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.leadingImage,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SvgPicture.asset(leadingImage),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }
}
