import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../api/addBuletin.dart';
import '../../../constants/AppConstants.dart';

class AddNewsBulletinView extends StatefulWidget {
  AddNewsBulletinView({super.key});

  @override
  State<AddNewsBulletinView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<AddNewsBulletinView> {
  final TextEditingController _dobControler = TextEditingController();
  TextEditingController _contentControler = TextEditingController();
  TextEditingController _titleControler = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();

  FocusNode _titleFousNode = FocusNode();
  FocusNode _contentFocusNode = FocusNode();
  bool _isEmpty = true;
  bool isSelected = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
    _dobControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _startTimeController.text = DateFormat('HH:mm:ss').format(DateTime.now());

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
    _dobControler.dispose();
    _contentControler.dispose();
    _titleControler.dispose();
    _startTimeController.dispose();
    _contentFocusNode.dispose();
    _titleFousNode.dispose();
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.55; // Example: Height of welcome message Positioned child

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
                    "Add News Bulletin",
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
                height: MediaQuery.of(context).size.height * 0.709,
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
                          "Title",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _titleControler,
                          focusNode: _titleFousNode,
                          onTap: () {
                            FocusScope.of(context).requestFocus(_titleFousNode);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
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
                                controller: _contentControler,
                                focusNode: _contentFocusNode,
                                onTap: () {
                                  FocusScope.of(context).requestFocus(_contentFocusNode);
                                },
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'enter content of the bulletin...',
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
                        Text(
                          "Schedule Options",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium",
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Radio(
                                value: true,
                                groupValue: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isSelected = value!;
                                  });
                                },
                              ),
                              Text(
                                'Publish Now',
                                style: TextStyle(
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                ),
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
                                    "Time",
                                    style: TextStyle(
                                        color: Color(0xFF0A0909),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () => _selectTime(
                                        context, _startTimeController),
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: TextFormField(
                                          controller: _startTimeController,
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
                                                AppConstants.timer1Icon,
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
                                    "Date",
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
                                          _dobControler.text = pickedDate
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
                                          style: TextStyle(fontSize: 14.0),
                                          controller: _dobControler,
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
                                              ),
                                            ),
                                            suffixIcon: Icon(
                                                Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Longitude",
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
                top: MediaQuery.of(context).size.height * 0.873,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (FocusScope.of(context).hasFocus) {
                      return; // Do not proceed if any text field is focused
                    }
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      addBulletin(
                          context,
                          _titleControler.text,
                          _contentControler.text,
                          isSelected,
                          _startTimeController.text,
                          _dobControler.text);

                      _titleControler.clear();
                      _contentControler.clear();
                      _startTimeController.clear();
                      _dobControler.clear();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFF015CB5), Color(0xFF00AAE1)],
                        stops: [0.0, 1.0],
                        // 0% for the first color, 100% for the second color
                        begin: Alignment.centerLeft,
                        // Start from the left side
                        end: Alignment.centerRight, // End at the right side
                      ),
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
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54, // Semi-transparent background
                  child: Center(
                    child: IgnorePointer(
                        ignoring: true,
                        child: CircularProgressIndicator(
                        )),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
