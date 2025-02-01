import 'package:crap_advisor_orgnaizer/auth_view/signup_view.dart';
import 'package:crap_advisor_orgnaizer/premium_view/premium_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../annim/transition.dart';
import '../api/login_api.dart';
import '../constants/AppConstants.dart';
import 'forgotPassword_view.dart';

class LoginView extends StatefulWidget {
  LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool _isTyping = false;
  bool _obscureText = true;
  bool _isLoading = false;

  // Controllers and Focus Nodes for TextFields
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isTyping = true; // Enable login button
      });
    } else {
      setState(() {
        _isTyping = false; // Disable login button
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the boolean variable
    });
  }

  double calculateTotalHeight(BuildContext context) {
    // Initialize total height accumulator
    double totalHeight = 0.0;

    // Sum up heights of each positioned child

    // Add heights of other Positioned widgets as needed
    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.2 +
        MediaQuery.of(context).size.height * 0.3 +
        MediaQuery.of(context).size.height * 0.2 +
        MediaQuery.of(context).size.height *
            0.38; // Example: Height of welcome message Positioned child
// Example: Height of login form Positioned child

    // Adjust as per your actual Positioned widgets

    return totalHeight;
  }

  void logIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      try {
        await LogInApi(context, email, password);
      } catch (e) {
        // Handle error (e.g., show an error message)
        print(e);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: calculateTotalHeight(context),
            ),
            Positioned.fill(
              child: Image.asset(
                AppConstants.planBackground,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8FAFC),
                    // color: const Color(0xFFF8FAFC),
                  ),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width - 32,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Text(
                        "Welcome",
                        style:
                            TextStyle(fontFamily: " UbuntuBold", fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "OK, so you’ve got far enough to see that there is more to CrapAdviser than a cheeky app",
                        style: TextStyle(
                            fontFamily: "UbuntuRegular", fontSize: 14),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.52,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8FAFC),
                      // color: const Color(0xFFF8FAFC),
                    ),
                    height: MediaQuery.of(context).size.height * 0.42,
                    width: MediaQuery.of(context).size.width - 32,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 20, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Form(
                            key: _formKey,
                            onChanged: _validateInputs,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Address TextField
                                Text(
                                  "Email Address",
                                  style: TextStyle(
                                      fontFamily: "UbuntuRegular",
                                      fontSize: 14,
                                      color: Color(0xFF7A849C)),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: 'Enter your email',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.withOpacity(0.5)),
                                    suffixIcon: Icon(Icons.email,
                                        color: Colors.black.withOpacity(0.2)),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email address';
                                    }
                                    if (!isValidEmail(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  onEditingComplete: () {
                                    FocusScope.of(context)
                                        .requestFocus(_passwordFocus);
                                  },
                                ),
                                SizedBox(height: 16),

                                // Password TextField
                                Text(
                                  "Password",
                                  style: TextStyle(
                                      fontFamily: "UbuntuRegular",
                                      fontSize: 14,
                                      color: Color(0xFF7A849C)),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.withOpacity(0.5)),
                                    suffixIcon: GestureDetector(
                                      onTap: _togglePasswordVisibility,
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter password';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  FadePageRouteBuilder(
                                      widget: ForgotPasswordView()));
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 12,
                                  color: const Color(0xFF8AC85A)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    child: _isTyping
                        ? SvgPicture.asset(AppConstants.loginButton)
                        : SvgPicture.asset(AppConstants.defaultLoginButton),
                    onTap: () {
                      logIn(context);
                    },
                    // onTap: () {
                    //   if (_isTyping) {
                    //     print("colorchanges");
                    //     Navigator.push(context, FadePageRouteBuilder(widget: PremiumView()));
                    //   }
                    // },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Text(
                      "Register Instead",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Ubuntumedium",
                          fontSize: 14,
                          color: const Color(0xFF8AC85A)),
                    ),
                    onTap: () {
                      Navigator.push(
                          context, FadePageRouteBuilder(widget: SignupView()));
                    },
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54, // Semi-transparent background
                  child: Center(
                    child: CircularProgressIndicator( color: Colors.black,),
                  ),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.147,
              left: MediaQuery.of(context).size.width * 0.281,
              child: Image.asset(
                AppConstants.newLogo,
                height: 150,
                width: 150,
              ),
              // child: Row(
              //   children: [
              //     SvgPicture.asset(AppConstants.leftLines),
              //     SizedBox(width: 10),
              //     SvgPicture.asset(AppConstants.logo),
              //     SizedBox(width: 10),
              //     SvgPicture.asset(AppConstants.rightLines),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isValidEmail(String email) {
  // Simple email validation using a regular expression
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
