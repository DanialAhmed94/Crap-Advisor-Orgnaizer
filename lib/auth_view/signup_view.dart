import 'dart:convert';
import 'dart:io';

import 'package:crap_advisor_orgnaizer/auth_view/login_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../annim/transition.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/signup_api.dart';

class ImageUploadSection extends StatefulWidget {
  final Function(List<XFile>) onImagesSelected;

  ImageUploadSection({required this.onImagesSelected});

  @override
  _ImageUploadSectionState createState() => _ImageUploadSectionState();
}

class _ImageUploadSectionState extends State<ImageUploadSection> {
  List<XFile> _images = [];

  Future<void> _pickImage(int index) async {
    // Check for gallery permission
    var permissionStatus = await Permission.photos.status;

    // Request permission if it isn't granted
    if (!permissionStatus.isGranted) {
      permissionStatus = await Permission.photos.request();
    }

    // If permission is granted, proceed to pick an image
    if (permissionStatus.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          if (_images.length > index) {
            _images[index] = image;
          } else {
            _images.add(image);
          }
        });

        widget.onImagesSelected(_images);
      }
    } else {
      // Handle the case where permission is denied
      print("Gallery access denied.");
      // Optionally, show a dialog to the user explaining why the permission is needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Identity Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _images.length > index
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_images[index].path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.add_photo_alternate,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  _SignupViewState createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  bool _isLoading = false;
  List<XFile> _uploadedImages = [];

  void _onImagesSelected(List<XFile> images) {
    setState(() {
      _uploadedImages = images;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_uploadedImages.length < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload at least 1 document')),
        );
        return;
      }
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        // Convert images to base64
        Future<List<String>> base64Strings =
            convertImagesToBase64(_uploadedImages);

        // Perform sign-up
        await signUp(
          context,
          fullNameController.text,
          emailController.text,
          phoneNumberController.text,
          base64Strings,
          organizationNameController.text,
          organizationAddressController.text,
          passwordController.text,
        );

        // Handle success (e.g., navigate to another screen or show a success message)
      } catch (e) {
        // Handle error (e.g., show an error message)
        print(e);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
      // else {
      //   Future<List<String>> base64Strings =
      //       convertImagesToBase64(_uploadedImages);
      //
      //   signUp(
      //       context,
      //       fullNameController.text,
      //       emailController.text,
      //       phoneNumberController.text,
      //       base64Strings,
      //       organizationNameController.text,
      //       organizationAddressController.text,passwordController.text);
      // }
      // Handle form submission
    }
  }

  Future<List<String>> convertImagesToBase64(List<XFile> imageFiles) async {
    List<String> base64Images = [];

    for (var imageFile in imageFiles) {
      // Read the file as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert bytes to base64 string
      String base64Image = base64Encode(bytes);

      // Add the base64 string to the list
      base64Images.add(base64Image);
    }

    return base64Images;
  }

  // Controllers for text fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController organizationNameController =
      TextEditingController();
  final TextEditingController organizationAddressController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Focus nodes for text fields
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneNumberFocus = FocusNode();
  final FocusNode organizationNameFocus = FocusNode();
  final FocusNode organizationAddressFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  // Form key to validate the form
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers and focus nodes when not needed
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    organizationNameController.dispose();
    organizationAddressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    fullNameFocus.dispose();
    emailFocus.dispose();
    phoneNumberFocus.dispose();
    organizationNameFocus.dispose();
    organizationAddressFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image

          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),

          // Positioned SVGs
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.28,
            child: Image.asset(
              AppConstants.newLogo,
              height: 150,
              width: 150,
            ),
            // child: Row(
            //   children: [
            //     SvgPicture.asset(AppConstants.leftLines),
            //     SizedBox(width: 10), // Adjust spacing between SVGs if needed
            //     SvgPicture.asset(AppConstants.logo),
            //     SizedBox(width: 10), // Adjust spacing between SVGs if needed
            //     SvgPicture.asset(AppConstants.rightLines),
            //   ],
            // ),
          ),

          // Scrollable content
          Stack(
            children: [
              Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.34,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          //  color: Color(0xFFF8F8FC),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),

                            // color: Color(0xFFF8F8FC),
                            // Background color of the container
                            borderRadius: BorderRadius.circular(
                                12.0), // Circular border with radius 12
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Full Name field
                                  buildTextFormField(
                                    controller: fullNameController,
                                    focusNode: fullNameFocus,
                                    labelText: 'Full Name',
                                    suffixIcon: Icons.person,
                                    nextFocus: emailFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Email field
                                  buildTextFormField(
                                    controller: emailController,
                                    focusNode: emailFocus,
                                    labelText: 'Email',
                                    suffixIcon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    nextFocus: phoneNumberFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an email address';
                                      }
                                      if (!isValidEmail(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Phone Number field
                                  buildTextFormField(
                                    controller: phoneNumberController,
                                    focusNode: phoneNumberFocus,
                                    labelText: 'Phone Number',
                                    suffixIcon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    nextFocus: organizationNameFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      }
                                      // You can add more validation rules for phone number here if needed
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  Container(
                                    color: const Color(0xFFF1FEED),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ImageUploadSection(
                                          onImagesSelected: _onImagesSelected),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Organization Name field
                                  buildTextFormField(
                                    controller: organizationNameController,
                                    focusNode: organizationNameFocus,
                                    labelText: 'Organization Name',
                                    suffixIcon: Icons.business,
                                    nextFocus: organizationAddressFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the organization name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Organization Address field
                                  buildTextFormField(
                                    controller: organizationAddressController,
                                    focusNode: organizationAddressFocus,
                                    labelText: 'Organization Address',
                                    suffixIcon: Icons.location_on,
                                    maxLines: 3,
                                    nextFocus: passwordFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the organization address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Strong Password field
                                  buildTextFormField(
                                    controller: passwordController,
                                    focusNode: passwordFocus,
                                    labelText: 'Strong Password',
                                    suffixIcon: Icons.lock,
                                    obscureText: true,
                                    nextFocus: confirmPasswordFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      // You can add more validation rules for password here if needed
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Confirm Password field
                                  buildTextFormField(
                                    controller: confirmPasswordController,
                                    focusNode: confirmPasswordFocus,
                                    labelText: 'Confirm Password',
                                    suffixIcon: Icons.lock,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Submit button
                        GestureDetector(
                          onTap: _submitForm,
                          child: SvgPicture.asset(
                              "assets/svg/newsignupButton.svg"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Centered text widget for login prompt
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Already a member? ",
                              style: TextStyle(color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Login Now",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF8AC85A),
                                    // Change the color here to your desired color
                                    decoration: TextDecoration
                                        .underline, // Underline the text to indicate it's tappable
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                          context,
                                          FadePageRouteBuilder(
                                              widget: LoginView()));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading) // Conditionally show the loading indicator
                Positioned.fill(
                  child: Container(
                    color: Colors.black54, // Semi-transparent background
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black,), // Loading indicator
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1FEED),

        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        labelText: labelText,
        labelStyle: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontFamily: "UbuntuLight",
            fontSize: 14),
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                color: Colors.black.withOpacity(0.2),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          // Circular border with radius 30
          borderSide: BorderSide.none, // No border side
        ),
        // border: OutlineInputBorder(),
        // focusedBorder: OutlineInputBorder(
        //   borderSide:
        //       BorderSide(color: focusNode.hasFocus ? Colors.blue : Colors.grey),
        // ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
      validator: validator,
      onEditingComplete: () {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          // Handle submission if needed
        }
      },
    );
  }

  bool isValidEmail(String email) {
    // Simple email validation using a regular expression
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
