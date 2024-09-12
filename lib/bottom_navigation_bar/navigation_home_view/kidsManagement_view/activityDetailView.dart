import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addActivity_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/activityCollection_model.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import '../../../utilities/utilities.dart';

class ActivityDetailView extends StatefulWidget {
  late Activity activity;
  ActivityDetailView({required this.activity});

  @override
  State<ActivityDetailView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<ActivityDetailView> {
  //final TextEditingController _dobControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isEmpty = true;
  String? _selectedFestivalId;

  late TextEditingController _contentControler;
  late TextEditingController _endTimeController;
  late TextEditingController _startTimeController;
  late TextEditingController _titleController;
  late TextEditingController _festivalNameController;


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
    // TODO: implement initState
    super.initState();
    _contentControler = TextEditingController(text: "${widget.activity.description??""}");
    _endTimeController = TextEditingController(text: "${widget.activity.endTime??""}");
    _startTimeController = TextEditingController(text: "${widget.activity.startTime??""}");
    _titleController= TextEditingController(text: "${widget.activity.activityTitle??""}");
    _festivalNameController= TextEditingController(text: "${widget.activity.festival?.nameOrganizer}");

    _contentControler.addListener(() {
      setState(() {
        _isEmpty = _contentControler.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _contentControler.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _titleController.dispose();
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.41 +
        MediaQuery.of(context).size.height *
            0.8; // Example: Height of welcome message Positioned child

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
                    "Activity Detail",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: SvgPicture.asset(AppConstants.backIcon),
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
                height: MediaQuery.of(context).size.height * 1.03,
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
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,

                          controller: _festivalNameController,
                          //focusNode: _performanceFocusNode,
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
                                AppConstants.dropDownPrefixIcon,color: Color(0xFF8AC85A),),
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
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Title",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title is required'; // Error message for empty input
                            } else if (value.length < 10) {
                              return 'Title must be at least 10 characters long'; // Error message for short input
                            }
                            return null; // Input is valid
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
                          "Image",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                          child:ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:Image.network(
                              "${AppConstants.imageBaseUrl}" +
                                  (widget.activity.image ?? ""), // Provide a default empty string if null
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // If an error occurs while loading the image, show the default image
                                return Image.asset(
                                  "assets/icons/logo.png",
                                  fit: BoxFit.cover,
                                );
                              },
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),

                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Content",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                                readOnly: true,
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
                                      AppConstants.bulletinContentIcon),
                                ),
                            ],
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
                                    "Start Time",
                                    style: TextStyle(
                                        color: Color(0xFF0A0909),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 70,
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.45,
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: _startTimeController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Please select a start time';
                                        }
                                        return null;
                                      },
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
                                              AppConstants.timer1Icon),
                                        ),
                                        // suffixIcon: Icon(
                                        //     Icons.arrow_drop_down_sharp),
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
                                ],
                              ),
                            ),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 70,
                                    width:
                                    MediaQuery.of(context).size.width *
                                        0.45,
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: _endTimeController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Please select a end time';
                                        }
                                        return null;
                                      },
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
                                              AppConstants.timerIcon),
                                        ),
                                        // suffixIcon: Icon(
                                        //     Icons.arrow_drop_down_sharp),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //     top: MediaQuery.of(context).size.height * 1.2,
            //     left: MediaQuery.of(context).size.width * 0.1,
            //     right: MediaQuery.of(context).size.width * 0.1,
            //     child: GestureDetector(
            //       onTap: () async {
            //         if (_formKey.currentState!.validate()) {
            //           if (_selectedImage == null) {
            //             setState(() {
            //               _isImageSelected =
            //               false; // Trigger error message if no image is selected
            //             });
            //             return;
            //           } else {
            //             setState(() {
            //               isLoading = true; // Show loading indicator
            //             });
            //             try {
            //               String base64img =
            //               await convertImageToBase64(_selectedImage);
            //               addActivity(
            //                   context,
            //                   _selectedFestivalId,
            //                   _titleController.text,
            //                   base64img,
            //                   _contentControler.text,
            //                   _startTimeController.text,
            //                   _endTimeController.text);
            //             } finally {
            //               // setState(() {
            //               //   isLoading = false;
            //               // });
            //             }
            //             print('all ok danial');
            //           }
            //         }
            //       },
            //       child: Container(
            //         width: MediaQuery.of(context).size.width * 0.8,
            //         height: 50,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(16),
            //           gradient: LinearGradient(
            //             colors: [Color(0xFF015CB5), Color(0xFF00AAE1)],
            //             stops: [0.0, 1.0],
            //             // 0% for the first color, 100% for the second color
            //             begin: Alignment.centerLeft,
            //             // Start from the left side
            //             end: Alignment.centerRight, // End at the right side
            //           ),
            //         ),
            //         child: Center(
            //           child: Text(
            //             "Submit",
            //             style: TextStyle(
            //                 fontFamily: "UbuntuBold",
            //                 fontSize: 18,
            //                 color: Colors.white),
            //           ),
            //         ),
            //       ),
            //     )),
            // if (isLoading)
            //   Positioned.fill(
            //     child: Container(
            //       color: Colors.black54, // Semi-transparent background
            //       child: Center(
            //         child: CircularProgressIndicator(),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
