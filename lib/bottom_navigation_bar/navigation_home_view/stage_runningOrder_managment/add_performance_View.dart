import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api/addPerformance.dart';
import '../../../api/getEventsByFestival.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';

class AddPerformanceView extends StatefulWidget {
  AddPerformanceView({super.key});

  @override
  State<AddPerformanceView> createState() => _AddPerformanceViewState();
}

class _AddPerformanceViewState extends State<AddPerformanceView> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  bool _isloading = false;

  String? _selectedFestivalId;
  String? _selectedEventId;
  Future<List<Map<String, String>>>? _eventsFuture;

  // Controllers
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
  final _specialNotesController = TextEditingController();

  // FocusNodes
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

  void _fetchEvents(String festivalId) {
    setState(() {
      _eventsFuture = getEventsByFestival(festivalId);
    });
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
    _startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _endDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    // Dispose Controllers
    _endTimeController.dispose();
    _startTimeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _bandController.dispose();
    _performanceController.dispose();
    _artistController.dispose();
    _participantsController.dispose();
    _guestsController.dispose();
    _lightingController.dispose();
    _soundController.dispose();
    _stageSetupController.dispose();
    _transitionController.dispose();
    _specialNotesController.dispose();

    // Dispose FocusNodes
    _focusNodeSpecialNotes.dispose();
    _focusNodeTransition.dispose();
    _focusNodeLighting.dispose();
    _focusNodeSound.dispose();
    _focusNodeStageSetup.dispose();
    _performanceFocusNode.dispose();
    _bandFocusNode.dispose();
    _artistFocusNode.dispose();
    _participantsFocusNode.dispose();
    _guestsFocusNode.dispose();

    super.dispose();
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
            child: Column(
              children: [
                SizedBox(height: 10),
                AppBar(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                SizedBox(height: 20),
                // Main Container for Festival and Event selection, Dates, Performance title, etc.
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
                  child: Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Festival",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        Consumer<FestivalProvider>(
                          builder: (context, festivalProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedFestivalId,
                              decoration: InputDecoration(
                                prefixIcon: SvgPicture.asset(
                                  AppConstants.dropDownPrefixIcon,
                                  color: Color(0xFF8AC85A),
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
                                  _selectedEventId = null;
                                  if (newValue != null) _fetchEvents(newValue);
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
                        SizedBox(height: 20),
                        Text(
                          "Select Event",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        FutureBuilder<List<Map<String, String>>>(
                          future: _eventsFuture,
                          builder: (context, snapshot) {
                            if (_selectedFestivalId == null) {
                              return _buildDisabledDropdown('Select festival first');
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildDisabledDropdown('Loading events...');
                            } else if (snapshot.hasError) {
                              return _buildDisabledDropdown('Error loading events');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return _buildDisabledDropdown('No events found');
                            } else {
                              // Ensure selected event is still valid
                              if (_selectedEventId != null &&
                                  !snapshot.data!.any((event) => event['event_id'] == _selectedEventId)) {
                                _selectedEventId = null;
                              }

                              return DropdownButtonFormField<String>(
                                value: _selectedEventId,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: snapshot.data!.map((Map<String, String> event) {
                                  return DropdownMenuItem<String>(
                                    value: event['event_id'],
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                                      ),
                                      child: Text(
                                        event['event_title'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEventId = value;
                                  });
                                },
                                hint: Text('Select Event'),

                              );
                            }
                          },
                        ),

                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: buildDateField(
                                context,
                                "Start Date",
                                _startDateController,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: buildDateField(
                                context,
                                "End Date",
                                _endDateController,
                              ),
                            ),
                          ],
                        ),

                        buildTextField(
                          "Performance Title",
                          _performanceController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a band name';
                            }
                            return null;
                          },
                          icon: AppConstants.performanceTitleIcon,
                          focusNode: _performanceFocusNode,
                          nextFocusNode: _bandFocusNode,
                        ),

                        buildTextField(
                          "Artist",
                          _artistController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter participants';
                            }
                            return null;
                          },
                          icon: AppConstants.artistTitleIcon,
                          focusNode: _artistFocusNode,
                          nextFocusNode: _participantsFocusNode,
                        ),

                        buildMultilineField(
                          "Participants",
                          _participantsController,
                          "Enter names...",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter names';
                            }
                            return null;
                          },
                        ),

                        buildTextField(
                          "Special Guests",
                          _guestsController,
                          icon: AppConstants.specialGuestsTitleIcon,
                          focusNode: _guestsFocusNode,
                        ),

                        buildTimeRow(context),

                      ],
                    ),
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
                        offset: Offset(0,4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey4,
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
                        buildMultilineField("",_specialNotesController, "Enter notes...",
                            focusNode: _focusNodeSpecialNotes),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Submit button
                GestureDetector(
                  onTap: () async {
                    if (_isloading) return;
                    if (_formKey1.currentState!.validate() &&
                        _formKey4.currentState!.validate()) {
                       {
                        setState(() {
                          _isloading = true;
                        });
                        await addPerformance(
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
                          _specialNotesController.text,
                          _selectedEventId,
                        );
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xFF8AC85A),
                    ),
                    child: Center(
                      child:  Text(
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
                SizedBox(height: 20),
              ],
            ),
          ),
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

  Widget buildDateField(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Color(0xFF0A0909),
              fontFamily: "UbuntuMedium",
              fontSize: 15),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = pickedDate.toString().substring(0, 11);
              });
            }
          },
          child: AbsorbPointer(
            child: Container(
              height: 70,
              child: TextFormField(
                controller: controller,
                style: TextStyle(fontSize: 14.0),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller, {
        String? Function(String?)? validator,
        String? icon,
        FocusNode? focusNode,
        FocusNode? nextFocusNode,
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
        TextFormField(
          controller: controller,
          focusNode: focusNode,
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
          validator: validator,
          onFieldSubmitted: (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ],
    );
  }

  Widget buildMultilineField(
      String label,
      TextEditingController controller,
      String hint, {
        String? Function(String?)? validator,
        FocusNode? focusNode,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(color: Color(0xFF0A0909), fontFamily: "UbuntuMedium", fontSize: 15),
          ),
          SizedBox(height: 10),
        ],
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
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16.0),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: validator,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledDropdown(String hintText) {
    return DropdownButtonFormField<String>(
      items: const [],
      onChanged: null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildTimeRow(BuildContext context) {
    return Row(
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
                          child: SvgPicture.asset(AppConstants.timer1Icon, color: Color(0xFF8AC85A)),
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
                          child: SvgPicture.asset(AppConstants.timerIcon, color: Color(0xFF8AC85A)),
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
    );
  }
}


