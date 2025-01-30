import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../../../Maps/DetailMap.dart';
import '../../../Maps/googleMap.dart';
import '../../../annim/transition.dart';
import '../../../api/addFestival_api.dart';
import '../../../api/updateFestival_api.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../utilities/utilities.dart';
import '../../../constants/AppConstants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FestivalDetailView extends StatefulWidget {
  final Festival festival;

  FestivalDetailView({required this.festival});

  @override
  State<FestivalDetailView> createState() => _FestivalDetailViewState();
}

class _FestivalDetailViewState extends State<FestivalDetailView> {
  late TextEditingController _festivalNameControler;
  late TextEditingController _latitudeControler;
  late TextEditingController _longitudeControler;
  late TextEditingController _descriptionControler;
  late TextEditingController _startDateControler;
  late TextEditingController _endDateControler;
  late TextEditingController _addressControler;

  final _formKey = GlobalKey<FormState>();

  bool _isEditMode = false;
  bool _isImageSelected = true;
  bool isLoading = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _festivalNameControler =
        TextEditingController(text: widget.festival.nameOrganizer ?? "");
    _latitudeControler =
        TextEditingController(text: "${widget.festival.latitude}");
    _longitudeControler =
        TextEditingController(text: "${widget.festival.longitude}");
    _descriptionControler =
        TextEditingController(text: "${widget.festival.descriptionOrganizer}");
    _startDateControler =
        TextEditingController(text: "${widget.festival.startingDate}");
    _endDateControler =
        TextEditingController(text: "${widget.festival.endingDate}");
    _addressControler = TextEditingController(text: "");

