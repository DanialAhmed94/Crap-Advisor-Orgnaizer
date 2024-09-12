import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addPerformance.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../data_model/performanceCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';

class PerformanceDetailView extends StatefulWidget {
  late Performance performance;
  PerformanceDetailView({required this.performance});

  @override
  State<PerformanceDetailView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<PerformanceDetailView> {
  final TextEditingController _dobControler = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  String? _selectedItem;
  bool _isloading = false;

  String? _selectedFestivalId;

// Define TextEditingControllers
  late TextEditingController _endTimeController;
  late TextEditingController _festivalNameController;
  late TextEditingController _startTimeController ;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _bandController ;
  late TextEditingController _performanceController ;
  late TextEditingController _artistController ;
  late TextEditingController _participantsController ;
  late TextEditingController _guestsController ;
  late TextEditingController _lightingController ;
  late TextEditingController _soundController ;
  late TextEditingController _stageSetupController;
  late TextEditingController _transitionController ;
  late TextEditingController _specialNotesController ;

  // FocusNodes to handle focus navigation between fields
  final _focusNodeSpecialNotes = FocusNode();
  final _focusNodeTransition = FocusNode();
  final _focusNodeLighting = FocusNode();
  final _focusNodeSound = FocusNode();
  final _focusNodeStageSetup = FocusNode();
  final _performanceFocusNode = FocusNode();
  final _bandFocusNode = FocusNode();
  final _artistFocusNode = FocusNode();
  final _participantsFocusNode = FocusNode();
  final _guestsFocusNode = FocusNode();

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
    _festivalNameController = TextEditingController(
        text: widget.performance.festival?.nameOrganizer ?? ""
    );
    _startDateController = TextEditingController(text: "${widget.performance.startDate ??""}");
    _endDateController = TextEditingController(text: "${widget.performance.endDate??""}");
    _endTimeController= TextEditingController(text: "${widget.performance.endTime}"??"");
    _startTimeController= TextEditingController(text: "${widget.performance.startTime??""}");
    _bandController= TextEditingController(text: "${widget.performance.bandName}");
    _performanceController= TextEditingController(text: "${widget.performance.performanceTitle??""}");
    _artistController= TextEditingController(text: "${widget.performance.artistName}");
    _participantsController= TextEditingController(text: "${widget.performance.participantName??""}");
    _guestsController= TextEditingController(text: "${widget.performance.specialGuests??""}");
    _lightingController= TextEditingController(text: "${widget.performance.technicalRequirementLighting??""}");
    _soundController= TextEditingController(text: "${widget.performance.technicalRequirementSound??""}");
    _stageSetupController= TextEditingController(text: "${widget.performance.technicalRequirementStageSetup??""}");
    _transitionController= TextEditingController(text: "${widget.performance.transitionDetail??""}");
    _specialNotesController= TextEditingController(text: "${widget.performance.technicalRequirementSpecialNotes??""}");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _festivalNameController.dispose();
    _endDateController.dispose();
    _endDateController.dispose();
    _performanceController.dispose();
    _performanceFocusNode.dispose();
    _specialNotesController.dispose();
    _focusNodeSpecialNotes.dispose();
    _dobControler.dispose();
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
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height * 0.58 +
        MediaQuery.of(context).size.height * 0.9 +
        MediaQuery.of(context).size.height * 0.8;

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
                fit: BoxFit.cover,
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
                    "Performance Detail",
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
              top: MediaQuery.of(context).size.height * 0.15,
              left: 16,
              right: 16,
              child: Container(
                height: MediaQuery.of(context).size.height * 1.2,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      // Shadow color with 4% opacity
                      blurRadius: 4.0,
                      // Adjust the blur radius for desired blur effect
                      spreadRadius: 0,
                      // Optional: controls the size of the shadow spread
                      offset: Offset(0,
                          4), // Optional: controls the position of the shadow
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey1,
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

                          controller: _festivalNameController,
                          focusNode: _performanceFocusNode,
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

                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_bandFocusNode);
                          },
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
                                    MediaQuery.of(context).size.width *
                                        0.45,
                                    child: TextFormField(
                                      readOnly: true,

                                      controller: _startDateController,
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
                                    MediaQuery.of(context).size.width *
                                        0.42,
                                    child: TextFormField(
                                      controller: _endDateController,
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
                          "Performance Title",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,

                          controller: _performanceController,
                          focusNode: _performanceFocusNode,
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
                                AppConstants.performanceTitleIcon,color: Color(0xFF8AC85A),),
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

                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_bandFocusNode);
                          },
                        ),
                        SizedBox(height: 10),
                        Text("Band",
                            style: TextStyle(
                                fontFamily: "UbuntuMedium", fontSize: 15)),
                        SizedBox(height: 10),
                        TextFormField(
                          readOnly: true,

                          controller: _bandController,
                          focusNode: _bandFocusNode,
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
                                AppConstants.artistTitleIcon,color: Color(0xFF8AC85A),),
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

                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_artistFocusNode);
                          },
                        ),
                        SizedBox(height: 10),
                        Text("Artist",
                            style: TextStyle(
                                fontFamily: "UbuntuMedium", fontSize: 15)),
                        SizedBox(height: 10),
                        TextFormField(
                          readOnly: true,

                          controller: _artistController,
                          focusNode: _artistFocusNode,
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
                                AppConstants.artistTitleIcon,color: Color(0xFF8AC85A),
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

                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_participantsFocusNode);
                          },
                        ),
                        SizedBox(height: 10),
                        Text("Participantes Names",
                            style: TextStyle(
                                color: Color(0xFF0A0909),
                                fontFamily: "UbuntuMedium",
                                fontSize: 15)),
                        SizedBox(height: 10),
                        Container(
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
                            readOnly: true,

                            controller: _participantsController,
                            focusNode: _participantsFocusNode,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Enter names...',
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

                            textInputAction: TextInputAction.done,
                            // Complete with Done action
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss the keyboard
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Special Guests",
                            style: TextStyle(
                                fontFamily: "UbuntuMedium", fontSize: 15)),
                        SizedBox(height: 10),
                        TextFormField(
                          readOnly: true,

                          controller: _guestsController,
                          focusNode: _guestsFocusNode,
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
                                AppConstants.specialGuestsTitleIcon,color: Color(0xFF8AC85A),),
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
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter special guests';
                          //   }
                          //   return null;
                          // },
                          onFieldSubmitted: (_) {
                            // When the user submits the last field, you can add logic here
                            FocusScope.of(context)
                                .unfocus(); // Dismiss the keyboard
                          },
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
                                            AppConstants.timer1Icon,color: Color(0xFF8AC85A),),
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
                                      controller: _endTimeController,
                                      readOnly: true,

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
                                            AppConstants.timerIcon,color: Color(0xFF8AC85A),),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 1.38,
              left: 16,
              right: 16,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.43,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    // Add a FormKey if needed to control the state of the Form
                    key: _formKey2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Technical Requirements",
                          style: TextStyle(
                            fontFamily: "UbuntuBold",
                            fontSize: 22,
                            color: Color(0xFF8AC85A),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,

                          controller: _lightingController,
                          focusNode: _focusNodeLighting,
                          textInputAction: TextInputAction.next,
                          // Move to next field
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodeSound);
                          },
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter lighting requirements';
                          //   }
                          //   return null;
                          // },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Lighting",
                            hintStyle: TextStyle(
                              color: Color(0xFFA0A0A0),
                              fontFamily: "UbuntuMedium",
                              fontSize: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,

                          controller: _soundController,
                          focusNode: _focusNodeSound,
                          textInputAction: TextInputAction.next,
                          // Move to next field
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodeStageSetup);
                          },
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter sound requirements';
                          //   }
                          //   return null;
                          // },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Sound",
                            hintStyle: TextStyle(
                              color: Color(0xFFA0A0A0),
                              fontFamily: "UbuntuMedium",
                              fontSize: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          readOnly: true,

                          controller: _stageSetupController,
                          focusNode: _focusNodeStageSetup,
                          textInputAction: TextInputAction.done,
                          // Complete form
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter stage setup details';
                          //   }
                          //   return null;
                          // },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Stage Setup",
                            hintStyle: TextStyle(
                              color: Color(0xFFA0A0A0),
                              fontFamily: "UbuntuMedium",
                              fontSize: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide:
                              BorderSide.none, // Removes the default border
                            ),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 1.85,
              left: 16,
              right: 16,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey3, // Form key for validation
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Transition Details",
                          style: TextStyle(
                            fontFamily: "UbuntuBold",
                            fontSize: 22,
                            color: Color(0xFF8AC85A),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
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
                            readOnly: true,
                            controller: _transitionController,
                            focusNode: _focusNodeTransition,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText:
                              'Instructions for transition between acts',
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
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter a description';
                            //   }
                            //   return null;
                            // },
                            textInputAction: TextInputAction.done,
                            // Done button to close keyboard
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss keyboard
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 2.227,
              left: 16,
              right: 16,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey4, // Form key for validation
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Special Notes",
                          style: TextStyle(
                            fontFamily: "UbuntuBold",
                            fontSize: 22,
                            color: Color(0xFF8AC85A),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
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
                            readOnly: true,
                            controller: _specialNotesController,
                            focusNode: _focusNodeSpecialNotes,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'notes...',
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
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter a description';
                            //   }
                            //   return null;
                            // },
                            textInputAction: TextInputAction.done,
                            // Complete with Done action
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .unfocus(); // Dismiss the keyboard
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   top: MediaQuery.of(context).size.height * 2.6,
            //   left: MediaQuery.of(context).size.width * 0.1,
            //   right: MediaQuery.of(context).size.width * 0.1,
            //   child: GestureDetector(
            //     onTap: () {
            //       // Validate all forms
            //       if (_formKey1.currentState!.validate() &&
            //           _formKey2.currentState!.validate() &&
            //           _formKey3.currentState!.validate() &&
            //           _formKey4.currentState!.validate()) {
            //         // All forms are valid, proceed with submission
            //         print("All forms are valid!");
            //         setState(() {
            //           _isloading = true;
            //         });
            //         addPerformance(
            //             context,
            //             _selectedFestivalId,
            //             _startDateController.text,
            //             _endDateController.text,
            //             _performanceController.text,
            //             _bandController.text,
            //             _artistController.text,
            //             _participantsController.text,
            //             _guestsController.text,
            //             _startTimeController.text,
            //             _endTimeController.text,
            //             _lightingController.text,
            //             _soundController.text,
            //             _stageSetupController.text,
            //             _transitionController.text,
            //             _specialNotesController.text);
            //
            //
            //         // Add further submission logic here
            //       } else {
            //         // One or more forms are invalid
            //         print("Some forms are invalid.");
            //         // Show Snackbar message
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(
            //             content: Text(
            //               'Please fill out all required fields.',
            //               style: TextStyle(fontSize: 16),
            //             ),
            //             backgroundColor: Colors.red,
            //             // Change background color as needed
            //             duration: Duration(
            //                 seconds: 3), // Duration for Snackbar visibility
            //           ),
            //         );
            //       }
            //     },
            //     child: Container(
            //       width: MediaQuery.of(context).size.width * 0.8,
            //       height: 50,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(16),
            //         gradient: LinearGradient(
            //           colors: [Color(0xFF015CB5), Color(0xFF00AAE1)],
            //           stops: [0.0, 1.0],
            //           begin: Alignment.centerLeft,
            //           end: Alignment.centerRight,
            //         ),
            //       ),
            //       child: Center(
            //         child: Text(
            //           "Submit",
            //           style: TextStyle(
            //             fontFamily: "UbuntuBold",
            //             fontSize: 18,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

          ],
        ),
      ),
    );
  }
}


