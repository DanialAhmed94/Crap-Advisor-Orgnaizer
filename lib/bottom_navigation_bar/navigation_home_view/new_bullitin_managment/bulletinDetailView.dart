import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../api/updateBulletin_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/bulletinCollection_model.dart';

class BulletinDetailView extends StatefulWidget {
  final Bulletin bulletin;
  BulletinDetailView({required this.bulletin});

  @override
  State<BulletinDetailView> createState() => _BulletinDetailViewState();
}

class _BulletinDetailViewState extends State<BulletinDetailView> {
  late TextEditingController _dobController;
  late TextEditingController _titleController;
  late TextEditingController _startTimeController;
  late TextEditingController _contentController;

  bool _isPublished = false;
  bool _isEmpty = true;
  bool _isLoading = false;
  bool _isEditMode = false;

  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dobController = TextEditingController(text: "${widget.bulletin.date}");
    _titleController = TextEditingController(text: "${widget.bulletin.title}");
    _startTimeController = TextEditingController(text: "${widget.bulletin.time}");
    _contentController = TextEditingController(text: "${widget.bulletin.content}");

    // Determine if published now based on bulletin data
    _isPublished = widget.bulletin.publishNow.toString() == "1";

    // Check if content is empty or not
    _isEmpty = _contentController.text.isEmpty;

