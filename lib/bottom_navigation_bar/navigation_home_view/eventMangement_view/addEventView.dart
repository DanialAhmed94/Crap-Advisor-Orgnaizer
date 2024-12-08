
import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../api/addEvent_api.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import 'invoice_view.dart';

class AddEventview extends StatefulWidget {
  AddEventview({super.key});

  @override
  State<AddEventview> createState() => _AddEventviewState();
}

class _AddEventviewState extends State<AddEventview> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFestivalId;

  bool _isEmpty = true;

  final TextEditingController _dobControler = TextEditingController();
  final TextEditingController _contentControler = TextEditingController();
  final TextEditingController _titleControler = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _crowdCapicityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

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
    _dobControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
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
                AppBar(
                  centerTitle: true,
                  title: Text(
                    "Add Event",
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
                  child: Form(
                    key: _formKey,
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
                                  color: Color(0xFF628C61),
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
                        SizedBox(height: 10),
                        Text(
                          "Title",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        TextFormField(
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
                                AppConstants.bulletinTitleIcon,
                                color: Color(0xFF628C61),
                              ),
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
                                controller: _contentControler,
                                focusNode: _contentFocusNode,
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'Enter content of the event...',
                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
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
                                    AppConstants.bulletinContentIcon,
                                    color: Color(0xFF628C61),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Crowd Capacity",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _crowdCapicityController,
                          focusNode: _crowdCapacityFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
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
                        Text(
                          "Price Per Person",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        Text(
                          "Total Amount",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
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
                                fontSize: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Tax",
                          style: TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                                fontSize: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: buildTimeField(
                                context,
                                label: " Start Time",
                                controller: _startTimeController,
                                validator: _validateStartTime,
                                focusNode: _startTimeFocusNode,
                                nextFocusNode: _endTimeFocusNode,
                                icon: AppConstants.timer1Icon,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: buildTimeField(
                                context,
                                label: " End Time",
                                controller: _endTimeController,
                                validator: _validateEndTime,
                                focusNode: _endTimeFocusNode,
                                nextFocusNode: _dobFocusNode,
                                icon: AppConstants.timer1Icon,
                              ),
                            ),
                          ],
                        ),
                        buildDateField(
                          context,
                          label: "Date",
                          controller: _dobControler,
                          validator: _validateDate,
                          focusNode: _dobFocusNode,
                        ),
                        SizedBox(height: 20),
                        // Submit button
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              addEvent(
                                context,
                                _titleControler.text,
                                _selectedFestivalId,
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
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color(0xFF48CF51),
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
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String? Function(String?) validator,
        required FocusNode focusNode,
        required FocusNode nextFocusNode,
        required String icon,
      }) {
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
          onTap: () => _selectTime(context, controller),
          child: AbsorbPointer(
            child: Container(
              height: 70,
              child: TextFormField(
                readOnly: true,
                validator: validator,
                textInputAction: TextInputAction.next,
                focusNode: focusNode,
                controller: controller,
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
    );
  }

  Widget buildDateField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required String? Function(String?) validator,
        required FocusNode focusNode,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Color(0xFF0A0909), fontFamily: "UbuntuMedium", fontSize: 15),
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
                controller.text = pickedDate.toString().substring(0, 10);
              });
            }
          },
          child: AbsorbPointer(
            child: Container(
              height: 70,
              child: TextFormField(
                readOnly: true,
                validator: validator,
                controller: controller,
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
                  suffixIcon: Icon(Icons.arrow_drop_down_sharp),
                  filled: true,
                  fillColor: Colors.white,
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
// import 'package:provider/provider.dart';
//
// import '../../../api/addEvent_api.dart';
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/festivalCollection_model.dart';
// import '../../../provider/festivalCollection_provider.dart';
// import 'invoice_view.dart';
//
// class AddEventview extends StatefulWidget {
//   AddEventview({super.key});
//
//   @override
//   State<AddEventview> createState() => _AddFestivalViewState();
// }
//
// class _AddFestivalViewState extends State<AddEventview> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedItem;
//   bool _isEmpty = true;
//   String? _selectedFestivalId;
//
//   final TextEditingController _dobControler = TextEditingController();
//   TextEditingController _contentControler = TextEditingController();
//   TextEditingController _titleControler = TextEditingController();
//   TextEditingController _startTimeController = TextEditingController();
//   TextEditingController _endTimeController = TextEditingController();
//   TextEditingController _crowdCapicityController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();
//   TextEditingController _totalController = TextEditingController();
//   TextEditingController _taxController = TextEditingController();
//
//   // Focus nodes for form navigation
//   final FocusNode _titleFocusNode = FocusNode();
//   final FocusNode _contentFocusNode = FocusNode();
//   final FocusNode _crowdCapacityFocusNode = FocusNode();
//   final FocusNode _priceFocusNode = FocusNode();
//   final FocusNode _taxFocusNode = FocusNode();
//   final FocusNode _startTimeFocusNode = FocusNode();
//   final FocusNode _endTimeFocusNode = FocusNode();
//   final FocusNode _dobFocusNode = FocusNode();
//
//   Future<void> _selectTime(
//       BuildContext context, TextEditingController controller) async {
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
// // Start Time Validator
//   String? _validateStartTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select a start time';
//     }
//     return null;
//   }
//
// // End Time Validator
//   String? _validateEndTime(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select an end time';
//     }
//     return null;
//   }
//
// // Date Validator
//   String? _validateDate(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select a date';
//     }
//     return null;
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _dobControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
//
//     // Update the total amount in the total controller
//     _totalController.text =
//         total.toStringAsFixed(2); // format to 2 decimal places
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     _dobControler.dispose();
//     _contentControler.dispose();
//     _endTimeController.dispose();
//     _contentControler.dispose();
//     _titleControler.dispose();
//     _crowdCapicityController.dispose();
//     _priceController.dispose();
//     _totalController.dispose();
//     _taxController.dispose();
//   }
//
//   double calculateTotalHeight(BuildContext context) {
//     double totalHeight = 0.0;
//
//     totalHeight = totalHeight +
//         MediaQuery.of(context).size.height * 0.07 +
//         MediaQuery.of(context).size.height * 0.37 +
//         MediaQuery.of(context).size.height *
//             0.9 + // Example: Height of welcome message Positioned child
//         MediaQuery.of(context).size.height *
//             0.333; // Example: Height of welcome message Positioned child
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
//                 fit: BoxFit.fill,
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
//                     "Add Event",
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
//                 height: MediaQuery.of(context).size.height * 1.35,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   color: Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       // Shadow color with 4% opacity
//                       blurRadius: 80.0,
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
//                         Consumer<FestivalProvider>(
//                           builder: (context, festivalProvider, child) {
//                             return DropdownButtonFormField<String>(
//                               value: _selectedFestivalId,
//                               decoration: InputDecoration(
//                                 prefixIcon: SvgPicture.asset(color: Color(0xFF628C61),
//                                     AppConstants.dropDownPrefixIcon),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               items: festivalProvider.festivals
//                                   .map((Festival festival) {
//                                 return DropdownMenuItem<String>(
//                                   value: festival.id.toString(),
//                                   // Store the festival ID here
//                                   child: ConstrainedBox(
//                                     constraints: BoxConstraints(
//                                       maxWidth:
//                                           MediaQuery.of(context).size.width *
//                                               0.6, // Set a max width
//                                     ),
//                                     child: Text(
//                                       festival.nameOrganizer ?? "",
//                                       // Display the festival name
//                                       overflow: TextOverflow.ellipsis,
//                                       // Manage overflow
//                                       maxLines: 1, // Show only one line
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (newValue) {
//                                 setState(() {
//                                   _selectedFestivalId =
//                                       newValue; // Save the selected festival ID
//                                 });
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please select a festival';
//                                 }
//                                 return null;
//                               },
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Title",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         TextFormField(
//                           controller: _titleControler,
//                           focusNode: _titleFocusNode,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white,
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 30.0,
//                               minHeight: 30.0,
//                             ),
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.only(left: 8),
//                               child: SvgPicture.asset(color: Color(0xFF628C61),
//                                   AppConstants.bulletinTitleIcon),
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 32.0),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a title';
//                             }
//                             return null;
//                           },
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (_) {
//                             FocusScope.of(context)
//                                 .requestFocus(_contentFocusNode);
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Content",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Container(
//                           height: MediaQuery.of(context).size.height * 0.25,
//                           width: double.infinity,
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
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           child: Stack(
//                             children: [
//                               TextFormField(
//                                 controller: _contentControler,
//                                 focusNode: _contentFocusNode,
//                                 maxLines: null,
//                                 expands: true,
//                                 keyboardType: TextInputType.multiline,
//                                 textAlignVertical: TextAlignVertical.top,
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter content of the event...',
//                                   hintStyle: TextStyle(
//                                       color: Colors.grey, fontSize: 16.0),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   contentPadding: EdgeInsets.all(16.0),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter a description';
//                                   }
//                                   return null;
//                                 },
//                                 textInputAction: TextInputAction.next,
//                                 onFieldSubmitted: (_) {
//                                   FocusScope.of(context)
//                                       .requestFocus(_crowdCapacityFocusNode);
//                                 },
//                               ),
//                               if (_isEmpty)
//                                 Center(
//                                   child: SvgPicture.asset(color: Color(0xFF628C61),
//                                       AppConstants.bulletinContentIcon),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Crowd Capacity",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           controller: _crowdCapicityController,
//                           focusNode: _crowdCapacityFocusNode,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             // Allows only digits (0-9)
//                           ],
//                           decoration: InputDecoration(
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child:
//                                   SvgPicture.asset(color: Color(0xFF628C61),AppConstants.crowdCapicity),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "0",
//                             hintStyle: TextStyle(
//                               color: Color(0xFFA0A0A0),
//                               fontFamily: "UbuntuMedium",
//                               fontSize: 15,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                           validator: (value) {
//                             if (value == null ||
//                                 value.isEmpty ||
//                                 int.tryParse(value) == null) {
//                               return 'Please enter a valid crowd capacity';
//                             }
//                             return null;
//                           },
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (_) {
//                             FocusScope.of(context)
//                                 .requestFocus(_priceFocusNode);
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Price Per Person",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           textInputAction: TextInputAction.next,
//                           controller: _priceController,
//                           focusNode: _priceFocusNode,
//                           keyboardType: TextInputType.number,
//                           // Still use the numeric keyboard
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             // Allows only digits (0-9)
//                           ],
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a valid number';
//                             }
//                             return null;
//                           },
//                           onFieldSubmitted: (_) {
//                             FocusScope.of(context).requestFocus(_taxFocusNode);
//                           },
//                           decoration: InputDecoration(
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(color: Color(0xFF628C61),AppConstants.person),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "0",
//                             hintStyle: TextStyle(
//                               color: Color(0xFFA0A0A0),
//                               fontFamily: "UbuntuMedium",
//                               fontSize: 15,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding:
//                                 EdgeInsets.symmetric(horizontal: 16.0),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Total Amount",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           readOnly: true,
//                           controller: _totalController,
//                           decoration: InputDecoration(
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(color: Color(0xFF628C61),AppConstants.totalAmount),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "0",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFA0A0A0),
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15),
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
//                           "Tax",
//                           style: TextStyle(
//                               fontFamily: "UbuntuMedium", fontSize: 15),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           keyboardType: TextInputType.number,
//                           // Still use the numeric keyboard
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             // Allows only digits (0-9)
//                           ],
//                           validator: (value) {
//                             double total =
//                                 double.tryParse(_totalController.text) ?? 0;
//                             double tax = double.tryParse(value ?? '') ?? 0;
//
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a tax amount';
//                             } else if (tax > total) {
//                               return 'Tax must be less than or equal to total amount';
//                             }
//                           },
//                           textInputAction: TextInputAction.next,
//                           focusNode: _taxFocusNode,
//                           controller: _taxController,
//                           onFieldSubmitted: (_) {
//                             FocusScope.of(context)
//                                 .requestFocus(_startTimeFocusNode);
//                           },
//                           decoration: InputDecoration(
//                             prefixIcon: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SvgPicture.asset(color: Color(0xFF628C61),AppConstants.tax),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                             hintText: "0",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFA0A0A0),
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15),
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
//                                     " Start Time",
//                                     style: TextStyle(
//                                         color: Color(0xFF0A0909),
//                                         fontFamily: "UbuntuMedium",
//                                         fontSize: 15),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () => _selectTime(
//                                         context, _startTimeController),
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.45,
//                                         child: TextFormField(
//                                           readOnly: true,
//                                           validator: _validateStartTime,
//                                           textInputAction: TextInputAction.next,
//                                           focusNode: _startTimeFocusNode,
//                                           controller: _startTimeController,
//                                           onFieldSubmitted: (_) {
//                                             FocusScope.of(context).requestFocus(
//                                                 _endTimeFocusNode);
//                                           },
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints:
//                                                 BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8, right: 8),
//                                               child: SvgPicture.asset(color: Color(0xFF628C61),
//                                                 AppConstants.timer1Icon,
//                                               ),
//                                             ),
//                                             suffixIcon: Icon(
//                                                 Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
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
//                                     " End Time",
//                                     style: TextStyle(
//                                         color: Color(0xFF0A0909),
//                                         fontFamily: "UbuntuMedium",
//                                         fontSize: 15),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   GestureDetector(
//                                     onTap: () => _selectTime(
//                                         context, _endTimeController),
//                                     child: AbsorbPointer(
//                                       child: Container(
//                                         height: 70,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.45,
//                                         child: TextFormField(
//                                           validator: _validateEndTime,
//                                           readOnly: true,
//                                           textInputAction: TextInputAction.next,
//                                           controller: _endTimeController,
//                                           focusNode: _endTimeFocusNode,
//                                           onFieldSubmitted: (_) {
//                                             FocusScope.of(context)
//                                                 .requestFocus(_dobFocusNode);
//                                           },
//                                           decoration: InputDecoration(
//                                             prefixIconConstraints:
//                                                 BoxConstraints(
//                                               minWidth: 30.0,
//                                               minHeight: 30.0,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8, right: 8),
//                                               child: SvgPicture.asset(color: Color(0xFF628C61),
//                                                 AppConstants.timer1Icon,
//                                               ),
//                                             ),
//                                             suffixIcon: Icon(
//                                                 Icons.arrow_drop_down_sharp),
//                                             filled: true,
//                                             fillColor: Colors.white,
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
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Date",
//                                 style: TextStyle(
//                                     color: Color(0xFF0A0909),
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 15),
//                               ),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               GestureDetector(
//                                 onTap: () async {
//                                   final DateTime? pickedDate =
//                                       await showDatePicker(
//                                     context: context,
//                                     initialDate: DateTime.now(),
//                                     firstDate: DateTime(1900),
//                                     lastDate: DateTime(2050),
//                                   );
//                                   if (pickedDate != null) {
//                                     setState(() {
//                                       _dobControler.text = pickedDate
//                                           .toString()
//                                           .substring(0, 10);
//                                     });
//                                   }
//                                 },
//                                 child: AbsorbPointer(
//                                   child: Container(
//                                     height: 70,
//                                     width: MediaQuery.of(context).size.width *
//                                         0.42,
//                                     child: TextFormField(
//                                       readOnly: true,
//                                       validator: _validateDate,
//                                       controller: _dobControler,
//                                       focusNode: _dobFocusNode,
//                                       decoration: InputDecoration(
//                                         prefixIconConstraints: BoxConstraints(
//                                           minWidth: 30.0,
//                                           minHeight: 30.0,
//                                         ),
//                                         prefixIcon: Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 8, right: 8),
//                                           child: SvgPicture.asset(color: Color(0xFF628C61),
//                                             AppConstants.calendarIcon,
//                                           ),
//                                         ),
//                                         suffixIcon:
//                                             Icon(Icons.arrow_drop_down_sharp),
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         hintText: "Longitude",
//                                         hintStyle: TextStyle(
//                                             color: Color(0xFFA0A0A0),
//                                             fontFamily: "UbuntuMedium",
//                                             fontSize: 15),
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(25.0),
//                                           borderSide: BorderSide
//                                               .none, // Removes the default border
//                                         ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(30.0),
//                                           borderSide: BorderSide
//                                               .none, // Removes the default border
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(30.0),
//                                           borderSide: BorderSide
//                                               .none, // Removes the default border
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 16.0),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//                 top: MediaQuery.of(context).size.height * 1.53,
//                 left: MediaQuery.of(context).size.width * 0.1,
//                 right: MediaQuery.of(context).size.width * 0.1,
//                 child: GestureDetector(
//                   onTap: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Navigator.push(
//                       //     context, FadePageRouteBuilder(widget: InvoiceView()));
//                       addEvent(
//                           context,
//                           _titleControler.text,
//                           _selectedFestivalId,
//                           _contentControler.text,
//                           _crowdCapicityController.text,
//                           _priceController.text,
//                           _totalController.text,
//                           _taxController.text,
//                           _startTimeController.text,
//                           _endTimeController.text,
//                           _dobControler.text);                    print("taped submit");
//
//                     }
//                   },
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color : Color(0xFF48CF51),
//
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Submit",
//                         style: TextStyle(
//                             fontFamily: "UbuntuBold",
//                             fontSize: 18,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
