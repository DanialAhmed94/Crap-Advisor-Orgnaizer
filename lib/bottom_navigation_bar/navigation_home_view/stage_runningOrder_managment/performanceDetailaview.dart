import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addPerformance.dart';
import '../../../api/updatePerformance_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../data_model/performanceCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';

class PerformanceDetailView extends StatefulWidget {
  final Performance performance;

  PerformanceDetailView({required this.performance});

  @override
  State<PerformanceDetailView> createState() => _PerformanceDetailViewState();
}

class _PerformanceDetailViewState extends State<PerformanceDetailView> {
  bool _isloading = false;
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();
  // Controllers
  late TextEditingController _festivalNameController;
  late TextEditingController _eventNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _endTimeController;
  late TextEditingController _startTimeController;
  late TextEditingController _bandController;
  late TextEditingController _performanceController;
  late TextEditingController _artistController;
  late TextEditingController _participantsController;
  late TextEditingController _guestsController;
  late TextEditingController _lightingController;
  late TextEditingController _soundController;
  late TextEditingController _stageSetupController;
  late TextEditingController _transitionController;
  late TextEditingController _specialNotesController;

  // FocusNodes
  final _focusNodeSpecialNotes = FocusNode();
  final _performanceFocusNode = FocusNode();
  final _bandFocusNode = FocusNode();
  final _artistFocusNode = FocusNode();
  final _participantsFocusNode = FocusNode();
  final _guestsFocusNode = FocusNode();
  final _focusNodeTransition = FocusNode();
  final _focusNodeLighting = FocusNode();
  final _focusNodeSound = FocusNode();
  final _focusNodeStageSetup = FocusNode();

  @override
  void initState() {
    super.initState();
    _festivalNameController = TextEditingController(
        text: widget.performance.festival?.nameOrganizer ?? "");
    _eventNameController =
        TextEditingController(text: widget.performance.event?.eventTitle ?? "");
    _startDateController =
        TextEditingController(text: widget.performance.startDate ?? "");
    _endDateController =
        TextEditingController(text: widget.performance.endDate ?? "");
    _endTimeController =
        TextEditingController(text: widget.performance.endTime ?? "");
    _startTimeController =
        TextEditingController(text: widget.performance.startTime ?? "");
    _bandController =
        TextEditingController(text: widget.performance.bandName ?? "");
    _performanceController =
        TextEditingController(text: widget.performance.performanceTitle ?? "");
    _artistController =
        TextEditingController(text: widget.performance.artistName ?? "");
    _participantsController =
        TextEditingController(text: widget.performance.participantName ?? "");
    _guestsController =
        TextEditingController(text: widget.performance.specialGuests ?? "");
    _lightingController = TextEditingController(
        text: widget.performance.technicalRequirementLighting ?? "");
    _soundController = TextEditingController(
        text: widget.performance.technicalRequirementSound ?? "");
    _stageSetupController = TextEditingController(
        text: widget.performance.technicalRequirementStageSetup ?? "");
    _transitionController =
        TextEditingController(text: widget.performance.transitionDetail ?? "");
    _specialNotesController = TextEditingController(
        text: widget.performance.technicalRequirementSpecialNotes ?? "");
  }

  @override
  void dispose() {
    _festivalNameController.dispose();
    _eventNameController.dispose();
    _endDateController.dispose();
    _performanceController.dispose();
    _performanceFocusNode.dispose();
    _specialNotesController.dispose();
    _focusNodeSpecialNotes.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _lightingController.dispose();
    _soundController.dispose();
    _stageSetupController.dispose();
    _transitionController.dispose();
    _focusNodeTransition.dispose();
    _focusNodeLighting.dispose();
    _focusNodeSound.dispose();
    _focusNodeStageSetup.dispose();
    _participantsFocusNode.dispose();
    _participantsController.dispose();
    _artistController.dispose();
    _bandController.dispose();
    _startDateController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  String? _validateParticipantsNames(String? value) {
    if (!_isEditMode) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter a short description';
    }
    return null;
  }

