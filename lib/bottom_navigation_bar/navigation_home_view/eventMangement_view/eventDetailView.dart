import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addEvent_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/eventColection_model.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../data_model/invoiceCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import '../../../utilities/eventInvoiceDetail.dart';
import 'invoice_view.dart';

class EventDetailView extends StatefulWidget {
  late EventData event;
  late Invoice? invoice;

  EventDetailView({required this.event, this.invoice});

  @override
  State<EventDetailView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<EventDetailView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  bool _isEmpty = true;
  String? _selectedFestivalId;

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

  // Focus nodes for form navigation
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _crowdCapacityFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _taxFocusNode = FocusNode();
  final FocusNode _startTimeFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode();

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

// Start Time Validator
  String? _validateStartTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a start time';
    }
    return null;
  }

// End Time Validator
  String? _validateEndTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an end time';
    }
    return null;
  }

// Date Validator
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date';
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
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

    // Update the total amount in the total controller
    _totalController.text =
        total.toStringAsFixed(2); // format to 2 decimal places
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _dobControler.dispose();
    _contentControler.dispose();
    _endTimeController.dispose();
    _contentControler.dispose();
    _titleControler.dispose();
    _crowdCapicityController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _taxController.dispose();
    _festivalNameControler.dispose();
  }

  double calculateTotalHeight(BuildContext context) {
      double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.8 + // Example: Height of welcome message Positioned child
        MediaQuery.of(context).size.height *
            0.333; // Example: Height of welcome message Positioned child

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
                    "Event Detail",
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
                height: MediaQuery.of(context).size.height * 1.35,
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
                        TextFormField(
                          readOnly: true,
                          controller: _titleControler,
                          focusNode: _titleFocusNode,
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
                                  AppConstants.bulletinTitleIcon),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 32.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_contentFocusNode);
                          },
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
                                focusNode: _contentFocusNode,
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'Enter content of the event...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 16.0),
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
                                  FocusScope.of(context)
                                      .requestFocus(_crowdCapacityFocusNode);
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
                          "Crowd Capacity",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _crowdCapicityController,
                          focusNode: _crowdCapacityFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            // Allows only digits (0-9)
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  SvgPicture.asset(AppConstants.crowdCapicity),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'Please enter a valid crowd capacity';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Price Per Person",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          textInputAction: TextInputAction.next,
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          keyboardType: TextInputType.number,
                          // Still use the numeric keyboard
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            // Allows only digits (0-9)
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
                              child: SvgPicture.asset(AppConstants.person),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Total Amount",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _totalController,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(AppConstants.totalAmount),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "0",
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
                          "Tax",
                          style: TextStyle(
                              fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          // Still use the numeric keyboard
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            // Allows only digits (0-9)
                          ],
                          validator: (value) {
                            double total =
                                double.tryParse(_totalController.text) ?? 0;
                            double tax = double.tryParse(value ?? '') ?? 0;

                            if (value == null || value.isEmpty) {
                              return 'Please enter a tax amount';
                            } else if (tax > total) {
                              return 'Tax must be less than or equal to total amount';
                            }
                          },
                          textInputAction: TextInputAction.next,
                          focusNode: _taxFocusNode,
                          controller: _taxController,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_startTimeFocusNode);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(AppConstants.tax),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "0",
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
                                    " Start Time",
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
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: TextFormField(
                                      readOnly: true,
                                      validator: _validateStartTime,
                                      textInputAction: TextInputAction.next,
                                      focusNode: _startTimeFocusNode,
                                      controller: _startTimeController,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_endTimeFocusNode);
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
                                        contentPadding: EdgeInsets.symmetric(
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
                                    " End Time",
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
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: TextFormField(
                                      validator: _validateEndTime,
                                      readOnly: true,
                                      textInputAction: TextInputAction.next,
                                      controller: _endTimeController,
                                      focusNode: _endTimeFocusNode,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_dobFocusNode);
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
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * 0.42,
                                child: TextFormField(
                                  readOnly: true,
                                  validator: _validateDate,
                                  controller: _dobControler,
                                  focusNode: _dobFocusNode,
                                  decoration: InputDecoration(
                                    prefixIconConstraints: BoxConstraints(
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

                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "Longitude",
                                    hintStyle: TextStyle(
                                        color: Color(0xFFA0A0A0),
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide
                                          .none, // Removes the default border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide
                                          .none, // Removes the default border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide
                                          .none, // Removes the default border
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // if (widget.invoice != null)
            //   Positioned(
            //     top: MediaQuery.of(context).size.height * 1.55,
            //     child: InvoiceDetailView(
            //       crowdCapacity: widget.invoice!.crowdCapacity ?? "",
            //       pricePerPerson: widget.invoice!.pricePerPerson ?? "",
            //       tax: widget.invoice!.taxPercentage??"",
            //       total: widget.invoice!.grandTotal??"",
            //     ),
            //   )
          ],
        ),
      ),
    );
  }
}
