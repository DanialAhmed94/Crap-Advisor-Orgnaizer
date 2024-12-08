
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Maps/googleMap.dart';
import '../../../annim/transition.dart';
import '../../../api/addActivity_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import '../../../utilities/utilities.dart';

class AddActivityView extends StatefulWidget {
  AddActivityView({super.key});

  @override
  State<AddActivityView> createState() => _AddActivityViewState();
}

class _AddActivityViewState extends State<AddActivityView> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isEmpty = true;
  String? _selectedFestivalId;

  TextEditingController _contentControler = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  XFile? _selectedImage;
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

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _contentControler.addListener(() {
      setState(() {
        _isEmpty = _contentControler.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _contentControler.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        setState(() {
          _isImageSelected = false; // Trigger error message if no image is selected
        });
        return;
      } else {
        setState(() {
          isLoading = true; // Show loading indicator
        });
        try {
          String base64img = await convertImageToBase64(_selectedImage);
          await addActivity(
            context,
            _selectedFestivalId,
            _titleController.text,
            base64img,
            _contentControler.text,
            _latitudeController.text,
            _longitudeController.text,
            _startTimeController.text,
            _endTimeController.text,
          );
        } finally {
          setState(() {
            isLoading = false;
          });
        }
        print('all ok');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                AppBar(
                  centerTitle: true,
                  title: Text(
                    "Add Activity",
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
                        Text(
                          "Select Festival",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        Consumer<FestivalProvider>(
                          builder: (context, festivalProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedFestivalId,
                              decoration: InputDecoration(
                                prefixIcon: SvgPicture.asset(
                                  AppConstants.dropDownPrefixIcon,
                                  color: Color(0xFFAEDB4E),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: festivalProvider.festivals.map((Festival festival) {
                                return DropdownMenuItem<String>(
                                  value: festival.id.toString(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                                    ),
                                    child: Text(
                                      festival.nameOrganizer ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedFestivalId = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a festival';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Title",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 10.0,
                              minHeight: 10.0,
                            ),
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
                                color: Color(0xFFAEDB4E),
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
                        Text(
                          "Content",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
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
                                controller: _contentControler,
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'enter more about activity...',
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              if (_isEmpty)
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
                            Text(
                              "Add Location",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              "Open Map",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                    context, FadePageRouteBuilder(widget: GoogleMapView(isFromFestival: false)));
                                if (result != null) {
                                  setState(() {
                                    _latitudeController.text = result['latitude'];
                                    _longitudeController.text = result['longitude'];
                                    _addressController.text = result['address'];
                                  });
                                }
                              },
                              child: Image.asset(AppConstants.mapPreview),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,
                          controller: _latitudeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter latitude';
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
                        SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,
                          controller: _longitudeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter longitude';
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
                        SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,
                          controller: _addressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter address';
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
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Start Time",
                                    style: TextStyle(
                                        color: Color(0xFF0A0909),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _selectTime(context, _startTimeController),
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        child: TextFormField(
                                          controller: _startTimeController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please select a start time';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            prefixIconConstraints: BoxConstraints(
                                              minWidth: 30.0,
                                              minHeight: 30.0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                AppConstants.timer1Icon,
                                                color: Color(0xFFAEDB4E),
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
                                    "End Time",
                                    style: TextStyle(
                                        color: Color(0xFF0A0909),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => _selectTime(context, _endTimeController),
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        child: TextFormField(
                                          controller: _endTimeController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please select an end time';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            prefixIconConstraints: BoxConstraints(
                                              minWidth: 30.0,
                                              minHeight: 30.0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                AppConstants.timerIcon,
                                                color: Color(0xFFAEDB4E),
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
                          ],
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: _handleSubmit,
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xFFAEDB4E),
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


// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Maps/googleMap.dart';
// import '../../../annim/transition.dart';
// import '../../../api/addActivity_api.dart';
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/festivalCollection_model.dart';
// import '../../../provider/festivalCollection_provider.dart';
// import '../../../utilities/utilities.dart';
//
// class AddActivityView extends StatefulWidget {
//   AddActivityView({super.key});
//
//   @override
//   State<AddActivityView> createState() => _AddFestivalViewState();
// }
//
// class _AddFestivalViewState extends State<AddActivityView> {
//   //final TextEditingController _dobControler = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   bool _isEmpty = true;
//   String? _selectedFestivalId;
//
//   TextEditingController _contentControler = TextEditingController();
//   TextEditingController _endTimeController = TextEditingController();
//   TextEditingController _startTimeController = TextEditingController();
//   TextEditingController _titleController = TextEditingController();
//   TextEditingController _latitudeController = TextEditingController();
//   TextEditingController _longitudeController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//
//   XFile? _selectedImage;
//   bool _isImageSelected = true;
//
//   Future<void> _pickImage() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (image != null) {
//       setState(() {
//         _selectedImage = image; // Assign the selected image
//       });
//     }
//   }
//
//   Future<void> _selectTime(
//       BuildContext context, TextEditingController controller) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         controller.text = picked.format(context);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _contentControler.addListener(() {
//       setState(() {
//         _isEmpty = _contentControler.text.isEmpty;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     _contentControler.dispose();
//     _startTimeController.dispose();
//     _endTimeController.dispose();
//     _titleController.dispose();
//     _addressController.dispose();
//   }
//
//   double calculateTotalHeight(BuildContext context) {
//     double totalHeight = 0.0;
//
//     totalHeight = totalHeight +
//         MediaQuery.of(context).size.height * 0.4 +
//         MediaQuery.of(context).size.height * 0.41 +
//         MediaQuery.of(context).size.height *
//             0.85; // Example: Height of welcome message Positioned child
//
//     return totalHeight;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               height: calculateTotalHeight(context),
//             ),
//             Positioned.fill(
//               child: Image.asset(
//                 AppConstants.planBackground,
//                 fit: BoxFit.fill,
//                 height: MediaQuery.of(context).size.height,
//                 width: MediaQuery.of(context).size.width,
//               ),
//             ),
//             Positioned(
//               top: 10,
//               left: 0,
//               right: 0,
//               child: PreferredSize(
//                 preferredSize: Size.fromHeight(kToolbarHeight),
//                 child: AppBar(
//                   centerTitle: true,
//                   title: Text(
//                     "Add Activity",
//                     style: TextStyle(
//                       fontFamily: "Ubuntu",
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   leading: IconButton(
//                     icon: SvgPicture.asset(AppConstants.backIcon),
//                     // Replace with your custom icon
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   backgroundColor: Colors.transparent,
//                   elevation: 0, // Remove shadow
//                 ),
//               ),
//             ),
//             Positioned(
//               top: MediaQuery.of(context).size.height * 0.15,
//               left: 16,
//               right: 16,
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 1.4,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       // Shadow color with 4% opacity
//                       blurRadius: 80.0,
//                       // Adjust the blur radius for desired blur effect
//                       spreadRadius: 0,
//                       // Optional: controls the size of the shadow spread
//                       offset: Offset(0,
//                           4), // Optional: controls the position of the shadow
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Select Festival",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Consumer<FestivalProvider>(
//                           builder: (context, festivalProvider, child) {
//                             return DropdownButtonFormField<String>(
//                               value: _selectedFestivalId,
//                               decoration: InputDecoration(
//                                 prefixIcon: SvgPicture.asset(                  color: Color(0xFFAEDB4E),
//
//                                     AppConstants.dropDownPrefixIcon),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               items: festivalProvider.festivals
//                                   .map((Festival festival) {
//                                 return DropdownMenuItem<String>(
//                                   value: festival.id.toString(),
//                                   // Store the festival ID here
//                                   child: ConstrainedBox(
//                                     constraints: BoxConstraints(
//                                       maxWidth:
//                                           MediaQuery.of(context).size.width *
//                                               0.6, // Set a max width
//                                     ),
//                                     child: Text(
//                                       festival.nameOrganizer ?? "",
//                                       // Display the festival name
//                                       overflow: TextOverflow.ellipsis,
//                                       // Manage overflow
//                                       maxLines: 1, // Show only one line
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedFestivalId =
//                                       newValue; // Save the selected festival ID
//                                 });
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please select a festival';
//                                 }
//                                 return null;
//                               },
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Title",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           controller: _titleController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Title is required'; // Error message for empty input
//                             }
//                             return null; // Input is valid
//                           },
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 10.0,
//                               minHeight: 10.0,
//                             ),
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.only(left: 8, right: 8),
//                               child: SvgPicture.asset(                  color: Color(0xFFAEDB4E),
//
//                                 AppConstants.bulletinTitleIcon,
//                               ),
//                             ),
//                             // Change icon as needed
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide:
//                                   BorderSide.none, // Removes the default border
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                                   BorderSide.none, // Removes the default border
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                                   BorderSide.none, // Removes the default border
//                             ),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 32.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Upload Image",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Container(
//                           height: MediaQuery.of(context).size.height * 0.2,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.25),
//                                 blurRadius: 4.0,
//                                 spreadRadius: 0,
//                                 offset: Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               _pickImage();
//                               setState(() {
//                                 _isImageSelected =
//                                     true; // Reset error message once image is selected
//                               });
//                             },
//                             child: Center(
//                               child: _selectedImage == null
//                                   ? SvgPicture.asset(                  color: Color(0xFFAEDB4E),
//                                   AppConstants.addIcon)
//                                   : ClipRRect(
//                                       borderRadius: BorderRadius.circular(16),
//                                       child: Image.file(
//                                         File(_selectedImage!.path),
//                                         fit: BoxFit.cover,
//                                         width: double.infinity,
//                                         height: double.infinity,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ),
//                         if (!_isImageSelected) // If image is not selected, show error message
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Text(
//                               'Please upload an image',
//                               style: TextStyle(color: Colors.red, fontSize: 12),
//                             ),
//                           ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Content",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Container(
//                           height: MediaQuery.of(context).size.height * 0.25,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.25),
//                                 blurRadius: 4.0,
//                                 spreadRadius: 0,
//                                 offset: Offset(0, 4),
//                               ),
//                             ],
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           child: Stack(
//                             children: [
//                               TextFormField(
//                                 controller: _contentControler,
//                                 maxLines: null,
//                                 expands: true,
//                                 keyboardType: TextInputType.multiline,
//                                 textAlignVertical: TextAlignVertical.top,
//                                 decoration: InputDecoration(
//                                   hintText: 'enter more about activity...',
//                                   hintStyle: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 16.0,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   contentPadding: EdgeInsets.all(16.0),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter a description';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               if (_isEmpty)
//                                 Center(
//                                   child: SvgPicture.asset(                  color: Color(0xFFAEDB4E),
//
//                                       AppConstants.bulletinContentIcon),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               "Add Location",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             Spacer(),
//                             Text(
//                               "Open Map",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             GestureDetector(
//                                 onTap: () async {
//                                   final result = await Navigator.push(
//                                       context,
//                                       FadePageRouteBuilder(
//                                           widget: GoogleMapView(isFromFestival: false,)));
//                                   if (result != null) {
//                                     // Update text fields with the selected latitude and longitude
//                                     setState(() {
//                                       _latitudeController.text =
//                                       result['latitude'];
//                                       _longitudeController.text =
//                                       result['longitude'];
//                                       _addressController.text =
//                                       result['address'];
//
//                                     });
//                                   }
//                                 },
//                                 child: Image.asset(AppConstants.mapPreview)),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         TextFormField(
//                           readOnly: true,
//                           controller: _latitudeController,
//
//                           textInputAction: TextInputAction.next,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter latitude';
//                             }
//                             return null;
//                           },
//
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "Latitude",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFA0A0A0),
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         TextFormField(
//                           readOnly: true,
//                           controller: _longitudeController,
//                           textInputAction: TextInputAction.done,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter longitude';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "Longitude",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFA0A0A0),
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//
//
//                         SizedBox(
//                           height: 20,
//                         ),
//                         TextFormField(
//                           readOnly: true,
//                           controller: _addressController,
//                           textInputAction: TextInputAction.done,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter address';
//                             }
//                             return null;
//                           },
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "Address",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFA0A0A0),
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide:
//                               BorderSide.none, // Removes the default border
//                             ),
//                             contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Start Time",
//                                     style: TextStyle(
//                                         color: Color(0xFF0A0909),
//                                         fontFamily: "UbuntuMedium",
//                                         fontSize: 15),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () => _selectTime(
//                                         context, _startTimeController),
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.45,
//                                         child: TextFormField(
//                                           controller: _startTimeController,
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value.isEmpty) {
//                                               return 'Please select a start time';
//                                             }
//                                             return null;
//                                           },
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints:
//                                                 BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8, right: 8),
//                                               child: SvgPicture.asset(                  color: Color(0xFFAEDB4E),
//
//                                                   AppConstants.timer1Icon),
//                                             ),
//                                             suffixIcon: Icon(
//                                                 Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(25.0),
//                                               borderSide: BorderSide
//                                                   .none, // Removes the default border
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(30.0),
//                                               borderSide: BorderSide
//                                                   .none, // Removes the default border
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(30.0),
//                                               borderSide: BorderSide
//                                                   .none, // Removes the default border
//                                             ),
//                                             contentPadding:
//                                                 EdgeInsets.symmetric(
//                                                     horizontal: 16.0),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "End Time",
//                                     style: TextStyle(
//                                         color: Color(0xFF0A0909),
//                                         fontFamily: "UbuntuMedium",
//                                         fontSize: 15),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () => _selectTime(
//                                         context, _endTimeController),
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.45,
//                                         child: TextFormField(
//                                           controller: _endTimeController,
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value.isEmpty) {
//                                               return 'Please select a end time';
//                                             }
//                                             return null;
//                                           },
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints:
//                                                 BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8, right: 8),
//                                               child: SvgPicture.asset(                  color: Color(0xFFAEDB4E),
//
//                                                   AppConstants.timerIcon),
//                                             ),
//                                             suffixIcon: Icon(
//                                                 Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(25.0),
//                                               borderSide: BorderSide
//                                                   .none, // Removes the default border
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(30.0),
//                                               borderSide: BorderSide
//                                                   .none, // Removes the default border
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(30.0),
//                                               borderSide: BorderSide
//                                                   .none, // Removes the default border
//                                             ),
//                                             contentPadding:
//                                                 EdgeInsets.symmetric(
//                                                     horizontal: 16.0),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//                 top: MediaQuery.of(context).size.height * 1.57,
//                 left: MediaQuery.of(context).size.width * 0.1,
//                 right: MediaQuery.of(context).size.width * 0.1,
//                 child: GestureDetector(
//                   onTap: () async {
//                     if (_formKey.currentState!.validate()) {
//                       if (_selectedImage == null) {
//                         setState(() {
//                           _isImageSelected =
//                               false; // Trigger error message if no image is selected
//                         });
//                         return;
//                       } else {
//                         setState(() {
//                           isLoading = true; // Show loading indicator
//                         });
//                         try {
//                           String base64img =
//                               await convertImageToBase64(_selectedImage);
//                           addActivity(
//                               context,
//                               _selectedFestivalId,
//                               _titleController.text,
//                               base64img,
//                               _contentControler.text,
//                               _latitudeController.text,
//                               _longitudeController.text,
//                               _startTimeController.text,
//                               _endTimeController.text);
//                         } finally {
//                           // setState(() {
//                           //   isLoading = false;
//                           // });
//                         }
//                         print('all ok danial');
//                       }
//                     }
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color: Color(0xFFAEDB4E),
//
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Submit",
//                         style: TextStyle(
//                             fontFamily: "UbuntuBold",
//                             fontSize: 18,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 )),
//             if (isLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black54, // Semi-transparent background
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
