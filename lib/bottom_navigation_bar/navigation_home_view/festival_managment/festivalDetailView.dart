import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../../api/addFestival_api.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../utilities/utilities.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../constants/AppConstants.dart';

class FestivalDetailView extends StatefulWidget {
  late Festival festival;
  FestivalDetailView({required this.festival});

  @override
  State<FestivalDetailView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<FestivalDetailView> {
  late  TextEditingController _festivalNameControler;
  late  TextEditingController _latitudeControler;
  late  TextEditingController _longitudeControler;
  late TextEditingController _descriptionControler;
  late  TextEditingController _startDateControler ;
  late  TextEditingController _endDateControler;
// late Uint8List imageBytes;





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _festivalNameControler = TextEditingController(text: "${widget.festival.nameOrganizer}");
    _latitudeControler = TextEditingController(text:"${widget.festival.latitude}" );
    _longitudeControler = TextEditingController(text:"${widget.festival.longitude}");
    _descriptionControler = TextEditingController(text:"${widget.festival.descriptionOrganizer}");
    _startDateControler = TextEditingController(text: "${widget.festival.startingDate}");
    _endDateControler =TextEditingController(text: "${widget.festival.endingDate}");
   // imageBytes = base64Decode(widget.festival.image??"");

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _startDateControler.dispose();
    _latitudeControler.dispose();
    _longitudeControler.dispose();
    _festivalNameControler.dispose();
    _endDateControler.dispose();
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery
            .of(context)
            .size
            .height * 0.07 +
        MediaQuery
            .of(context)
            .size
            .height * 0.37 +
        MediaQuery
            .of(context)
            .size
            .height *
            0.58 + // Example: Height of welcome message Positioned child
        MediaQuery
            .of(context)
            .size
            .height *
            0.1; // Example: Height of welcome message Positioned child

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
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
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
                    "Festival Detail",
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
              top: MediaQuery
                  .of(context)
                  .size
                  .height * 0.15,
              left: 16,
              right: 16,
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.95,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
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
                          readOnly: true,
                          controller: _festivalNameControler,
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
                                AppConstants.festivalNameFieldIcon,color: Color(0xFF8AC85A),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:Image.network(
                              "${AppConstants.festivalImageBaseUrl}" +
                                  (widget.festival.image ?? ""), // Provide a default empty string if null
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
                          height: 15,
                        ),
                        Text(
                          "Location (Lattitude / Longitude)",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _latitudeControler,

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
                          controller: _longitudeControler,
                          readOnly: true,
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

                                  Container(
                                    height: 70,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.45,
                                    child: TextFormField(
                                      readOnly: true,
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
                                            AppConstants.calendarIcon,color: Color(0xFF8AC85A),
                                          ),
                                        ),

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
                            SizedBox(width: 8,),
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
                                  Container(
                                    height: 70,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.42,
                                    child: TextFormField(
                                      readOnly: true,
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
                                            AppConstants.calendarIcon,color: Color(0xFF8AC85A),
                                          ),
                                        ),

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
                          height: MediaQuery
                              .of(context)
                              .size
                              .height *
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
readOnly:  true,
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
            // Positioned(
            //     top: MediaQuery
            //         .of(context)
            //         .size
            //         .height * 1.2,
            //     left: MediaQuery
            //         .of(context)
            //         .size
            //         .width * 0.1,
            //     right: MediaQuery
            //         .of(context)
            //         .size
            //         .width * 0.1,
            //     child: Container(
            //       width: MediaQuery
            //           .of(context)
            //           .size
            //           .width * 0.8,
            //       height: 50,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(16),
            //         color: Color(0xFF8AC85A),
            //       ),
            //       child: Center(
            //         child: Text(
            //           "Submit",
            //           style: TextStyle(
            //               fontFamily: "UbuntuBold",
            //               fontSize: 18,
            //               color: Colors.white),
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
