import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addFestival_api.dart';
import '../../../api/addToilet_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../data_model/toiletTypeCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import '../../../provider/toiletTypeCollection_provider.dart';
import '../../../utilities/utilities.dart';

class AddToiletView extends StatefulWidget {
  AddToiletView({super.key});

  @override
  State<AddToiletView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<AddToiletView> {
  final TextEditingController _dobControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _latFocusNode = FocusNode();
  final FocusNode _longFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  bool isLoading = false;
  XFile? _selectedImage;
  String? _selectedFestivalId;
  String? _selectedToiletId;

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
    _dobControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

  }
  @override
  void dispose() {
    _dobControler.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _latFocusNode.dispose();
    _longFocusNode.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.5 +
        MediaQuery.of(context).size.height *
            0.63 ; // Example: Height of welcome message Positioned child

    return totalHeight;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(height: calculateTotalHeight(context),),
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
                    "Add Toilet",
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
                height: MediaQuery.of(context).size.height * 0.95,
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
                      offset: Offset(
                          0, 4), // Optional: controls the position of the shadow
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
                          "Select Festival",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10,),
                        Consumer<FestivalProvider>(
                          builder: (context, festivalProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedFestivalId,
                              decoration: InputDecoration(
                                prefixIcon: SvgPicture.asset(
                                  AppConstants.dropDownPrefixIcon,color: Color(0xFF8AC85A),),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: festivalProvider.festivals
                                  .map((Festival festival) {
                                return DropdownMenuItem<String>(
                                  value: festival.id.toString(),
                                  // Store the festival ID here
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.6, // Set a max width
                                    ),
                                    child: Text(
                                      festival.nameOrganizer ?? "",
                                      // Display the festival name
                                      overflow: TextOverflow.ellipsis,
                                      // Manage overflow
                                      maxLines: 1, // Show only one line
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedFestivalId =
                                      newValue; // Save the selected festival ID
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

                        SizedBox(height: 10,),
                        Text(
                          "Toilet Category",
                          style:
                          TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Consumer<ToiletTypeProvider>(
                          builder: (context, toiletProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedToiletId,
                              decoration: InputDecoration(
                                prefixIcon: SvgPicture.asset(
                                  AppConstants.dropDownPrefixIcon,color: Color(0xFF8AC85A),),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: toiletProvider.toiletTypes
                                  .map((ToiletType toiletType) {
                                return DropdownMenuItem<String>(
                                  value: toiletType.id.toString(),
                                  // Store the festival ID here
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.6, // Set a max width
                                    ),
                                    child: Text(
                                      toiletType.name ?? "",
                                      // Display the festival name
                                      overflow: TextOverflow.ellipsis,
                                      // Manage overflow
                                      maxLines: 1, // Show only one line
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedToiletId =
                                      newValue; // Save the selected festival ID
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a toilet type';
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Upload Image",
                          style:
                          TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.2,
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
                                  ? SvgPicture.asset(AppConstants.addIcon,)
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
                        Text(
                          "Name",
                          style:
                          TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_latFocusNode);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "name",
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
                        Text(
                          "Location",
                          style:
                          TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _latitudeController,
                          focusNode: _latFocusNode,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter latitude';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_longFocusNode);
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
                          controller: _longitudeController,
                          focusNode: _longFocusNode,
                          textInputAction: TextInputAction.done,
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



                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height*1.12,
                left: MediaQuery.of(context).size.width*0.1,
                right: MediaQuery.of(context).size.width*0.1,
                child: GestureDetector(
                  onTap: ()async{
                    if(_formKey.currentState!.validate()){
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
                          String base64img = await convertImageToBase64(
                              _selectedImage);
                          addToilet(
                              context,
                              _selectedFestivalId??"",
                              _selectedToiletId??"",
                              _latitudeController.text,
                              _longitudeController.text,
                              base64img,
                            _nameController.text
                              );
                        } finally{

                        }
                        print('all ok danial');
                      }
                      print("tapped");
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFF015CB5), Color(0xFF00AAE1)],
                        stops: [0.0, 1.0], // 0% for the first color, 100% for the second color
                        begin: Alignment.centerLeft, // Start from the left side
                        end: Alignment.centerRight,  // End at the right side
                      ),
                    ),
                    child: Center(child: Text("Submit",style: TextStyle(fontFamily: "UbuntuBold",fontSize: 18,color: Colors.white),),),
                  ),
                )
            ),
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