    _contentController.addListener(() {
      setState(() {
        _isEmpty = _contentController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    _contentController.dispose();
    _titleController.dispose();
    _startTimeController.dispose();
    _contentFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });

  }

  Future<void> _pickDate() async {
    if (!_isEditMode) return;
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime() async {
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

  Future<void> _updateBulletin() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields correctly.',
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Perform the API call to update the bulletin here.

      await updateBulletin(
        context,
         widget.bulletin.id.toString(),
         _titleController.text.trim(),
        _contentController.text.trim(),
        _isPublished ,
       _startTimeController.text.trim(),
        _dobController.text.trim(),

      );



      // Once updated successfully, disable edit mode and update UI
      setState(() {
        _isEditMode = false;
        _titleController.text = widget.bulletin.title.toString();
        _contentController.text  = widget.bulletin.content.toString();
   _dobController.text = widget.bulletin.date.toString();
        _startTimeController.text =   widget.bulletin.time .toString();
        _isPublished = widget.bulletin.publishNow == "1";
      });


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update bulletin. Please try again.',
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEditable = _isEditMode;
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
         SizedBox(
           height: MediaQuery.of(context).size.height,
           width: MediaQuery.of(context).size.width,
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
                // App Bar
                AppBar(
                  centerTitle: true,
                  title: Text(
                    "Bulletin Detail",
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

                // Stack for Edit button and details container
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
                            Text(
                              "Title",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _titleController,
                              readOnly: !isEditable,
                              focusNode: _titleFocusNode,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
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
                                    readOnly: !isEditable,
                                    controller: _contentController,
                                    focusNode: _contentFocusNode,
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
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter some content';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_isEmpty && !isEditable)
                                    Center(
                                      child: SvgPicture.asset(
                                        AppConstants.bulletinContentIcon,
                                        color: Color(0xFF8AC85A),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Schedule Options",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: _isPublished,
                                    onChanged: isEditable ? (bool? value) {
                                      setState(() {
                                        _isPublished = value ?? false;
                                      });
                                    } : null,
                                  ),
                                  Text(
                                    'Publish Now',
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                    ),
                                  ),
                                  Spacer(),
                                  Radio<bool>(
                                    value: false,
                                    groupValue: _isPublished,
                                    onChanged: isEditable ? (bool? value) {
                                      setState(() {
                                        _isPublished = value ?? false;
                                      });
                                    } : null,
                                  ),
                                  Text(
                                    'Publish Later',
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
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
                                        "Time",
                                        style: TextStyle(
                                            color: Color(0xFF0A0909),
                                            fontFamily: "UbuntuMedium",
                                            fontSize: 15),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        onTap: _isEditMode ? _pickTime : null,
                                        readOnly: true,
                                        controller: _startTimeController,
                                        validator: (value) {
                                          if (!_isPublished && (value == null || value.trim().isEmpty)) {
                                            return 'Please select a time when publishing later';
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
                                              color: Color(0xFF8AC85A),
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
                                      Text(
                                        "Date",
                                        style: TextStyle(
                                            color: Color(0xFF0A0909),
                                            fontFamily: "UbuntuMedium",
                                            fontSize: 15),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        onTap: _isEditMode ? _pickDate : null,

                                        readOnly: true,
                                        style: TextStyle(fontSize: 14.0),
                                        controller: _dobController,
                                        validator: (value) {
                                          if (!_isPublished && (value == null || value.trim().isEmpty)) {
                                            return 'Please select a date when publishing later';
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
                                              AppConstants.calendarIcon,
                                              color: Color(0xFF8AC85A),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: "Select Date",
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    if (!isEditable)
                      Positioned(
                        top: 3,
                        right: 22,
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
                      onTap: _updateBulletin,
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
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: IgnorePointer(
                    ignoring: true,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
//
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/bulletinCollection_model.dart';
//
// class BulletinDetailView extends StatefulWidget {
//   final Bulletin bulletin;
//   BulletinDetailView({required this.bulletin});
//
//   @override
//   State<BulletinDetailView> createState() => _BulletinDetailViewState();
// }
//
// class _BulletinDetailViewState extends State<BulletinDetailView> {
//   late TextEditingController _dobControler;
//   late TextEditingController _titleControler;
//   late TextEditingController _startTimeController;
//   late TextEditingController _contentControler;
//
//   bool _isPublished = false;
//   final FocusNode _titleFousNode = FocusNode();
//   final FocusNode _contentFocusNode = FocusNode();
//   bool _isEmpty = true;
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _dobControler = TextEditingController(text: "${widget.bulletin.date}");
//     _titleControler = TextEditingController(text: "${widget.bulletin.title}");
//     _startTimeController = TextEditingController(text: "${widget.bulletin.time}");
//     _contentControler = TextEditingController(text: "${widget.bulletin.content}");
//
//     // Determine if published now based on bulletin data
//     _isPublished = widget.bulletin.publishNow.toString() == "1";
//
//     // Check if content is empty or not
//     _isEmpty = _contentControler.text.isEmpty;
//   }
//
//   @override
//   void dispose() {
//     _dobControler.dispose();
//     _contentControler.dispose();
//     _titleControler.dispose();
//     _startTimeController.dispose();
//     _contentFocusNode.dispose();
//     _titleFousNode.dispose();
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
//                     "Bulletin Detail",
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
//
//                 // Stack for Edit button and details container
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
//                             offset: Offset(0,4),
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
//                               "Title",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               controller: _titleControler,
//                               readOnly: true,
//                               focusNode: _titleFousNode,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a title';
//                                 }
//                                 return null;
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 prefixIconConstraints: BoxConstraints(
//                                   minWidth: 10.0,
//                                   minHeight: 10.0,
//                                 ),
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.only(left: 8, right: 8),
//                                   child: SvgPicture.asset(
//                                     AppConstants.bulletinTitleIcon,
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
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Content",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             Container(
//                               height: MediaQuery.of(context).size.height * 0.25,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.25),
//                                     blurRadius: 4.0,
//                                     spreadRadius: 0,
//                                     offset: Offset(0, 4),
//                                   ),
//                                 ],
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   TextFormField(
//                                     readOnly: true,
//                                     controller: _contentControler,
//                                     focusNode: _contentFocusNode,
//                                     maxLines: null,
//                                     expands: true,
//                                     keyboardType: TextInputType.multiline,
//                                     textAlignVertical: TextAlignVertical.top,
//                                     decoration: InputDecoration(
//                                       hintText: 'enter content of the bulletin...',
//                                       hintStyle: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: 16.0,
//                                       ),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10.0),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       contentPadding: EdgeInsets.all(16.0),
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter a description';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   if (_isEmpty)
//                                     Center(
//                                       child: SvgPicture.asset(
//                                         AppConstants.bulletinContentIcon,
//                                         color: Color(0xFF8AC85A),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Schedule Options",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium",
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 10),
//                             Container(
//                               width: double.infinity,
//                               height: 45,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(100),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Radio(
//                                     value: true,
//                                     groupValue: _isPublished,
//                                     onChanged: (bool? value) {
//                                       setState(() {
//                                         _isPublished = value ?? false;
//                                       });
//                                     },
//                                   ),
//                                   Text(
//                                     'Publish Now',
//                                     style: TextStyle(
//                                       fontFamily: "UbuntuMedium",
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Time",
//                                         style: TextStyle(
//                                             color: Color(0xFF0A0909),
//                                             fontFamily: "UbuntuMedium",
//                                             fontSize: 15),
//                                       ),
//                                       SizedBox(height: 10),
//                                       Container(
//                                         height: 70,
//                                         child: TextFormField(
//                                           readOnly: true,
//                                           controller: _startTimeController,
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints: BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(left: 8, right: 8),
//                                               child: SvgPicture.asset(
//                                                 AppConstants.timer1Icon,
//                                                 color: Color(0xFF8AC85A),
//                                               ),
//                                             ),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(25.0),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Date",
//                                         style: TextStyle(
//                                             color: Color(0xFF0A0909),
//                                             fontFamily: "UbuntuMedium",
//                                             fontSize: 15),
//                                       ),
//                                       SizedBox(height: 10),
//                                       Container(
//                                         height: 70,
//                                         child: TextFormField(
//                                           readOnly: true,
//                                           style: TextStyle(fontSize: 14.0),
//                                           controller: _dobControler,
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints: BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(left: 8, right: 8),
//                                               child: SvgPicture.asset(
//                                                 AppConstants.calendarIcon,
//                                                 color: Color(0xFF8AC85A),
//                                               ),
//                                             ),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             hintText: "Longitude",
//                                             hintStyle: TextStyle(
//                                                 color: Color(0xFFA0A0A0),
//                                                 fontFamily: "UbuntuMedium",
//                                                 fontSize: 15),
//                                             border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(25.0),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 10),
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
//           if (_isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: Center(
//                   child: IgnorePointer(
//                     ignoring: true,
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
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
