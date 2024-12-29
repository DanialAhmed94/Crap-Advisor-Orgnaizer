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
  late final TextEditingController _startDateControler;
  late final TextEditingController _endDateControler;
  XFile? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isImageSelected = true;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _festivalNameControler = TextEditingController();
    latitudeControler = TextEditingController();
    longitudeControler = TextEditingController();
    _addressControler = TextEditingController();
    _descriptionControler = TextEditingController();
    _startDateControler = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _endDateControler = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  }

  @override
  void dispose() {
    _startDateControler.dispose();
    latitudeControler.dispose();
    longitudeControler.dispose();
    _festivalNameControler.dispose();
    _endDateControler.dispose();
    _addressControler.dispose();
    _descriptionControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                // AppBar
                AppBar(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                SizedBox(height: 20),
                // Main Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 80.0,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Festival Name",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
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
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min, // Ensures icon fits its space
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: SvgPicture.asset(
                                    AppConstants.festivalNameFieldIcon,
                                    color: Color(0xFF8AC85A),
                                    width: 25.0, // Keep icon size intact
                                    height: 25.0,
                                  ),
                                ),
                                SizedBox(width: 8), // Adds padding between the icon and content
                              ],
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0, // Removes minimum size constraints for `prefixIcon`
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust content padding
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Upload Image",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
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
                                _isImageSelected = true;
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
                        if (!_isImageSelected)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Please upload an image',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Location",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              "Open Map",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                    context,
                                    FadePageRouteBuilder(widget: GoogleMapView(isFromFestival: true,)));
                                if (result != null) {
                                  setState(() {
                                    latitudeControler.text = result['latitude'];
                                    longitudeControler.text = result['longitude'];
                                    _addressControler.text = result['address'];
                                  });
                                }
                              },
                              child: Image.asset(AppConstants.mapPreview),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
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
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 10),
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
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 10),
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
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 10),
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
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2050),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _startDateControler.text = pickedDate.toString().substring(0, 11);
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        child: TextFormField(
                                          controller: _startDateControler,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            prefixIconConstraints: BoxConstraints(
                                              minWidth: 30.0,
                                              minHeight: 30.0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                AppConstants.calendarIcon,
                                                color: Color(0xFF8AC85A),
                                              ),
                                            ),
                                            suffixIcon: Icon(Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
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
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2050),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _endDateControler.text = pickedDate.toString().substring(0, 11);
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        child: TextFormField(
                                          controller: _endDateControler,
                                          style: TextStyle(fontSize: 14.0),
                                          decoration: InputDecoration(
                                            prefixIconConstraints: BoxConstraints(
                                              minWidth: 30.0,
                                              minHeight: 30.0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                AppConstants.calendarIcon,
                                                color: Color(0xFF8AC85A),
                                              ),
                                            ),
                                            suffixIcon: Icon(Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintStyle: TextStyle(
                                                color: Color(0xFFA0A0A0),
                                                fontFamily: "UbuntuMedium",
                                                fontSize: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(25.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: double.infinity,
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
                            borderRadius: BorderRadius.circular(10.0),
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
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Enter your description here...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(16.0),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Submit Button
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedImage == null) {
                                setState(() {
                                  _isImageSelected = false;
                                });
                                return;
                              } else {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  String base64img = await convertImageToBase64(_selectedImage);
                                await  addFestival(
                                    context,
                                    _festivalNameControler.text,
                                    base64img,
                                    latitudeControler.text,
                                    longitudeControler.text,
                                    _startDateControler.text,
                                    _endDateControler.text,
                                    _descriptionControler.text,
                                  );
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
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
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
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
