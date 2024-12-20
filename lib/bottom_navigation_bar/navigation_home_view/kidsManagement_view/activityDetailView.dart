import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../Maps/DetailMap.dart';
import '../../../Maps/googleMap.dart';
import '../../../annim/transition.dart';
import '../../../api/updateActivity_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/activityCollection_model.dart';
import '../../../data_model/festivalCollection_model.dart';

class ActivityDetailView extends StatefulWidget {
  final Activity activity;

  ActivityDetailView({required this.activity});

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _isEmpty = true;
  bool _isEditMode = false;
  bool _isNewImageSelected = false;

  late TextEditingController _contentController;
  late TextEditingController _endTimeController;
  late TextEditingController _startTimeController;
  late TextEditingController _titleController;
  late TextEditingController _festivalNameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _addressController;

  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.activity.description ?? "");
    _latitudeController = TextEditingController(text: widget.activity.latitude ?? "");
    _longitudeController = TextEditingController(text: widget.activity.longitude ?? "");
    _endTimeController = TextEditingController(text: widget.activity.endTime ?? "");
    _startTimeController = TextEditingController(text: widget.activity.startTime ?? "");
    _titleController = TextEditingController(text: widget.activity.activityTitle ?? "");
    _festivalNameController = TextEditingController(text: widget.activity.festival?.nameOrganizer ?? "");
    _addressController = TextEditingController(text: "");

    _fetchAndSetAddress();

    _contentController.addListener(() {
      setState(() {
        _isEmpty = _contentController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _festivalNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSetAddress() async {
    double lat = double.tryParse(_latitudeController.text) ?? 0.0;
    double lng = double.tryParse(_longitudeController.text) ?? 0.0;
    String address = await _getAddressFromLatLng(lat, lng);
    setState(() {
      _addressController.text = address;
    });
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      }
    } catch (e) {
      print(e);
    }
    return "Unknown Address";
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });

  }

  Future<void> _pickImage() async {
    if (!_isEditMode) return;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isNewImageSelected = true;
      });
    }
  }

  Future<String> _convertImageToBase64(XFile? image) async {
    if (image == null) return '';
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _updateActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Check if existing image is available
        String? originalImage = widget.activity.image?.trim();
        bool hasOriginalImage = (originalImage != null && originalImage.isNotEmpty);

        // If no new image selected and no original image
        if (!_isNewImageSelected && !hasOriginalImage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please upload an image',
                style: TextStyle(fontFamily: "Ubuntu"),
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        String base64img = '';

        if (_isNewImageSelected && _selectedImage != null) {
          // New image selected by user
          base64img = await _convertImageToBase64(_selectedImage);
        } else {
          // No new image selected, use original image
          // Fetch the original image from the network and convert to base64
          final imageUrl = AppConstants.imageBaseUrl + (originalImage ?? "");
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            base64img = base64Encode(response.bodyBytes);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to fetch original image. Please try again.',
                  style: TextStyle(fontFamily: "Ubuntu"),
                ),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              isLoading = false;
            });
            return;
          }
        }


        await updateActivity(
          context, widget.activity.id.toString(),
          widget.activity.festivalId.toString(),
        _titleController.text.trim(),
            base64img,
         _contentController.text.trim(),
          _latitudeController.text.trim(),
           _longitudeController.text.trim(),
          _startTimeController.text.trim(),
          _endTimeController.text.trim(),

        );




        setState(() {
          _isEditMode = false;
          _isNewImageSelected = false;
          // Reset fields to original data after successful update
          _titleController.text = widget.activity.activityTitle ?? "";
          _contentController.text = widget.activity.description ?? "";
          _latitudeController.text = widget.activity.latitude ?? "";
          _longitudeController.text = widget.activity.longitude ?? "";
          _startTimeController.text = widget.activity.startTime ?? "";
          _endTimeController.text = widget.activity.endTime ?? "";
          _festivalNameController.text = widget.activity.festival?.nameOrganizer ?? "";
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update activity details. Please try again.',
              style: TextStyle(fontFamily: "Ubuntu"),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields correctly.',
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _openMap() async {
    await Navigator.push(
      context,
      FadePageRouteBuilder(
        widget: MapDetailView(
          isFromFestival: false,
          initialPosition: LatLng(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ),
        ),
      ),
    );
  }
  Future<void> _pickStartTime() async {
    if (!_isEditMode) return;
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _startTimeController.text = DateFormat('h.mm a').format(selectedDateTime);
    }
  }

  Future<void> _pickEndTime() async {
    if (!_isEditMode) return;
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _endTimeController.text = DateFormat('h.mm a').format(selectedDateTime);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEditable = _isEditMode;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                AppBar(
                  centerTitle: true,
                  title: Text(
                    "Activity Detail",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: SvgPicture.asset(AppConstants.backIcon),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                SizedBox(height: 20),
                Stack(
                  children: [
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
                            offset: Offset(0,4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditable)
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    "You are now in Edit Mode",
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            if (isEditable)
                              SizedBox(height: 10),
                            Text("Festival Name", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              controller: _festivalNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIconConstraints: BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  child: SvgPicture.asset(
                                    AppConstants.dropDownPrefixIcon,
                                    color: Color(0xFFAEDB4E),
                                  ),
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Title", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: !isEditable,
                              controller: _titleController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Title is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIconConstraints: BoxConstraints(minWidth: 10.0, minHeight: 10.0),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  child: SvgPicture.asset(
                                    AppConstants.bulletinTitleIcon,
                                    color: Color(0xFFAEDB4E),
                                  ),
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Image", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                if (isEditable) {
                                  _pickImage();
                                }
                              },
                              child: Container(
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _isNewImageSelected && _selectedImage != null
                                      ? Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                      : Image.network(
                                    "${AppConstants.imageBaseUrl}${widget.activity.image ?? ""}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/icons/logo.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Content", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                            SizedBox(height: 10),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.25,
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
                              child: Stack(
                                children: [
                                  TextFormField(
                                    readOnly: !isEditable,
                                    controller: _contentController,
                                    maxLines: null,
                                    expands: true,
                                    keyboardType: TextInputType.multiline,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      hintText: 'enter more about activity...',
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.all(16.0),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter a description';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_isEmpty && !isEditable)
                                    Center(
                                      child: SvgPicture.asset(
                                        AppConstants.bulletinContentIcon,
                                        color: Color(0xFFAEDB4E),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(isEditable ? "Edit Location" : "View Location", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                                Spacer(),
                                Text("Open Map", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    if (_isEditMode) {
                                      // In edit mode, open the GoogleMapView to pick a new location
                                      final result = await Navigator.push(
                                        context,
                                        FadePageRouteBuilder(
                                          widget: GoogleMapView(isFromFestival: false),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          _latitudeController.text = result['latitude'];
                                          _longitudeController.text = result['longitude'];
                                          _addressController.text = result['address'];
                                        });
                                      }
                                    } else {
                                      // Not in edit mode, open the original MapDetailView as before
                                      await _openMap();
                                    }
                                  },
                                  child: Image.asset(AppConstants.mapPreview),
                                ),                              ],
                            ),
                            SizedBox(height: 20),
                            Text("Location (Latitude / Longitude / Address)", style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15)),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: !isEditable,
                              controller: _latitudeController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter latitude';
                                }
                                final lat = double.tryParse(value.trim());
                                if (lat == null || lat < -90 || lat > 90) {
                                  return 'Latitude must be between -90 and 90.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Latitude",
                                hintStyle: TextStyle(color: Color(0xFFA0A0A0), fontFamily: "UbuntuMedium", fontSize: 15),
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
                              readOnly: !isEditable,
                              controller: _longitudeController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter longitude';
                                }
                                final lng = double.tryParse(value.trim());
                                if (lng == null || lng < -180 || lng > 180) {
                                  return 'Longitude must be between -180 and 180.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Longitude",
                                hintStyle: TextStyle(color: Color(0xFFA0A0A0), fontFamily: "UbuntuMedium", fontSize: 15),
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
                              controller: _addressController,
                              validator: (value) {
                                if (value == null || value.isEmpty || value == "Unknown Address") {
                                  return 'Please select a valid location (address unknown)';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Address",
                                hintStyle: TextStyle(color: Color(0xFFA0A0A0), fontFamily: "UbuntuMedium", fontSize: 15),
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
                                      Text("Start Time", style: TextStyle(color: Color(0xFF0A0909), fontFamily: "UbuntuMedium", fontSize: 15)),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        onTap: _isEditMode ? _pickStartTime : null,

                                        readOnly: true,
                                        controller: _startTimeController,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please select a start time';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          prefixIconConstraints: BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 8),
                                            child: SvgPicture.asset(
                                              AppConstants.timer1Icon,
                                              color: Color(0xFFAEDB4E),
                                            ),
                                          ),
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
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("End Time", style: TextStyle(color: Color(0xFF0A0909), fontFamily: "UbuntuMedium", fontSize: 15)),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        onTap: _isEditMode ? _pickEndTime : null,

                                        readOnly: true,
                                        controller: _endTimeController,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please select an end time';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          prefixIconConstraints: BoxConstraints(minWidth: 30.0, minHeight: 30.0),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 8),
                                            child: SvgPicture.asset(
                                              AppConstants.timerIcon,
                                              color: Color(0xFFAEDB4E),
                                            ),
                                          ),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    if (!isEditable)
                      Positioned(
                        top: 10,
                        right: 0,
                        child: GestureDetector(
                          onTap: _toggleEditMode,
                          child: Container(
                            height: 40,
                            width: 85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xFF8AC85A),
                            ),
                            child: Center(
                              child: Text(
                                "Edit",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                if (isEditable)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _updateActivity,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFF8AC85A),
                        ),
                        child: Center(
                          child: Text(
                            "Update",
                            style: TextStyle(
                                fontFamily: "UbuntuBold",
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
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


