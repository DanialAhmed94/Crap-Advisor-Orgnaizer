import 'dart:io';
import 'package:crap_advisor_orgnaizer/Maps/googleMap.dart';

import '../../../annim/transition.dart';
import '../../../api/addFestival_api.dart';
import '../../../utilities/utilities.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

import '../../../constants/AppConstants.dart';

class AddFestivalView extends StatefulWidget {
  AddFestivalView({super.key});

  @override
  State<AddFestivalView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<AddFestivalView> {
  late final TextEditingController _festivalNameControler;
  late final TextEditingController latitudeControler;
  late final TextEditingController longitudeControler;
  late final TextEditingController _descriptionControler;
  late final TextEditingController _addressControler;
  late final TextEditingController _startDateControler =
      TextEditingController();
  late final TextEditingController _endDateControler = TextEditingController();
  XFile? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isImageSelected = true;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image; // Assign the selected image
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _festivalNameControler = TextEditingController();
    latitudeControler = TextEditingController();
    longitudeControler = TextEditingController();
    _addressControler = TextEditingController();
    _descriptionControler = TextEditingController();
    _startDateControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _endDateControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _startDateControler.dispose();
    latitudeControler.dispose();
    longitudeControler.dispose();
    _festivalNameControler.dispose();
    _endDateControler.dispose();
    _addressControler.dispose();
  }
  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.6 + // Example: Height of welcome message Positioned child
        MediaQuery.of(context).size.height *
            0.33; // Example: Height of welcome message Positioned child

    return totalHeight;
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
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: AppBar(
                  centerTitle: true,
                  title: Text(
                    "Add Festivals",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: SvgPicture.asset(AppConstants.greenBackIcon),
                    // Replace with your custom icon
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0, // Remove shadow
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 16,
              right: 16,
              child: Container(
                height: MediaQuery.of(context).size.height * 1.11,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      // Shadow color with 4% opacity
                      blurRadius: 80.0,
                      // Adjust the blur radius for desired blur effect
                      spreadRadius: 0,
                      // Optional: controls the size of the shadow spread
                      offset: Offset(0,
                          4), // Optional: controls the position of the shadow
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Festival Name",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        TextFormField(
                          controller: _festivalNameControler,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a festival name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 30.0,
                              minHeight: 30.0,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SvgPicture.asset(
                                AppConstants.festivalNameFieldIcon,
                                color: Color(0xFF8AC85A),
                              ),
                            ),
                            // Change icon as needed
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 32.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Upload Image",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4.0,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _pickImage();
                              setState(() {
                                _isImageSelected =
                                    true; // Reset error message once image is selected
                              });
                            },
                            child: Center(
                              child: _selectedImage == null
                                  ? SvgPicture.asset(
                                      AppConstants.addIcon,
                                      color: Color(0xFF8AC85A),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(_selectedImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (!_isImageSelected) // If image is not selected, show error message
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Please upload an image',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Location",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              "Open Map",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      FadePageRouteBuilder(
                                          widget: GoogleMapView(isFromFestival: true,)));
                                  if (result != null) {
                                    // Update text fields with the selected latitude and longitude
                                    setState(() {
                                      latitudeControler.text =
                                          result['latitude'];
                                      longitudeControler.text =
                                          result['longitude'];

                                      _addressControler.text =
                                      result['address'];
                                    });
                                  }
                                },
                                child: Image.asset(AppConstants.mapPreview)),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: latitudeControler,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid latitude';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Latitude",
                            hintStyle: TextStyle(
                                color: Color(0xFFA0A0A0),
                                fontFamily: "UbuntuMedium",
                                fontSize: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: longitudeControler,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid longitude';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Longitude",
                            hintStyle: TextStyle(
                                color: Color(0xFFA0A0A0),
                                fontFamily: "UbuntuMedium",
                                fontSize: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _addressControler,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Address",
                            hintStyle: TextStyle(
                                color: Color(0xFFA0A0A0),
                                fontFamily: "UbuntuMedium",
                                fontSize: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Start Date",
                                    style: TextStyle(
                                        color: Color(0xFF0A0909),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2050),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _startDateControler.text = pickedDate
                                              .toString()
                                              .substring(0, 11);
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: TextFormField(
                                          controller: _startDateControler,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            prefixIconConstraints:
                                                BoxConstraints(
                                              minWidth: 30.0,
                                              minHeight: 30.0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                AppConstants.calendarIcon,
                                                color: Color(0xFF8AC85A),
                                              ),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              borderSide: BorderSide
                                                  .none, // Removes the default border
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide
                                                  .none, // Removes the default border
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide
                                                  .none, // Removes the default border
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "End Date",
                                    style: TextStyle(
                                        color: Color(0xFF0A0909),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2050),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _endDateControler.text = pickedDate
                                              .toString()
                                              .substring(0, 11);
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42,
                                        child: TextFormField(
                                          controller: _endDateControler,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            prefixIconConstraints:
                                                BoxConstraints(
                                              minWidth: 30.0,
                                              minHeight: 30.0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                AppConstants.calendarIcon,
                                                color: Color(0xFF8AC85A),
                                              ),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintStyle: TextStyle(
                                                color: Color(0xFFA0A0A0),
                                                fontFamily: "UbuntuMedium",
                                                fontSize: 15),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              borderSide: BorderSide
                                                  .none, // Removes the default border
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide
                                                  .none, // Removes the default border
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide
                                                  .none, // Removes the default border
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Description",
                          style: TextStyle(
                              color: Color(0xFF0A0909),
                              fontFamily: "UbuntuMedium",
                              fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.2, // 20% of screen height
                          width: double.infinity, // Full width of the container
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4.0,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(
                                10.0), // Optional: Add border radius
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a short description';
                              }
                              return null;
                            },
                            controller: _descriptionControler,
                            maxLines: null,
                            // Allows text field to expand vertically
                            expands: true,
                            // Fills the container vertically
                            keyboardType: TextInputType.multiline,
                            // Sets the keyboard to multiline
                            textAlignVertical: TextAlignVertical.top,
                            // Aligns text at the top
                            decoration: InputDecoration(
                              hintText: 'Enter your description here...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                // Matches container's border radius
                                borderSide: BorderSide
                                    .none, // Removes the default border
                              ),
                              contentPadding: EdgeInsets.all(16.0),
                              // Padding inside the text field
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * 1.28,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedImage == null) {
                        setState(() {
                          _isImageSelected =
                              false; // Trigger error message if no image is selected
                        });
                        return;
                      } else {
                        setState(() {
                          isLoading = true; // Show loading indicator
                        });
                        try {
                          String base64img =
                              await convertImageToBase64(_selectedImage);
                          addFestival(
                              context,
                              _festivalNameControler.text,
                              base64img,
                              latitudeControler.text,
                              longitudeControler.text,
                              _startDateControler.text,
                              _endDateControler.text,
                              _descriptionControler.text);
                        } finally {}
                        print('all ok danial');
                      }
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xFF8AC85A),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            fontFamily: "UbuntuBold",
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )),
            if (isLoading)
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
      ),
    );
  }
}
