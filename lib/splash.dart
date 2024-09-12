import 'dart:async';

import 'package:crap_advisor_orgnaizer/auth_view/login_view.dart';
import 'package:crap_advisor_orgnaizer/auth_view/signup_view.dart';
import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'annim/transition.dart';
import 'homw_view/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), _whereToGo);
  }

  Future<void> _whereToGo() async {
    bool isLoggedIn = await getIsLogedIn() ?? false;

    if (isLoggedIn) {
      // Navigate to logged-in screen
      Navigator.of(context)
          .pushReplacement(FadePageRouteBuilder(widget: HomeView()));
    } else {
      Navigator.of(context).pushReplacement(
    FadePageRouteBuilder(widget: LoginView())      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: SvgPicture.asset(
            AppConstants.splashBackground,
            fit: BoxFit.cover,
          )),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.26,
              child: Image.asset(
                AppConstants.newLogo,
                height: 180,
                width: 180,
              )),
        ],
      ),
    );
  }
}