  Future<void> _pickStartDate() async {
    DateTime initialDate = DateTime.now();
    if (_startDateController.text.isNotEmpty) {
      DateTime? parsedDate = DateTime.tryParse(_startDateController.text);
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
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime initialDate = DateTime.now();
    if (_endDateController.text.isNotEmpty) {
      DateTime? parsedDate = DateTime.tryParse(_endDateController.text);
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
        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  AppBar(
                    centerTitle: true,
                    title: Text(
                      "Performance Detail",
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
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4.0,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        // This Column contains all your read-only fields as before
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
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
                            GestureDetector(
                              onTap: _isEditMode? (){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Festival name and event name can not be edited.",
                                      style: TextStyle(fontFamily: "Ubuntu"),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }: null,
                              child: AbsorbPointer(
                                child: buildReadOnlyField(
                                    "Festival Name", _festivalNameController,
                                    icon: AppConstants.dropDownPrefixIcon),
                              ),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: _isEditMode? (){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Festival name and event name can not be edited.",
                                      style: TextStyle(fontFamily: "Ubuntu"),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }: null,
                              child: AbsorbPointer(
                                child: buildReadOnlyField("Event Name", _eventNameController,
                                    icon: AppConstants.dropDownPrefixIcon),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Start Date",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              controller: _startDateController,
                              onTap: _isEditMode ? _pickStartDate : null,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 30.0,
                                  minHeight: 30.0,
                                ),
                                prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
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
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "End Date",
                              style: TextStyle(
                                  fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              controller: _endDateController,
                              onTap: _isEditMode ? _pickEndDate : null,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 30.0,
                                  minHeight: 30.0,
                                ),
                                prefixIcon: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
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
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),
                            // Performance Title Field
                            buildReadOnlyField(
                              "Performance Title",
                              _performanceController,
                              icon: AppConstants.performanceTitleIcon,
                              readOnly: !_isEditMode,
                              validator: (value) {
                                if (!_isEditMode) return null; // Skip validation if not in edit mode
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the performance title';
                                }
                                return null;
                              },
                            ),
                            buildReadOnlyField(
                              "Artist",
                              _artistController,
                              icon: AppConstants.artistTitleIcon,
                              readOnly: !_isEditMode,
                              validator: (value) {
                                if (!_isEditMode) return null;
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the artist name';
                                }
                                return null;
                              },
                            ),
                            Text(
                              "Participants",
                              style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                            ),
                            SizedBox(height: 10),
                            buildMultilineField(
                              _participantsController,
                              validator: (value) {
                                if (!_isEditMode) return null;
                                if (value == null || value.isEmpty) {
                                  return 'Please enter participant names';
                                }
                                return null;
                              },
                              readOnly: !_isEditMode,
                            ),
                            buildReadOnlyField(
                              "Special Guests",
                              _guestsController,
                              icon: AppConstants.specialGuestsTitleIcon,
                              readOnly: !_isEditMode,
                            ),
                            SizedBox(height: 10),
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
                                      Container(
                                        height: 70,
                                        child: TextFormField(
                                          readOnly: true,
                                          onTap: _isEditMode
                                              ? () => _selectTime(
                                                  context, _startTimeController)
                                              : null,
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
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                  AppConstants.timer1Icon,
                                                  color: Color(0xFF8AC85A)),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
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
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
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
                                      Container(
                                        height: 70,
                                        child: TextFormField(
                                          readOnly: true,
                                          onTap: _isEditMode
                                              ? () => _selectTime(
                                                  context, _endTimeController)
                                              : null,
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
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: SvgPicture.asset(
                                                  AppConstants.timerIcon,
                                                  color: Color(0xFF8AC85A)),
                                            ),
                                            suffixIcon:
                                                Icon(Icons.arrow_drop_down_sharp),
                                            filled: true,
                                            fillColor: Colors.white,
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
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        // Positioned widget for the Edit button at the top-right corner
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
                  ),
                  SizedBox(height: 20),
                  // Notes Container
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Notes",
                          style: TextStyle(
                            fontFamily: "UbuntuBold",
                            fontSize: 22,
                            color: Color(0xFF8AC85A),
                          ),
                        ),
                        SizedBox(height: 20),
                        buildMultilineField(
                          _specialNotesController,
                          readOnly: !_isEditMode,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  if (_isEditMode)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      width: double.infinity,
                      child: GestureDetector(
                       onTap: _handleSubmit, // Ensure this function is implemented
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
          ),
          SizedBox(height: 10),
          if (_isloading)
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
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isloading = true;
      });

      try {
        // Call your API or perform update operations here
         await updatePerformance(
          context,
          widget.performance.id.toString(),
          widget.performance.festivalId.toString(),
          _startDateController.text,
          _endDateController.text,
          _performanceController.text,
          _bandController.text,
          _artistController.text,
          _participantsController.text,
          _guestsController.text,
          _startTimeController.text,
          _endTimeController.text,
          _lightingController.text,
          _soundController.text,
          _stageSetupController.text,
          _transitionController.text,
          _specialNotesController.text,
          widget.performance.event!.id.toString()
        );



        // Exit edit mode
        setState(() {
          _isEditMode = false;
        });
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update performance.',
              style: TextStyle(fontFamily: "Ubuntu"),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isloading = false;
        });
      }
    } else {
      // If validation fails, you can optionally show a general error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fix the errors in red before submitting.',
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget buildReadOnlyField(
      String label,
      TextEditingController controller, {
        String? icon,
        double height = 60,
        bool readOnly = true,
        String? Function(String?)? validator, // Add this parameter
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
        ),
        SizedBox(height: 10),
        Container(
          height: height,
          child: TextFormField(
            readOnly: readOnly,
            controller: controller,
            validator: validator, // Assign the validator
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
        ),
      ],
    );
  }


  Widget buildMultilineField(
      TextEditingController controller, {
        String? Function(String?)? validator,
        bool readOnly = true,
      }) {
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

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../api/addPerformance.dart';
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/festivalCollection_model.dart';
// import '../../../data_model/performanceCollection_model.dart';
// import '../../../provider/festivalCollection_provider.dart';
//
// class PerformanceDetailView extends StatefulWidget {
//   final Performance performance;
//   PerformanceDetailView({required this.performance});
//
//   @override
//   State<PerformanceDetailView> createState() => _PerformanceDetailViewState();
// }
//
// class _PerformanceDetailViewState extends State<PerformanceDetailView> {
//   bool _isloading = false;
//
//   // Controllers
//   late TextEditingController _festivalNameController;
//   late TextEditingController _eventNameController;
//   late TextEditingController _startDateController;
//   late TextEditingController _endDateController;
//   late TextEditingController _endTimeController;
//   late TextEditingController _startTimeController;
//   late TextEditingController _bandController;
//   late TextEditingController _performanceController;
//   late TextEditingController _artistController;
//   late TextEditingController _participantsController;
//   late TextEditingController _guestsController;
//   late TextEditingController _lightingController;
//   late TextEditingController _soundController;
//   late TextEditingController _stageSetupController;
//   late TextEditingController _transitionController;
//   late TextEditingController _specialNotesController;
//
//   // FocusNodes
//   final _focusNodeSpecialNotes = FocusNode();
//   final _performanceFocusNode = FocusNode();
//   final _bandFocusNode = FocusNode();
//   final _artistFocusNode = FocusNode();
//   final _participantsFocusNode = FocusNode();
//   final _guestsFocusNode = FocusNode();
//   final _focusNodeTransition = FocusNode();
//   final _focusNodeLighting = FocusNode();
//   final _focusNodeSound = FocusNode();
//   final _focusNodeStageSetup = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     _festivalNameController = TextEditingController(
//         text: widget.performance.festival?.nameOrganizer ?? "");
//     _eventNameController =
//         TextEditingController(text: widget.performance.event?.eventTitle ?? "");
//     _startDateController = TextEditingController(
//         text: widget.performance.startDate ?? "");
//     _endDateController =
//         TextEditingController(text: widget.performance.endDate ?? "");
//     _endTimeController =
//         TextEditingController(text: widget.performance.endTime ?? "");
//     _startTimeController =
//         TextEditingController(text: widget.performance.startTime ?? "");
//     _bandController =
//         TextEditingController(text: widget.performance.bandName ?? "");
//     _performanceController =
//         TextEditingController(text: widget.performance.performanceTitle ?? "");
//     _artistController =
//         TextEditingController(text: widget.performance.artistName ?? "");
//     _participantsController =
//         TextEditingController(text: widget.performance.participantName ?? "");
//     _guestsController =
//         TextEditingController(text: widget.performance.specialGuests ?? "");
//     _lightingController = TextEditingController(
//         text: widget.performance.technicalRequirementLighting ?? "");
//     _soundController = TextEditingController(
//         text: widget.performance.technicalRequirementSound ?? "");
//     _stageSetupController = TextEditingController(
//         text: widget.performance.technicalRequirementStageSetup ?? "");
//     _transitionController =
//         TextEditingController(text: widget.performance.transitionDetail ?? "");
//     _specialNotesController = TextEditingController(
//         text: widget.performance.technicalRequirementSpecialNotes ?? "");
//   }
//
//   @override
//   void dispose() {
//     _festivalNameController.dispose();
//     _eventNameController.dispose();
//     _endDateController.dispose();
//     _performanceController.dispose();
//     _performanceFocusNode.dispose();
//     _specialNotesController.dispose();
//     _focusNodeSpecialNotes.dispose();
//     _startTimeController.dispose();
//     _endTimeController.dispose();
//     _lightingController.dispose();
//     _soundController.dispose();
//     _stageSetupController.dispose();
//     _transitionController.dispose();
//     _focusNodeTransition.dispose();
//     _focusNodeLighting.dispose();
//     _focusNodeSound.dispose();
//     _focusNodeStageSetup.dispose();
//     _participantsFocusNode.dispose();
//     _participantsController.dispose();
//     _artistController.dispose();
//     _bandController.dispose();
//     _startDateController.dispose();
//     _guestsController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               AppConstants.planBackground,
//               fit: BoxFit.cover,
//             ),
//           ),
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: 10),
//                 AppBar(
//                   centerTitle: true,
//                   title: Text(
//                     "Performance Detail",
//                     style: TextStyle(
//                       fontFamily: "Ubuntu",
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   leading: IconButton(
//                     icon: SvgPicture.asset(AppConstants.greenBackIcon),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                 ),
//                 SizedBox(height: 20),
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.25),
//                       blurRadius: 4.0,
//                       spreadRadius: 0,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.all(16.0),
//                 child: Stack(
//                   children: [
//                     // This Column contains all your read-only fields as before
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 20),
//                         buildReadOnlyField("Festival Name", _festivalNameController,
//                             icon: AppConstants.dropDownPrefixIcon),
//                         SizedBox(height: 20),
//                         buildReadOnlyField("Event Name", _eventNameController,
//                             icon: AppConstants.dropDownPrefixIcon),
//                         SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildReadOnlyField(
//                                 "Start Date",
//                                 _startDateController,
//                                 icon: AppConstants.calendarIcon,
//                                 height: 70,
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: buildReadOnlyField(
//                                 "End Date",
//                                 _endDateController,
//                                 icon: AppConstants.calendarIcon,
//                                 height: 70,
//                               ),
//                             ),
//                           ],
//                         ),
//                         buildReadOnlyField(
//                           "Performance Title",
//                           _performanceController,
//                           icon: AppConstants.performanceTitleIcon,
//                         ),
//                         buildReadOnlyField(
//                           "Artist",
//                           _artistController,
//                           icon: AppConstants.artistTitleIcon,
//                         ),
//                         buildMultilineReadOnlyField(
//                           "Participantes Names",
//                           _participantsController,
//                           "Enter names...",
//                         ),
//                         buildReadOnlyField(
//                           "Special Guests",
//                           _guestsController,
//                           icon: AppConstants.specialGuestsTitleIcon,
//                         ),
//                         SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: buildReadOnlyField(
//                                 "Start Time",
//                                 _startTimeController,
//                                 icon: AppConstants.timer1Icon,
//                                 height: 70,
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: buildReadOnlyField(
//                                 "End Time",
//                                 _endTimeController,
//                                 icon: AppConstants.timerIcon,
//                                 height: 70,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//
//                     // Positioned widget for the Edit button at the top-right corner
//                     Positioned(
//                       top: 10,
//                       right: 10,
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
//               ),
//                 SizedBox(height: 20),
//                 // Notes Container
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 80.0,
//                         spreadRadius: 0,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Notes",
//                         style: TextStyle(
//                           fontFamily: "UbuntuBold",
//                           fontSize: 22,
//                           color: Color(0xFF8AC85A),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       buildMultilineReadOnlyField(
//                         "",
//                         _specialNotesController,
//                         "notes...",
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 // Edit Button
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//           if (_isloading)
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
//
//   Widget buildReadOnlyField(String label, TextEditingController controller,
//       {String? icon, double height = 60}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 10),
//         Text(
//           label,
//           style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
//         ),
//         SizedBox(height: 10),
//         Container(
//           height: height,
//           child: TextFormField(
//             readOnly: true,
//             controller: controller,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               prefixIconConstraints: BoxConstraints(
//                 minWidth: 30.0,
//                 minHeight: 30.0,
//               ),
//               prefixIcon: icon != null
//                   ? Padding(
//                 padding: const EdgeInsets.only(left: 8, right: 8),
//                 child: SvgPicture.asset(icon, color: Color(0xFF8AC85A)),
//               )
//                   : null,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25.0),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30.0),
//                 borderSide: BorderSide.none,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30.0),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildMultilineReadOnlyField(
//       String label, TextEditingController controller, String hint) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label.isNotEmpty) ...[
//           SizedBox(height: 10),
//           Text(
//             label,
//             style: TextStyle(
//               color: Color(0xFF0A0909),
//               fontFamily: "UbuntuMedium",
//               fontSize: 15,
//             ),
//           ),
//           SizedBox(height: 10),
//         ],
//         Container(
//           height: MediaQuery.of(context).size.height * 0.2,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.25),
//                 blurRadius: 4.0,
//                 spreadRadius: 0,
//                 offset: Offset(0, 4),
//               ),
//             ],
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           child: TextFormField(
//             readOnly: true,
//             controller: controller,
//             maxLines: null,
//             expands: true,
//             keyboardType: TextInputType.multiline,
//             textAlignVertical: TextAlignVertical.top,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 16.0,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: EdgeInsets.all(16.0),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             onFieldSubmitted: (_) {
//               FocusScope.of(context).unfocus();
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
//
//
