import 'package:crap_advisor_orgnaizer/auth_view/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../annim/transition.dart';
import '../constants/AppConstants.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double calculateTotalHeight(BuildContext context) {
    // Initialize total height accumulator
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.16 +
        MediaQuery.of(context).size.height * 0.5 +
        MediaQuery.of(context).size.height * 0.38;  // Example: Height of welcome message Positioned child

    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(height: calculateTotalHeight(context)),
            Positioned.fill(
              child: Image.asset(
                AppConstants.planBackground,
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                "Reset Password",
                style: TextStyle(fontSize: 16, fontFamily: "UbuntuBold"),
              ),
              centerTitle: true,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.16,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8FAFC),
                  ),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width - 32,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        "Forgot Password?",
                        style: TextStyle(fontFamily: "UbuntuBold", fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          "Dont, worry we have your festival App covered! submit a request and we’ll ping you a reset ASAP",
                          style:
                          TextStyle(fontFamily: "UbuntuRegular", fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8FAFC),
                    ),
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width - 32,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1,
                          left: 16,
                          right: 16),
                      child: Form(
                        key: _formKey,
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
                                      color: Colors.blue),
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
                              ),
                            ]),
                      ),
                    )),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38,
              left: MediaQuery.of(context).size.width * 0.3,
              child: SvgPicture.asset(AppConstants.logo, height: 150,),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.8,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  GestureDetector(
                    child: SvgPicture.asset(AppConstants.submitButton),
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // Perform the submit action
                        print('Form is valid');
                        // Handle your form submission logic here
                      } else {
                        print('Form is invalid');
                      }
                    },
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    child: Text(
                    "Register Instead",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Ubuntumedium",
                        fontSize: 14,
                        color:const Color(0xFF8AC85A)
                    ),
                  ),
                    onTap: () {
                     Navigator.push(context, FadePageRouteBuilder(widget: SignupView()));
                    },
                  ),

                ],
              ),
            )
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
