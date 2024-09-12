import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../annim/transition.dart';
import '../../../api/addInvoice_api.dart';
import '../../../constants/AppConstants.dart';
import '../Navigation_HomeView.dart';

class InvoiceView extends StatefulWidget {
  late int? eventId;
  late String crowdCapacity;
  late String pricePerPerson;
  late String total;
  late String tax;

  InvoiceView(
      {required this.eventId,
      required this.crowdCapacity,
      required this.pricePerPerson,
      required this.total,
      required this.tax});

  @override
  State<InvoiceView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<InvoiceView> {
  final TextEditingController _dobControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  bool _isEmpty = true;
  TextEditingController _contentControler = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dobControler.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.56; // Example: Height of welcome message Positioned child

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
                    "Receipt",
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
              child: ClipPath(
                clipper: ReceiptClipper(),
                child: CustomPaint(
                  painter: BottomBorderPainter(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.43,
                    width: MediaQuery.of(context).size.width,
                    color: Color(0xFFF8FAFC),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            },
                            border: TableBorder(
                              horizontalInside:
                                  BorderSide(color: Colors.black, width: 1),
                            ),
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Sr#',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Crowd Capacity',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '\$ per person',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              // Add your rows here
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('1'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${widget.crowdCapacity}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('\$${widget.pricePerPerson}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('\$${widget.total}'),
                                  ),
                                ],
                              ),
                              // More rows can be added here
                            ],
                          ),
                          SizedBox(height: 20),
                          Divider(thickness: 2),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Subtotal: \$${widget.total}.00'),
                                Text('Tax: \$${widget.tax}.00'),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF015CB5),
                                        Color(0xFF00AAE1)
                                      ],
                                      stops: [0.0, 1.0],
                                      // 0% for the first color, 100% for the second color
                                      begin: Alignment.centerLeft,
                                      // Start from the left side
                                      end: Alignment
                                          .centerRight, // End at the right side
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Grand Total: \$${(double.parse(widget.total) - double.parse(widget.tax)).toString()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
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
            ),
            // Positioned(
            //     top: MediaQuery.of(context).size.height * 0.6,
            //     left: 16,
            //     right: 16,
            //     child: Container(
            //       height: MediaQuery.of(context).size.height * 0.3,
            //       width: MediaQuery.of(context).size.width,
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             children: [
            //               Text(
            //                 "Invoice Number",
            //                 style: TextStyle(
            //                     fontFamily: "UbuntuBold", fontSize: 18),
            //               ),
            //               Spacer(),
            //               Text(
            //                 "# SB-001598",
            //                 style: TextStyle(
            //                     fontFamily: "UbuntuBold", fontSize: 18),
            //               ),
            //             ],
            //           ),
            //           SizedBox(
            //             height: 15,
            //           ),
            //           Text(
            //             "Due Date",
            //             style:
            //                 TextStyle(fontFamily: "UbuntuBold", fontSize: 18),
            //           ),
            //           SizedBox(
            //             height: 15,
            //           ),
            //           GestureDetector(
            //             onTap: () async {
            //               final DateTime? pickedDate = await showDatePicker(
            //                 context: context,
            //                 initialDate: DateTime.now(),
            //                 firstDate: DateTime(1900),
            //                 lastDate: DateTime.now(),
            //               );
            //               if (pickedDate != null) {
            //                 setState(() {
            //                   _dobControler.text =
            //                       pickedDate.toString().substring(0, 10);
            //                 });
            //               }
            //             },
            //             child: AbsorbPointer(
            //               child: Container(
            //                 height: 70,
            //                 width: MediaQuery.of(context).size.width * 0.9,
            //                 child: TextFormField(
            //                   controller: _dobControler,
            //                   decoration: InputDecoration(
            //                     prefixIconConstraints: BoxConstraints(
            //                       minWidth: 30.0,
            //                       minHeight: 30.0,
            //                     ),
            //                     prefixIcon: Padding(
            //                       padding:
            //                           const EdgeInsets.only(left: 8, right: 8),
            //                       child: SvgPicture.asset(
            //                         AppConstants.calendarIcon,
            //                       ),
            //                     ),
            //                     suffixIcon: Icon(Icons.arrow_drop_down_sharp),
            //                     filled: true,
            //                     fillColor: Colors.white,
            //                     hintText: "Longitude",
            //                     hintStyle: TextStyle(
            //                         color: Color(0xFFA0A0A0),
            //                         fontFamily: "UbuntuMedium",
            //                         fontSize: 15),
            //                     border: OutlineInputBorder(
            //                       borderRadius: BorderRadius.circular(25.0),
            //                       borderSide: BorderSide
            //                           .none, // Removes the default border
            //                     ),
            //                     enabledBorder: OutlineInputBorder(
            //                       borderRadius: BorderRadius.circular(30.0),
            //                       borderSide: BorderSide
            //                           .none, // Removes the default border
            //                     ),
            //                     focusedBorder: OutlineInputBorder(
            //                       borderRadius: BorderRadius.circular(30.0),
            //                       borderSide: BorderSide
            //                           .none, // Removes the default border
            //                     ),
            //                     contentPadding:
            //                         EdgeInsets.symmetric(horizontal: 16.0),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SizedBox(
            //             height: 10,
            //           ),
            //           Row(
            //             children: [
            //               Text(
            //                 "Billed To",
            //                 style: TextStyle(
            //                     fontFamily: "UbuntuBold", fontSize: 18),
            //               ),
            //               Spacer(),
            //               Text(
            //                 "Joe Biden",
            //                 style: TextStyle(
            //                     fontFamily: "UbuntuBold", fontSize: 18),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     )),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.9,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLoading = true;
                    });
                    addInvoice(
                        context,
                        widget.eventId!,
                        widget.crowdCapacity,
                        widget.pricePerPerson,
                        widget.tax,
                        "${(double.parse(widget.total) - double.parse(widget.tax)).toString()}");
                  setState(() {
                    _isLoading = false;
                  });
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
                        "Save",
                        style: TextStyle(
                            fontFamily: "UbuntuBold",
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )),
            if(_isLoading)
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

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double waveWidth = 10.0;
    double waveHeight = 10.0;

    path.lineTo(0, size.height - waveHeight);

    for (double x = 0; x < size.width; x += waveWidth) {
      path.relativeQuadraticBezierTo(waveWidth / 2, waveHeight, waveWidth, 0);
    }

    path.lineTo(size.width, size.height - waveHeight);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BottomBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    double waveWidth = 10.0;
    double waveHeight = 10.0;

    path.moveTo(0, size.height - waveHeight);

    for (double x = 0; x < size.width; x += waveWidth) {
      path.relativeQuadraticBezierTo(waveWidth / 2, waveHeight, waveWidth, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
