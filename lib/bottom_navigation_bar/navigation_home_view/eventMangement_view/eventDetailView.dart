import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../api/addEvent_api.dart';
import '../../../api/updateEvent_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/eventColection_model.dart';

class EventDetailView extends StatefulWidget {
  final EventData event;

  EventDetailView({required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final _formKey = GlobalKey<FormState>();
  bool _isEmpty = true;
  bool _isloading = false;
  bool _isEditMode = false;

  late TextEditingController _dobControler;
  late TextEditingController _festivalNameControler;
  late TextEditingController _contentControler;
  late TextEditingController _titleControler;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _crowdCapicityController;
  late TextEditingController _priceController;
  late TextEditingController _totalController;
  late TextEditingController _taxController;

  // Focus nodes
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _crowdCapacityFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _taxFocusNode = FocusNode();
  final FocusNode _startTimeFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _dobControler = TextEditingController(text: "${widget.event.startDate}");
    _festivalNameControler =
        TextEditingController(text: widget.event.festival?.nameOrganizer ?? "");
    _contentControler =
        TextEditingController(text: "${widget.event.eventDescription ?? ""}");
    _titleControler =
        TextEditingController(text: "${widget.event.eventTitle ?? ""}");
    _startTimeController =
        TextEditingController(text: "${widget.event.startTime ?? ""}");
    _endTimeController =
        TextEditingController(text: "${widget.event.endTime ?? ""}");
    _crowdCapicityController =
        TextEditingController(text: "${widget.event.crowdCapacity ?? ""}");
    _priceController =
        TextEditingController(text: "${widget.event.pricePerPerson ?? ""}");
    _totalController =
        TextEditingController(text: "${widget.event.grandTotal ?? ""}");
    _taxController =
        TextEditingController(text: "${widget.event.taxPercentage ?? ""}");

    // Listen to changes in the price and crowd capacity fields
    _priceController.addListener(_updateTotalAmount);
    _crowdCapicityController.addListener(_updateTotalAmount);
    _contentControler.addListener(() {
      setState(() {
        _isEmpty = _contentControler.text.isEmpty;
      });
    });
  }

  void _updateTotalAmount() {
    double price = double.tryParse(_priceController.text) ?? 0;
    int crowdCapacity = int.tryParse(_crowdCapicityController.text) ?? 0;
    double total = price * crowdCapacity;
    _totalController.text = total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _dobControler.dispose();
    _contentControler.dispose();
    _endTimeController.dispose();
    _titleControler.dispose();
    _crowdCapicityController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _taxController.dispose();
    _festivalNameControler.dispose();
    super.dispose();
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

  Future<void> _pickStartDate() async {
    DateTime initialDate = DateTime.now();
    if (_dobControler.text.isNotEmpty) {
      DateTime? parsedDate = DateTime.tryParse(_dobControler.text);
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
        _dobControler.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  String? _validateStartTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a start time';
    }
    return null;
  }

  String? _validateEndTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an end time';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date';
    }
    return null;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
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
                    "Event Detail",
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
                // Event Details Container with a Stack to place the Edit button
                Stack(
                  children: [
                    Container(
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
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
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
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            if (_isEditMode) SizedBox(height: 10),

                            // Festival Name (Non-editable even in edit mode)
                            GestureDetector(
                              onTap: _isEditMode
                                  ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Festival name cannot be edited.",
                                      style: TextStyle(fontFamily: "Ubuntu"),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                                  : null,
                              child: Text(
                                "Festival Name",
                                style: TextStyle(
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            TextFormField(
                              readOnly: true, // Always read-only
                              controller: _festivalNameControler,
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
                                    AppConstants.dropDownPrefixIcon,
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Title Field
                            Text(
                              "Title",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
                            ),
                            TextFormField(
                              readOnly: !_isEditMode, // Editable in edit mode
                              controller: _titleControler,
                              focusNode: _titleFocusNode,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 30.0,
                                  minHeight: 30.0,
                                ),
                                prefixIcon: Row(
                                  mainAxisSize: MainAxisSize.min, // Ensures icon fits its space
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: SvgPicture.asset(
                                        AppConstants.bulletinTitleIcon,
                                        color: Color(0xFF628C61),
                                        width: 25.0, // Keep icon size intact
                                        height: 25.0,
                                      ),
                                    ),
                                    SizedBox(width: 8), // Adds padding between the icon and content
                                  ],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_contentFocusNode);
                              },
                            ),
                            SizedBox(height: 10),

                            // Content Field
                            Text(
                              "Content",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
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
                                    readOnly: !_isEditMode, // Editable in edit mode
                                    controller: _contentControler,
                                    focusNode: _contentFocusNode,
                                    maxLines: null,
                                    expands: true,
                                    keyboardType: TextInputType.multiline,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      hintText: 'Enter content of the event...',
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
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(_crowdCapacityFocusNode);
                                    },
                                  ),
                                  if (_isEmpty)
                                    Center(
                                      child: SvgPicture.asset(
                                        AppConstants.bulletinContentIcon,
                                        color: Color(0xFF628C61),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),

                            // Crowd Capacity Field
                            Text(
                              "Crowd Capacity",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: !_isEditMode, // Editable in edit mode
                              controller: _crowdCapicityController,
                              focusNode: _crowdCapacityFocusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    AppConstants.crowdCapicity,
                                    color: Color(0xFF628C61),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "0",
                                hintStyle: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                  return 'Please enter a valid crowd capacity';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_priceFocusNode);
                              },
                            ),
                            SizedBox(height: 10),

                            // Price Per Person Field
                            Text(
                              "Price Per Person",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: !_isEditMode, // Editable in edit mode
                              textInputAction: TextInputAction.next,
                              controller: _priceController,
                              focusNode: _priceFocusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_taxFocusNode);
                              },
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    AppConstants.person,
                                    color: Color(0xFF628C61),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "0",
                                hintStyle: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Total Amount Field
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: true,
                              controller: _totalController,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    AppConstants.totalAmount,
                                    color: Color(0xFF628C61),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "0",
                                hintStyle: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Tax Field
                            Text(
                              "Tax",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              readOnly: !_isEditMode, // Editable in edit mode
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                double total = double.tryParse(_totalController.text) ?? 0;
                                double tax = double.tryParse(value ?? '') ?? 0;

                                if (value == null || value.isEmpty) {
                                  return 'Please enter a tax amount';
                                } else if (tax > total) {
                                  return 'Tax must be less than or equal to total amount';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              focusNode: _taxFocusNode,
                              controller: _taxController,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_startTimeFocusNode);
                              },
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    AppConstants.tax,
                                    color: Color(0xFF628C61),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "0",
                                hintStyle: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Start and End Time Fields
                            Row(
                              children: [
                                Expanded(
                                  child: buildReadOnlyTimeField(
                                    readOnly:true, // Editable in edit mode
                                    onTap: _isEditMode
                                        ? () => _selectTime(context, _startTimeController)
                                        : null,
                                    label: "Start Time",
                                    controller: _startTimeController,
                                    validator: _validateStartTime,
                                    focusNode: _startTimeFocusNode,
                                    nextFocusNode: _endTimeFocusNode,
                                    icon: AppConstants.timer1Icon,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: buildReadOnlyTimeField(
                                    readOnly:true, // Editable in edit mode
                                    onTap: _isEditMode
                                        ? () => _selectTime(context, _endTimeController)
                                        : null,
                                    label: "End Time",
                                    controller: _endTimeController,
                                    validator: _validateEndTime,
                                    focusNode: _endTimeFocusNode,
                                    nextFocusNode: _dobFocusNode,
                                    icon: AppConstants.timer1Icon,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // Date Field
                            buildReadOnlyDateField(
                              readOnly:true, // Editable in edit mode
                              label: "Date",
                              controller: _dobControler,
                              validator: _validateDate,
                              focusNode: _dobFocusNode,
                              onTap: _isEditMode ? _pickStartDate : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Edit Button
                    if (!_isEditMode)
                      Positioned(
                        top: 20,
                        right: 16,
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

                // Update Button
                if (_isEditMode)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          updateEvent(
                            context,
                            widget.event.id.toString(),
                            _titleControler.text,
                            widget.event.festivalId.toString(),

                            _contentControler.text,
                            _crowdCapicityController.text,
                            _priceController.text,
                            _totalController.text,
                            _taxController.text,
                            _startTimeController.text,
                            _endTimeController.text,
                            _dobControler.text,
                          );
                        }
                      }, // Ensure this function is implemented
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

  Widget buildReadOnlyTimeField({
    bool readOnly = true,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    VoidCallback? onTap, // Make onTap optional
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required String icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          " $label",
          style: TextStyle(
            color: Color(0xFF0A0909),
            fontFamily: "UbuntuMedium",
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 70,
          child: TextFormField(
            readOnly: readOnly, // Use the readOnly parameter
            validator: validator,
            textInputAction: TextInputAction.next,
            focusNode: focusNode,
            controller: controller,
            onTap: onTap, // Pass the optional onTap
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            },
            decoration: InputDecoration(
              prefixIconConstraints: BoxConstraints(
                minWidth: 30.0,
                minHeight: 30.0,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SvgPicture.asset(icon, color: Color(0xFF628C61)),
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
        ),
      ],
    );
  }

  Widget buildReadOnlyDateField({
    bool readOnly = true,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    VoidCallback? onTap, // Make onTap optional
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF0A0909),
            fontFamily: "UbuntuMedium",
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 70,
          child: TextFormField(
            readOnly: readOnly, // Use the readOnly parameter
            validator: validator,
            controller: controller,
            onTap: onTap, // Pass the optional onTap
            focusNode: focusNode,
            decoration: InputDecoration(
              prefixIconConstraints: BoxConstraints(
                minWidth: 30.0,
                minHeight: 30.0,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SvgPicture.asset(AppConstants.calendarIcon, color: Color(0xFF628C61)),
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: "Select Date",
              hintStyle: TextStyle(
                color: Color(0xFFA0A0A0),
                fontFamily: "UbuntuMedium",
                fontSize: 15,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),
      ],
    );
  }

}

// import 'package:crap_advisor_orgnaizer/annim/transition.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
//
// import '../../../api/addEvent_api.dart';
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/eventColection_model.dart';
//
// class EventDetailView extends StatefulWidget {
//   final EventData event;
//
//   EventDetailView({required this.event});
//
//   @override
//   State<EventDetailView> createState() => _EventDetailViewState();
// }
//
// class _EventDetailViewState extends State<EventDetailView> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isEmpty = true;
//
//   late TextEditingController _dobControler;
//   late TextEditingController _festivalNameControler;
//   late TextEditingController _contentControler;
//   late TextEditingController _titleControler;
//   late TextEditingController _startTimeController;
//   late TextEditingController _endTimeController;
//   late TextEditingController _crowdCapicityController;
//   late TextEditingController _priceController;
//   late TextEditingController _totalController;
//   late TextEditingController _taxController;
//
//   // Focus nodes
//   final FocusNode _titleFocusNode = FocusNode();
//   final FocusNode _contentFocusNode = FocusNode();
//   final FocusNode _crowdCapacityFocusNode = FocusNode();
//   final FocusNode _priceFocusNode = FocusNode();
//   final FocusNode _taxFocusNode = FocusNode();
//   final FocusNode _startTimeFocusNode = FocusNode();
//   final FocusNode _endTimeFocusNode = FocusNode();
//   final FocusNode _dobFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     _dobControler = TextEditingController(text: "${widget.event.startDate}");
//     _festivalNameControler = TextEditingController(text: widget.event.festival?.nameOrganizer ?? "");
//     _contentControler = TextEditingController(text: "${widget.event.eventDescription ?? ""}");
//     _titleControler = TextEditingController(text: "${widget.event.eventTitle ?? ""}");
//     _startTimeController = TextEditingController(text: "${widget.event.startTime ?? ""}");
//     _endTimeController = TextEditingController(text: "${widget.event.endTime ?? ""}");
//     _crowdCapicityController = TextEditingController(text: "${widget.event.crowdCapacity ?? ""}");
//     _priceController = TextEditingController(text: "${widget.event.pricePerPerson ?? ""}");
//     _totalController = TextEditingController(text: "${widget.event.grandTotal ?? ""}");
//     _taxController = TextEditingController(text: "${widget.event.taxPercentage ?? ""}");
//
//     // Listen to changes in the price and crowd capacity fields
//     _priceController.addListener(_updateTotalAmount);
//     _crowdCapicityController.addListener(_updateTotalAmount);
//     _contentControler.addListener(() {
//       setState(() {
//         _isEmpty = _contentControler.text.isEmpty;
//       });
//     });
//   }
//
//   void _updateTotalAmount() {
//     double price = double.tryParse(_priceController.text) ?? 0;
//     int crowdCapacity = int.tryParse(_crowdCapicityController.text) ?? 0;
//     double total = price * crowdCapacity;
//     _totalController.text = total.toStringAsFixed(2);
//   }
//
//   @override
//   void dispose() {
//     _dobControler.dispose();
//     _contentControler.dispose();
//     _endTimeController.dispose();
//     _titleControler.dispose();
//     _crowdCapicityController.dispose();
//     _priceController.dispose();
//     _totalController.dispose();
//     _taxController.dispose();
//     _festivalNameControler.dispose();
//     super.dispose();
//   }
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
//   String? _validateStartTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select a start time';
//     }
//     return null;
//   }
//
//   String? _validateEndTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select an end time';
//     }
//     return null;
//   }
//
//   String? _validateDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select a date';
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background
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
//                     "Event Detail",
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
//                 // Event Details Container with a Stack to place the Edit button
//                 Stack(
//                   children: [
//                     Container(
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
//                       margin: EdgeInsets.symmetric(horizontal: 16),
//                       padding: EdgeInsets.all(16.0),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 20),
//                             Text(
//                               "Festival Name",
//                               style: TextStyle(
//                                   fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _festivalNameControler,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 prefixIconConstraints: BoxConstraints(
//                                   minWidth: 30.0,
//                                   minHeight: 30.0,
//                                 ),
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.only(left: 8, right: 8),
//                                   child: SvgPicture.asset(
//                                     AppConstants.dropDownPrefixIcon,
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
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Title",
//                               style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _titleControler,
//                               focusNode: _titleFocusNode,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 prefixIconConstraints: BoxConstraints(
//                                   minWidth: 30.0,
//                                   minHeight: 30.0,
//                                 ),
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.only(left: 8),
//                                   child: SvgPicture.asset(
//                                       AppConstants.bulletinTitleIcon,
//                                       color: Color(0xFF628C61)),
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a title';
//                                 }
//                                 return null;
//                               },
//                               textInputAction: TextInputAction.next,
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_contentFocusNode);
//                               },
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Content",
//                               style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
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
//                                       hintText: 'Enter content of the event...',
//                                       hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
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
//                                     textInputAction: TextInputAction.next,
//                                     onFieldSubmitted: (_) {
//                                       FocusScope.of(context)
//                                           .requestFocus(_crowdCapacityFocusNode);
//                                     },
//                                   ),
//                                   if (_isEmpty)
//                                     Center(
//                                       child: SvgPicture.asset(
//                                         AppConstants.bulletinContentIcon,
//                                         color: Color(0xFF628C61),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Crowd Capacity",
//                               style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _crowdCapicityController,
//                               focusNode: _crowdCapacityFocusNode,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                               decoration: InputDecoration(
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SvgPicture.asset(
//                                     AppConstants.crowdCapicity,
//                                     color: Color(0xFF628C61),
//                                   ),
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "0",
//                                 hintStyle: TextStyle(
//                                   color: Color(0xFFA0A0A0),
//                                   fontFamily: "UbuntuMedium",
//                                   fontSize: 15,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                               validator: (value) {
//                                 if (value == null ||
//                                     value.isEmpty ||
//                                     int.tryParse(value) == null) {
//                                   return 'Please enter a valid crowd capacity';
//                                 }
//                                 return null;
//                               },
//                               textInputAction: TextInputAction.next,
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_priceFocusNode);
//                               },
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Price Per Person",
//                               style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               textInputAction: TextInputAction.next,
//                               controller: _priceController,
//                               focusNode: _priceFocusNode,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a valid number';
//                                 }
//                                 return null;
//                               },
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_taxFocusNode);
//                               },
//                               decoration: InputDecoration(
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SvgPicture.asset(
//                                     AppConstants.person,
//                                     color: Color(0xFF628C61),
//                                   ),
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "0",
//                                 hintStyle: TextStyle(
//                                   color: Color(0xFFA0A0A0),
//                                   fontFamily: "UbuntuMedium",
//                                   fontSize: 15,
//                                 ),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Total Amount",
//                               style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               controller: _totalController,
//                               decoration: InputDecoration(
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SvgPicture.asset(
//                                     AppConstants.totalAmount,
//                                     color: Color(0xFF628C61),
//                                   ),
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "0",
//                                 hintStyle: TextStyle(
//                                     color: Color(0xFFA0A0A0),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               "Tax",
//                               style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
//                             ),
//                             SizedBox(height: 10),
//                             TextFormField(
//                               readOnly: true,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                               validator: (value) {
//                                 double total = double.tryParse(_totalController.text) ?? 0;
//                                 double tax = double.tryParse(value ?? '') ?? 0;
//
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a tax amount';
//                                 } else if (tax > total) {
//                                   return 'Tax must be less than or equal to total amount';
//                                 }
//                                 return null;
//                               },
//                               textInputAction: TextInputAction.next,
//                               focusNode: _taxFocusNode,
//                               controller: _taxController,
//                               onFieldSubmitted: (_) {
//                                 FocusScope.of(context).requestFocus(_startTimeFocusNode);
//                               },
//                               decoration: InputDecoration(
//                                 prefixIcon: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SvgPicture.asset(
//                                     AppConstants.tax,
//                                     color: Color(0xFF628C61),
//                                   ),
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 hintText: "0",
//                                 hintStyle: TextStyle(
//                                     color: Color(0xFFA0A0A0),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: buildReadOnlyTimeField(
//                                     label: "Start Time",
//                                     controller: _startTimeController,
//                                     validator: _validateStartTime,
//                                     focusNode: _startTimeFocusNode,
//                                     nextFocusNode: _endTimeFocusNode,
//                                     icon: AppConstants.timer1Icon,
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: buildReadOnlyTimeField(
//                                     label: "End Time",
//                                     controller: _endTimeController,
//                                     validator: _validateEndTime,
//                                     focusNode: _endTimeFocusNode,
//                                     nextFocusNode: _dobFocusNode,
//                                     icon: AppConstants.timer1Icon,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             buildReadOnlyDateField(
//                               label: "Date",
//                               controller: _dobControler,
//                               validator: _validateDate,
//                               focusNode: _dobFocusNode,
//                             ),
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
//         ],
//       ),
//     );
//   }
//
//   Widget buildReadOnlyTimeField({
//     required String label,
//     required TextEditingController controller,
//     required String? Function(String?) validator,
//     required FocusNode focusNode,
//     required FocusNode nextFocusNode,
//     required String icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           " $label",
//           style: TextStyle(
//               color: Color(0xFF0A0909), fontFamily: "UbuntuMedium", fontSize: 15),
//         ),
//         SizedBox(height: 10),
//         Container(
//           height: 70,
//           child: TextFormField(
//             readOnly: true,
//             validator: validator,
//             textInputAction: TextInputAction.next,
//             focusNode: focusNode,
//             controller: controller,
//             onFieldSubmitted: (_) {
//               FocusScope.of(context).requestFocus(nextFocusNode);
//             },
//             decoration: InputDecoration(
//               prefixIconConstraints: BoxConstraints(
//                 minWidth: 30.0,
//                 minHeight: 30.0,
//               ),
//               prefixIcon: Padding(
//                 padding: const EdgeInsets.only(left: 8, right: 8),
//                 child: SvgPicture.asset(icon, color: Color(0xFF628C61)),
//               ),
//               filled: true,
//               fillColor: Colors.white,
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
//   Widget buildReadOnlyDateField({
//     required String label,
//     required TextEditingController controller,
//     required String? Function(String?) validator,
//     required FocusNode focusNode,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//               color: Color(0xFF0A0909), fontFamily: "UbuntuMedium", fontSize: 15),
//         ),
//         SizedBox(height: 10),
//         Container(
//           height: 70,
//           child: TextFormField(
//             readOnly: true,
//             validator: validator,
//             controller: controller,
//             focusNode: focusNode,
//             decoration: InputDecoration(
//               prefixIconConstraints: BoxConstraints(
//                 minWidth: 30.0,
//                 minHeight: 30.0,
//               ),
//               prefixIcon: Padding(
//                 padding: const EdgeInsets.only(left: 8, right: 8),
//                 child: SvgPicture.asset(AppConstants.calendarIcon, color: Color(0xFF628C61)),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               hintText: "Longitude",
//               hintStyle: TextStyle(
//                   color: Color(0xFFA0A0A0),
//                   fontFamily: "UbuntuMedium",
//                   fontSize: 15),
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
// }
//
//
