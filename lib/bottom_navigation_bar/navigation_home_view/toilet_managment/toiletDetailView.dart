import 'dart:convert';
import 'dart:io';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletDetailMap.dart';
import 'package:crap_advisor_orgnaizer/data_model/toiletCollection_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../annim/transition.dart';
import '../../../api/updateToilet_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/toiletTypeCollection_model.dart';
import '../../../provider/toiletTypeCollection_provider.dart';
import '../../../utilities/utilities.dart';
import '../../../Maps/what3wordsMap.dart'; // Ensure this is your custom map for editing location

class ToiletDetailView extends StatefulWidget {
  final ToiletData toiletData;

  ToiletDetailView({required this.toiletData});

  @override
  State<ToiletDetailView> createState() => _ToiletDetailViewState();
}

class _ToiletDetailViewState extends State<ToiletDetailView> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _isEditMode = false;
  XFile? _selectedImage;
  bool _isNewImageSelected = false;

  late TextEditingController _festivalNameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _what3WordsController;

  late String? _selectedToiletId;

  final FocusNode _latFocusNode = FocusNode();
  final FocusNode _longFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _festivalNameController = TextEditingController(
        text: widget.toiletData.festival?.nameOrganizer ?? "");
    _latitudeController =
        TextEditingController(text: "${widget.toiletData.latitude}");
    _longitudeController =
        TextEditingController(text: "${widget.toiletData.longitude}");
    _what3WordsController =
        TextEditingController(text: "${widget.toiletData.what3Words}");
    _selectedToiletId = widget.toiletData.toiletType.id.toString();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _latFocusNode.dispose();
    _longFocusNode.dispose();
    _festivalNameController.dispose();
    _what3WordsController.dispose();
    super.dispose();
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

  Future<void> _openMap() async {
    if (_isEditMode) {
      final result = await Navigator.push(
        context,
        FadePageRouteBuilder(
          widget: What3WodsMapView(
            isEditMode: true,
            initialLat: double.tryParse(_latitudeController.text) ?? 0.0,
            initialLng: double.tryParse(_longitudeController.text) ?? 0.0,
          ),
        ),
      );

      if (result != null && _isEditMode) {
        setState(() {
          _latitudeController.text = result['latitude'] ?? _latitudeController.text;
          _longitudeController.text = result['longitude'] ?? _longitudeController.text;
          _what3WordsController.text = result['what3Words'] ?? _what3WordsController.text;
        });
      }
    } else {
      await Navigator.push(
        context,
        FadePageRouteBuilder(
          widget: What3WodsMapDetailView(
            initialPosition: LatLng(
              double.tryParse(_latitudeController.text) ?? 0.0,
              double.tryParse(_longitudeController.text) ?? 0.0,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _updateToilet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Determine if there's an original image
        String? originalImage = widget.toiletData.image?.trim();
        bool hasOriginalImage = (originalImage != null && originalImage.isNotEmpty);

        // If no new image is selected and no original image is present, show error
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
          // User picked a new image, convert it to base64
          base64img = await convertImageToBase64(_selectedImage);
        } else {
          // User did not pick a new image, use the original image
          // Fetch the original image from the network and convert it to base64
          final imageUrl = AppConstants.toiletImageBaseUrl + originalImage!;
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            base64img = base64Encode(response.bodyBytes);
          } else {
            // If fetching the image fails, show an error message and return
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

        await updateToilet(
          context,
          widget.toiletData.festivalId.toString(),
          widget.toiletData.id.toString(),
          _selectedToiletId ?? "",
          _latitudeController.text.trim(),
          _longitudeController.text.trim(),
          base64img,
          _what3WordsController.text.trim(),
        );



        setState(() {
          _isEditMode = false;
          _isNewImageSelected = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update toilet details. Please try again.',
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

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You are now in edit mode.',
          style: TextStyle(fontFamily: "Ubuntu"),
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = _isEditMode;
    return Scaffold(
      body: Stack(
        children: [
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
                    "Toilet Detail",
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
                  // Remove edit icon from here; will add like performance snippet
                  actions: [],
                ),
                SizedBox(height: 20),
                // Main Container with form
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
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Consumer<ToiletTypeProvider>(
                          builder: (context, toiletProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                // "You are now in Edit Mode" container like in performance code
                                if (isEditable)
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
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isEditable) SizedBox(height: 10),
                                Text(
                                  "Festival Name",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  readOnly: true,
                                  controller: _festivalNameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIconConstraints: BoxConstraints(
                                      minWidth: 30.0,
                                      minHeight: 30.0,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8),
                                      child: SvgPicture.asset(
                                        AppConstants.dropDownPrefixIcon,
                                        color: Color(0xFF8AC85A),
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
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Image",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    if (isEditable) {
                                      _pickImage();
                                    }
                                  },
                                  child: Container(
                                    height:
                                    MediaQuery.of(context).size.height * 0.2,
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
                                        "${AppConstants.toiletImageBaseUrl}" +
                                            (widget.toiletData.image ?? ""),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
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
                                SizedBox(height: 10),
                                Text(
                                  "Category",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                isEditable
                                    ? DropdownButtonFormField<String>(
                                  value: _selectedToiletId,
                                  decoration: InputDecoration(
                                    prefixIcon: SvgPicture.asset(
                                      AppConstants.dropDownPrefixIcon,
                                      color: Color(0xFF8AC85A),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: toiletProvider.toiletTypes
                                      .map((ToiletType toiletType) {
                                    return DropdownMenuItem<String>(
                                      value: toiletType.id.toString(),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.6,
                                        ),
                                        child: Text(
                                          toiletType.name ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedToiletId = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a toilet type';
                                    }
                                    return null;
                                  },
                                )
                                    : TextFormField(
                                  readOnly: true,
                                  initialValue:
                                  widget.toiletData.toiletType.name ?? "",
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "Category",
                                    hintStyle: TextStyle(
                                      color: Color(0xFFA0A0A0),
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      isEditable ? "Edit Location" : "View Location",
                                      style: TextStyle(
                                          fontFamily: "UbuntuMedium", fontSize: 15),
                                    ),
                                    Spacer(),
                                    Text(
                                      "Open Map",
                                      style: TextStyle(
                                          fontFamily: "UbuntuMedium", fontSize: 15),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: _openMap,
                                      child: Image.asset(AppConstants.mapPreview),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Latitude",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  readOnly: !isEditable,
                                  controller: _latitudeController,
                                  focusNode: _latFocusNode,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a valid latitude';
                                    }
                                    final lat = double.tryParse(value.trim());
                                    if (lat == null || lat < -90 || lat > 90) {
                                      return 'Latitude must be between -90 and 90.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_longFocusNode);
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
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Longitude",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  readOnly: !isEditable,
                                  controller: _longitudeController,
                                  focusNode: _longFocusNode,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a valid longitude';
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
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "What3Words Address",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  readOnly: !isEditable,
                                  controller: _what3WordsController,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a what3words address';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "what3words",
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
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    // Position the Edit button like in PerformanceDetailView
                    if (!_isEditMode)
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
                // Place the Update button outside the container at the bottom if in edit mode
                if (_isEditMode)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _updateToilet,
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
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}




// import 'dart:io';
// import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletDetailMap.dart';
// import 'package:crap_advisor_orgnaizer/data_model/toiletCollection_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../annim/transition.dart';
// import '../../../constants/AppConstants.dart';
//
// class ToiletDetailView extends StatefulWidget {
//   final ToiletData toiletData;
//
//   ToiletDetailView({required this.toiletData});
//
//   @override
//   State<ToiletDetailView> createState() => _ToiletDetailViewState();
// }
//
// class _ToiletDetailViewState extends State<ToiletDetailView> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   bool _isImageSelected = true; // Not really needed since we only view the image
//
//   late TextEditingController _festivalNameController;
//   late TextEditingController _latitudeController;
//   late TextEditingController _longitudeController;
//   late TextEditingController _categoryController;
//   late TextEditingController _what3WordsController;
//
//   final FocusNode _latFocusNode = FocusNode();
//   final FocusNode _longFocusNode = FocusNode();
//   final FocusNode _nameFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     _festivalNameController = TextEditingController(
//         text: widget.toiletData.festival?.nameOrganizer ?? "");
//     _latitudeController =
//         TextEditingController(text: "${widget.toiletData.latitude}");
//     _longitudeController =
//         TextEditingController(text: "${widget.toiletData.longitude}");
//     _categoryController =
//         TextEditingController(text: "${widget.toiletData.toiletType.name}");
//     _what3WordsController =
//         TextEditingController(text: "${widget.toiletData.what3Words}");
//   }
//
//   @override
//   void dispose() {
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     _latFocusNode.dispose();
//     _longFocusNode.dispose();
//     _categoryController.dispose();
//     _nameFocusNode.dispose();
//     _festivalNameController.dispose();
//     _what3WordsController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.asset(
//               AppConstants.planBackground,
//               fit: BoxFit.fill,
//             ),
//           ),
//           // Scrollable content
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: 10),
//                 // App Bar
//                 AppBar(
//                   centerTitle: true,
//                   title: Text(
//                     "Toilet Detail",
//                     style: TextStyle(
//                       fontFamily: "Ubuntu",
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   leading: IconButton(
//                     icon: SvgPicture.asset(AppConstants.backIcon),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                 ),
//                 SizedBox(height: 20),
//                 // Toilet detail container with a stack for the edit button
//                 Stack(
//                   children: [
//                     Container(
//                       margin: EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Color(0xFFF8FAFC),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 80.0,
//                             spreadRadius: 0,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       padding: EdgeInsets.all(16.0),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 20),
//                             Text(
//                               "Festival Name",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _festivalNameController,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 prefixIconConstraints: BoxConstraints(
//                                   minWidth: 30.0,
//                                   minHeight: 30.0,
//                                 ),
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.only(left: 8, right: 8),
//                                   child: SvgPicture.asset(
//                                     AppConstants.dropDownPrefixIcon,
//                                     color: Color(0xFF8AC85A),
//                                   ),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Image",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             Container(
//                               height: MediaQuery.of(context).size.height * 0.2,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.25),
//                                     blurRadius: 4.0,
//                                     spreadRadius: 0,
//                                     offset: Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: Image.network(
//                                   "${AppConstants.toiletImageBaseUrl}" +
//                                       (widget.toiletData.image ?? ""),
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Image.asset(
//                                       "assets/icons/logo.png",
//                                       fit: BoxFit.cover,
//                                     );
//                                   },
//                                   loadingBuilder: (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return Center(
//                                       child: CircularProgressIndicator(
//                                         value: loadingProgress.expectedTotalBytes != null
//                                             ? loadingProgress.cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                             : null,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Category",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _categoryController,
//                               focusNode: _nameFocusNode,
//                               textInputAction: TextInputAction.next,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please select category';
//                                 }
//                                 return null;
//                               },
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_latFocusNode);
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "Category",
//                                 hintStyle: TextStyle(
//                                     color: Color(0xFFA0A0A0),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 Text(
//                                   "View Location",
//                                   style: TextStyle(
//                                       fontFamily: "UbuntuMedium", fontSize: 15),
//                                 ),
//                                 Spacer(),
//                                 Text(
//                                   "Open Map",
//                                   style: TextStyle(
//                                       fontFamily: "UbuntuMedium", fontSize: 15),
//                                 ),
//                                 SizedBox(width: 10),
//                                 GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         FadePageRouteBuilder(
//                                           widget: What3WodsMapDetailView(
//                                             initialPosition: LatLng(
//                                               double.parse(_latitudeController.text),
//                                               double.parse(_longitudeController.text),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Image.asset(AppConstants.mapPreview)),
//                               ],
//                             ),
//                             SizedBox(height: 20),
//                             Text(
//                               "Location (Latitude / Longitude)",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _latitudeController,
//                               focusNode: _latFocusNode,
//                               textInputAction: TextInputAction.next,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter latitude';
//                                 }
//                                 return null;
//                               },
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_longFocusNode);
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "Latitude",
//                                 hintStyle: TextStyle(
//                                     color: Color(0xFFA0A0A0),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _longitudeController,
//                               focusNode: _longFocusNode,
//                               textInputAction: TextInputAction.done,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter longitude';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "Longitude",
//                                 hintStyle: TextStyle(
//                                     color: Color(0xFFA0A0A0),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "What3Words Address",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _what3WordsController,
//                               focusNode: _latFocusNode,
//                               textInputAction: TextInputAction.next,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter what3words';
//                                 }
//                                 return null;
//                               },
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_longFocusNode);
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "what3words",
//                                 hintStyle: TextStyle(
//                                     color: Color(0xFFA0A0A0),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 20,
//                       right: 16,
//                       child: GestureDetector(
//                         onTap: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 'This work is in process.',
//                                 style: TextStyle(fontFamily: "Ubuntu"),
//                               ),
//                               backgroundColor: Colors.blueAccent,
//                             ),
//                           );
//                         },
//                         child: Container(
//                           height: 40,
//                           width: 85,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                             color: Color(0xFF8AC85A),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Edit",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 12,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//           if (isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: Center(child: CircularProgressIndicator()),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