    _fetchAndSetAddress();
  }

  @override
  void dispose() {
    _startDateControler.dispose();
    _latitudeControler.dispose();
    _longitudeControler.dispose();
    _festivalNameControler.dispose();
    _endDateControler.dispose();
    _descriptionControler.dispose();
    _addressControler.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSetAddress() async {
    String address = await _getAddressFromLatLng(
      double.parse(widget.festival.latitude ?? "0.0"),
      double.parse(widget.festival.longitude ?? "0.0"),
    );

    setState(() {
      _addressControler.text = address;
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

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isImageSelected = true;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }
  Future<void> _openMap() async {
    await Navigator.push(
      context,
      FadePageRouteBuilder(
        widget: MapDetailView(
          isFromFestival: false,
          initialPosition: LatLng(
            double.parse(_latitudeControler.text),
            double.parse(_longitudeControler.text),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Check if there's an original image or a new one
      String? originalImage = widget.festival.image?.trim();
      bool hasOriginalImage = (originalImage != null && originalImage.isNotEmpty);

      // If no new image is selected and no original image is present, show error
      if (_selectedImage == null && !hasOriginalImage) {
        setState(() {
          _isImageSelected = false;
        });
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        String base64img = '';

        if (_selectedImage != null) {
          // If user selected a new image, convert it
          base64img = await convertImageToBase64(_selectedImage);
        } else {
          // No new image selected, use the original image
          // Fetch the original image from the network and convert to base64
          final imageUrl = AppConstants.festivalImageBaseUrl + originalImage!;
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            base64img = base64Encode(response.bodyBytes);
          } else {
            // If fetching the image fails for some reason, handle it.
            // For now, you could leave it blank or show an error.
            // But ideally, you handle the failure gracefully.
            base64img = '';
          }
        }

        updateFestival(
          context,
          widget.festival.id.toString(),
          _festivalNameControler.text,
          base64img,
          _latitudeControler.text,
          _longitudeControler.text,
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

  String? _validateFestivalName(String? value) {
    if (!_isEditMode) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter a festival name';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (!_isEditMode) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter a short description';
    }
    return null;
  }

  Future<void> _pickStartDate() async {
    DateTime initialDate = DateTime.now();
    if (_startDateControler.text.isNotEmpty) {
      DateTime? parsedDate = DateTime.tryParse(_startDateControler.text);
      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      setState(() {
        _startDateControler.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime initialDate = DateTime.now();
    if (_endDateControler.text.isNotEmpty) {
      DateTime? parsedDate = DateTime.tryParse(_endDateControler.text);
      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      setState(() {
        _endDateControler.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
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
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                AppBar(
                  centerTitle: true,
                  title: Text(
                    "Festival Detail",
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
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Indicator for edit mode
                            if (_isEditMode)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    "You are now in Edit Mode",
                                    style: TextStyle(
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 14,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            if (_isEditMode) SizedBox(height: 10),
                            SizedBox(height: 20),
                            buildTextField(
                              label: "Festival Name",
                              controller: _festivalNameControler,
                              icon: AppConstants.festivalNameFieldIcon,
                              validator: _validateFestivalName,
                              readOnly: !_isEditMode,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Image",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: _isEditMode ? _pickImage : null,
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
                                  child: _selectedImage != null
                                      ? Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                      : Image.network(
                                    "${AppConstants.festivalImageBaseUrl}${widget.festival.image ?? ""}",
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/icons/logo.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                              .expectedTotalBytes !=
                                              null
                                              ? loadingProgress
                                              .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Show error only if no image selected and no original image
                            if (!_isImageSelected && _isEditMode)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Please upload an image',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            SizedBox(height: 15),

                            // >>>>>>>>>>>>>> LOCATION ROW REPLACED HERE <<<<<<<<<<<<<<
                            Row(
                              children: [
                                Text(
                                  _isEditMode ? "Edit Location" : "View Location",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                Spacer(),
                                Text(
                                  "Open Map",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    if (_isEditMode) {
                                      // In edit mode, open the GoogleMapView to pick a new location
                                      final result = await Navigator.push(
                                        context,
                                        FadePageRouteBuilder(
                                          widget: GoogleMapView(isFromFestival: true),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          _latitudeControler.text = result['latitude'];
                                          _longitudeControler.text = result['longitude'];
                                          _addressControler.text = result['address'];
                                        });
                                      }
                                    } else {
                                      await _openMap();
                                    }
                                  },
                                  child: Image.asset(AppConstants.mapPreview),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Location (Latitude / Longitude / Address)",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            // Latitude, Longitude, and Address (Now editable if _isEditMode)
                            buildTextField(
                              label: "Latitude",
                              controller: _latitudeControler,
                              readOnly: !_isEditMode,
                            ),
                            SizedBox(height: 10),
                            buildTextField(
                              label: "Longitude",
                              controller: _longitudeControler,
                              readOnly: !_isEditMode,
                            ),
                            SizedBox(height: 10),
                            buildTextField(
                              label: "Address",
                              controller: _addressControler,
                              readOnly: true, // Typically derived from lat/lng
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Start Date",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              controller: _startDateControler,
                              onTap: _isEditMode ? _pickStartDate : null,
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
                            SizedBox(height: 10),
                            Text(
                              "End Date",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              controller: _endDateControler,
                              onTap: _isEditMode ? _pickEndDate : null,
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
                            SizedBox(height: 10),
                            Text(
                              "Description",
                              style: TextStyle(
                                color: Color(0xFF0A0909),
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
                            buildMultilineField(_descriptionControler,
                                validator: _validateDescription,
                                readOnly: !_isEditMode),
                            SizedBox(height: 20),
                            // Show Submit button only in edit mode
                            if (_isEditMode)
                              GestureDetector(
                                onTap: _handleSubmit,
                                child: Container(
                                  width: double.infinity,
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
                          ],
                        ),
                        // Edit button positioned at top-right corner
                        if (!_isEditMode)
                          Positioned(
                            top: 0, // Changed from 20 to 10
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

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? icon,
    String? Function(String?)? validator,
    bool readOnly = true,
    double height = 60,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
          ),
          SizedBox(height: 10),
        ],
        TextFormField(
          readOnly: readOnly,
          controller: controller,
          validator: validator,
          style: TextStyle(fontSize: 14.0),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIconConstraints: BoxConstraints(
              minWidth: 30.0,
              minHeight: 30.0,
            ),
            prefixIcon: icon != null
                ? Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: SvgPicture.asset(icon, color: Color(0xFF8AC85A)),
            )
                : null,
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
    );
  }

  Widget buildMultilineField(TextEditingController controller,
      {String? Function(String?)? validator, bool readOnly = true}) {
    return Container(
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
        readOnly: readOnly,
        validator: validator,
        controller: controller,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
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
    );
  }
}
