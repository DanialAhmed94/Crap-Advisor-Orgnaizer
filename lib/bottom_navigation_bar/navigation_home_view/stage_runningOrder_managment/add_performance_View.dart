import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addPerformance.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';

class AddPerformanceView extends StatefulWidget {
  AddPerformanceView({super.key});

  @override
  State<AddPerformanceView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<AddPerformanceView> {
  final TextEditingController _dobControler = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  String? _selectedItem;
  bool _isloading = false;

  String? _selectedFestivalId;

// Define TextEditingControllers
  final _endTimeController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _bandController = TextEditingController();
  final _performanceController = TextEditingController();
  final _artistController = TextEditingController();
  final _participantsController = TextEditingController();
  final _guestsController = TextEditingController();
  final _lightingController = TextEditingController();
  final _soundController = TextEditingController();
  final _stageSetupController = TextEditingController();
  final _transitionController = TextEditingController();
  final _focusNodeTransition = FocusNode();
  final _specialNotesController = TextEditingController();
  final _focusNodeSpecialNotes = FocusNode();

  // FocusNodes to handle focus navigation between fields
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
    _startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _endDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                    "Add Performance",
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
                          "Select Festival",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        // Consumer<FestivalProvider>(
                        //   builder: (context, festivalProvider, child) {
                        //     return DropdownButtonFormField<String>(
                        //       value: _selectedItem,
                        //       decoration: InputDecoration(
                        //         prefixIcon: SvgPicture.asset(AppConstants.dropDownPrefixIcon),
                        //         filled: true,
                        //         fillColor: Colors.white,
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(30.0),
                        //           borderSide: BorderSide.none,
                        //         ),
                        //       ),
                        //       items: festivalProvider.festivals.map((Festival festival) {
                        //         return DropdownMenuItem<String>(
                        //           value: festival.nameOrganizer, // Use the appropriate property
                        //           child: ConstrainedBox(
                        //             constraints: BoxConstraints(
                        //               maxWidth: MediaQuery.of(context).size.width * 0.6, // Set a max width
                        //             ),
                        //             child: Text(
                        //               festival.nameOrganizer,
                        //               overflow: TextOverflow.ellipsis, // Manage overflow
                        //               maxLines: 1, // Show only one line
                        //             ),
                        //           ),
                        //         );
                        //       }).toList(),
                        //       onChanged: (newValue) {
                        //         setState(() {
                        //           _selectedItem = newValue;
                        //         });
                        //       },
                        //       validator: (value) {
                        //         if (value == null || value.isEmpty) {
                        //           return 'Please select a festival';
                        //         }
                        //         return null;
                        //       },
                        //     );
                        //   },
                        // ),
                        // Holds the ID of the selected festival

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
                                          _startDateController.text = pickedDate
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
                                                0.45,
                                        child: TextFormField( style: TextStyle(fontSize: 14.0),
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
                                    "End Date",
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
                                          _endDateController.text = pickedDate
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
                                            suffixIcon: Icon(
                                                Icons.arrow_drop_down_sharp),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a band name';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an artist name';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter participants names';
                            }
                            return null;
                          },
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter names';
                              }
                              return null;
                            },
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
                                                  AppConstants.timer1Icon,color: Color(0xFF8AC85A),),
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
                                    "End Time",
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
                                        context, _endTimeController),
                                    child: AbsorbPointer(
                                      child: Container(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: TextFormField(
                                          controller: _endTimeController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select an end time';
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
                                                  AppConstants.timerIcon,color: Color(0xFF8AC85A),),
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
                            controller: _specialNotesController,
                            focusNode: _focusNodeSpecialNotes,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Enter notes...',
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
            Positioned(
              top: MediaQuery.of(context).size.height * 2.6,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTap: () {
                  // Validate all forms
                  if (_formKey1.currentState!.validate() &&
                      _formKey2.currentState!.validate() &&
                      _formKey3.currentState!.validate() &&
                      _formKey4.currentState!.validate()) {
                    // All forms are valid, proceed with submission
                    print("All forms are valid!");
                    setState(() {
                      _isloading = true;
                    });
                    addPerformance(
                        context,
                        _selectedFestivalId,
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
                        _specialNotesController.text);


                    // Add further submission logic here
                  } else {
                    // One or more forms are invalid
                    print("Some forms are invalid.");
                    // Show Snackbar message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill out all required fields.',
                          style: TextStyle(fontSize: 16),
                        ),
                        backgroundColor: Colors.red,
                        // Change background color as needed
                        duration: Duration(
                            seconds: 3), // Duration for Snackbar visibility
                      ),
                    );
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
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontFamily: "UbuntuBold",
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isloading)
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

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
//
// import '../../../constants/AppConstants.dart';
//
// class AddPerformanceView extends StatefulWidget {
//   AddPerformanceView({super.key});
//
//   @override
//   State<AddPerformanceView> createState() => _AddFestivalViewState();
// }
//
// class _AddFestivalViewState extends State<AddPerformanceView> {
//   final TextEditingController _dobControler = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedItem;
//
//   TextEditingController _endTimeController = TextEditingController();
//   TextEditingController _startTimeController = TextEditingController();
//
//   Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
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
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _dobControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _dobControler.dispose();
//     _startTimeController.dispose();
//     _endTimeController.dispose();
//   }
//
//   double calculateTotalHeight(BuildContext context) {
//     double totalHeight = 0.0;
//
//     totalHeight = totalHeight +
//         MediaQuery.of(context).size.height * 0.07 +
//         MediaQuery.of(context).size.height * 0.37 +
//         MediaQuery.of(context).size.height *
//             0.58 +
//         MediaQuery.of(context).size.height *
//             0.9 +
//         MediaQuery.of(context).size.height *
//             0.7;
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
//                 fit: BoxFit.cover,
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
//                     "Add Performance",
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
//                 height: MediaQuery.of(context).size.height * 1.1,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.25),
//                       // Shadow color with 4% opacity
//                       blurRadius: 4.0,
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
//                         DropdownButtonFormField<String>(
//                           value: _selectedItem,
//                           decoration: InputDecoration(
//                             prefixIcon: SvgPicture.asset(
//                                 AppConstants.dropDownPrefixIcon),
//                             filled: true,
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30.0),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                           items: <String>[
//                             'Isle of Wight Festival',
//                             'Glastonbury Festival',
//                             'TRNSMT Festival',
//                           ].map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                           onChanged: (newValue) {
//                             setState(() {
//                               _selectedItem = newValue;
//                             });
//                           },
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please select an item';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Start Date",
//                                     style: TextStyle(
//                                         color: Color(0xFF0A0909),
//                                         fontFamily: "UbuntuMedium",
//                                         fontSize: 15),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () async {
//                                       final DateTime? pickedDate =
//                                           await showDatePicker(
//                                         context: context,
//                                         initialDate: DateTime.now(),
//                                         firstDate: DateTime(1900),
//                                         lastDate: DateTime(2050),
//                                       );
//                                       if (pickedDate != null) {
//                                         setState(() {
//                                           _dobControler.text = pickedDate
//                                               .toString()
//                                               .substring(0, 10);
//                                         });
//                                       }
//                                     },
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.45,
//                                         child: TextFormField(
//                                           controller: _dobControler,
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints:
//                                                 BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8, right: 8),
//                                               child: SvgPicture.asset(
//                                                 AppConstants.calendarIcon,
//                                               ),
//                                             ),
//                                             suffixIcon: Icon(
//                                                 Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
//
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
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "End Date",
//                                     style: TextStyle(
//                                         color: Color(0xFF0A0909),
//                                         fontFamily: "UbuntuMedium",
//                                         fontSize: 15),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () async {
//                                       final DateTime? pickedDate =
//                                           await showDatePicker(
//                                         context: context,
//                                         initialDate: DateTime.now(),
//                                         firstDate: DateTime(1900),
//                                         lastDate: DateTime(2050),
//                                       );
//                                       if (pickedDate != null) {
//                                         setState(() {
//                                           _dobControler.text = pickedDate
//                                               .toString()
//                                               .substring(0, 10);
//                                         });
//                                       }
//                                     },
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.42,
//                                         child: TextFormField(
//                                           controller: _dobControler,
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints:
//                                                 BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8, right: 8),
//                                               child: SvgPicture.asset(
//                                                 AppConstants.calendarIcon,
//                                               ),
//                                             ),
//                                             suffixIcon: Icon(
//                                                 Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             hintText: "Longitude",
//                                             hintStyle: TextStyle(
//                                                 color: Color(0xFFA0A0A0),
//                                                 fontFamily: "UbuntuMedium",
//                                                 fontSize: 15),
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
//                         Text(
//                           "Performance Title",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 30.0,
//                               minHeight: 30.0,
//                             ),
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.only(left: 8, right: 8),
//                               child: SvgPicture.asset(
//                                 AppConstants.performanceTitleIcon,
//                               ),
//                             ),
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
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Band",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 30.0,
//                               minHeight: 30.0,
//                             ),
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.only(left: 8, right: 8),
//                               child: SvgPicture.asset(
//                                 AppConstants.bandTitleIcon,
//                               ),
//                             ),
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
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Artist",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 30.0,
//                               minHeight: 30.0,
//                             ),
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.only(left: 8, right: 8),
//                               child: SvgPicture.asset(
//                                 AppConstants.artistTitleIcon,
//                               ),
//                             ),
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
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Participantes Names",
//                           style: TextStyle(
//                               color: Color(0xFF0A0909),
//                               fontFamily: "UbuntuMedium",
//                               fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Container(
//                           height: MediaQuery.of(context).size.height *
//                               0.2, // 20% of screen height
//                           width: double.infinity, // Full width of the container
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
//                             borderRadius: BorderRadius.circular(
//                                 10.0), // Optional: Add border radius
//                           ),
//                           child: TextFormField(
//                             maxLines: null,
//                             // Allows text field to expand vertically
//                             expands: true,
//                             // Fills the container vertically
//                             keyboardType: TextInputType.multiline,
//                             // Sets the keyboard to multiline
//                             textAlignVertical: TextAlignVertical.top,
//                             // Aligns text at the top
//                             decoration: InputDecoration(
//                               hintText: 'Enter names here...',
//                               hintStyle: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 16.0,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 // Matches container's border radius
//                                 borderSide: BorderSide
//                                     .none, // Removes the default border
//                               ),
//                               contentPadding: EdgeInsets.all(16.0),
//                               // Padding inside the text field
//                               filled: true,
//                               fillColor: Colors.white,
//                             ),
//                             validator: (value) {
//                               // Add validation logic here if needed
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a description';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Special Guests",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 30.0,
//                               minHeight: 30.0,
//                             ),
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.only(left: 8, right: 8),
//                               child: SvgPicture.asset(
//                                 AppConstants.specialGuestsTitleIcon,
//                               ),
//                             ),
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
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
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
//                                     onTap: () => _selectTime(context, _startTimeController),
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width: MediaQuery.of(context).size.width * 0.45,
//                                         child: TextFormField(
//                                           controller: _startTimeController,
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints: BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(left: 8, right: 8),
//                                               child: SvgPicture.asset(AppConstants.timer1Icon
//                                               ),
//                                             ),
//                                             suffixIcon: Icon(Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(25.0),
//                                               borderSide: BorderSide.none, // Removes the default border
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none, // Removes the default border
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none, // Removes the default border
//                                             ),
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
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
//                                     onTap: () => _selectTime(context, _endTimeController),
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width: MediaQuery.of(context).size.width * 0.45,
//                                         child: TextFormField(
//                                           controller: _endTimeController,
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints: BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(left: 8, right: 8),
//                                               child: SvgPicture.asset(
//                                                 AppConstants.timerIcon
//                                               ),
//                                             ),
//                                             suffixIcon: Icon(Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(25.0),
//                                               borderSide: BorderSide.none, // Removes the default border
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none, // Removes the default border
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(30.0),
//                                               borderSide: BorderSide.none, // Removes the default border
//                                             ),
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//
//
//       Positioned(
//         top: MediaQuery.of(context).size.height * 1.3,
//         left: 16,
//         right: 16,
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.35,
//           width: MediaQuery.of(context).size.width,
//           decoration: BoxDecoration(
//             color: Color(0xFFF8FAFC),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 // Shadow color with 4% opacity
//                 blurRadius: 80.0,
//                 // Adjust the blur radius for desired blur effect
//                 spreadRadius: 0,
//                 // Optional: controls the size of the shadow spread
//                 offset: Offset(0,
//                     4), // Optional: controls the position of the shadow
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//
//                 Text("Technical Requirements",
//                   style: TextStyle(fontFamily: "UbuntuBold",
//                       fontSize: 22,color:
//                       Colors.blueAccent),),
//
//                 SizedBox(height: 20,),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: "Lightining",
//                     hintStyle: TextStyle(
//                         color: Color(0xFFA0A0A0),
//                         fontFamily: "UbuntuMedium",
//                         fontSize: 15),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16.0),
//                   ),
//                 ),
//
//                 SizedBox(height: 20,),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: "Sound",
//                     hintStyle: TextStyle(
//                         color: Color(0xFFA0A0A0),
//                         fontFamily: "UbuntuMedium",
//                         fontSize: 15),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16.0),
//                   ),
//                 ),
//
//                 SizedBox(height: 20,),
//                 TextFormField(
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     hintText: "Stage Setup",
//                     hintStyle: TextStyle(
//                         color: Color(0xFFA0A0A0),
//                         fontFamily: "UbuntuMedium",
//                         fontSize: 15),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                       borderSide:
//                       BorderSide.none, // Removes the default border
//                     ),
//                     contentPadding:
//                     EdgeInsets.symmetric(horizontal: 16.0),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )),
//
//             Positioned(
//                 top: MediaQuery.of(context).size.height * 1.7,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.35,
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         // Shadow color with 4% opacity
//                         blurRadius: 80.0,
//                         // Adjust the blur radius for desired blur effect
//                         spreadRadius: 0,
//                         // Optional: controls the size of the shadow spread
//                         offset: Offset(0,
//                             4), // Optional: controls the position of the shadow
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//
//                         Text("Transition Details",
//                           style: TextStyle(fontFamily: "UbuntuBold",
//                               fontSize: 22,color:
//                               Colors.blueAccent),),
//
//                         SizedBox(height: 20,),
//                         Container(
//                           height: MediaQuery.of(context).size.height *
//                               0.2, // 20% of screen height
//                           width: double.infinity, // Full width of the container
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
//                             borderRadius: BorderRadius.circular(
//                                 10.0), // Optional: Add border radius
//                           ),
//                           child: TextFormField(
//                             maxLines: null,
//                             // Allows text field to expand vertically
//                             expands: true,
//                             // Fills the container vertically
//                             keyboardType: TextInputType.multiline,
//                             // Sets the keyboard to multiline
//                             textAlignVertical: TextAlignVertical.top,
//                             // Aligns text at the top
//                             decoration: InputDecoration(
//                               hintText: 'instructions for transition between acts',
//                               hintStyle: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 16.0,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 // Matches container's border radius
//                                 borderSide: BorderSide
//                                     .none, // Removes the default border
//                               ),
//                               contentPadding: EdgeInsets.all(16.0),
//                               // Padding inside the text field
//                               filled: true,
//                               fillColor: Colors.white,
//                             ),
//                             validator: (value) {
//                               // Add validation logic here if needed
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a description';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 )),
//
//             Positioned(
//                 top: MediaQuery.of(context).size.height * 2.1,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.35,
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     color: Color(0xFFF8FAFC),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         // Shadow color with 4% opacity
//                         blurRadius: 80.0,
//                         // Adjust the blur radius for desired blur effect
//                         spreadRadius: 0,
//                         // Optional: controls the size of the shadow spread
//                         offset: Offset(0,
//                             4), // Optional: controls the position of the shadow
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//
//                         Text("Special Notes",
//                           style: TextStyle(fontFamily: "UbuntuBold",
//                               fontSize: 22,color:
//                               Colors.blueAccent),),
//
//                         SizedBox(height: 20,),
//                         Container(
//                           height: MediaQuery.of(context).size.height *
//                               0.2, // 20% of screen height
//                           width: double.infinity, // Full width of the container
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
//                             borderRadius: BorderRadius.circular(
//                                 10.0), // Optional: Add border radius
//                           ),
//                           child: TextFormField(
//                             maxLines: null,
//                             // Allows text field to expand vertically
//                             expands: true,
//                             // Fills the container vertically
//                             keyboardType: TextInputType.multiline,
//                             // Sets the keyboard to multiline
//                             textAlignVertical: TextAlignVertical.top,
//                             // Aligns text at the top
//                             decoration: InputDecoration(
//                               hintText: 'enter notes...',
//                               hintStyle: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 16.0,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 // Matches container's border radius
//                                 borderSide: BorderSide
//                                     .none, // Removes the default border
//                               ),
//                               contentPadding: EdgeInsets.all(16.0),
//                               // Padding inside the text field
//                               filled: true,
//                               fillColor: Colors.white,
//                             ),
//                             validator: (value) {
//                               // Add validation logic here if needed
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter a description';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 )),
//
//             Positioned(
//                 top: MediaQuery.of(context).size.height *2.48,
//                 left: MediaQuery.of(context).size.width * 0.1,
//                 right: MediaQuery.of(context).size.width * 0.1,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF015CB5), Color(0xFF00AAE1)],
//                       stops: [0.0, 1.0],
//                       // 0% for the first color, 100% for the second color
//                       begin: Alignment.centerLeft,
//                       // Start from the left side
//                       end: Alignment.centerRight, // End at the right side
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       "Submit",
//                       style: TextStyle(
//                           fontFamily: "UbuntuBold",
//                           fontSize: 18,
//                           color: Colors.white),
//                     ),
//                   ),
//                 )),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
