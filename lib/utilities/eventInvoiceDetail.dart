import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../annim/transition.dart';
import '../../../api/addInvoice_api.dart';
import '../../../constants/AppConstants.dart';

class InvoiceDetailView extends StatefulWidget {
  late int? eventId;
  late String crowdCapacity;
  late String pricePerPerson;
  late String total;
  late String tax;

  InvoiceDetailView(
      { this.eventId,
        required this.crowdCapacity,
        required this.pricePerPerson,
        required this.total,
        required this.tax});

  @override
  State<InvoiceDetailView> createState() => _AddFestivalViewState();
}

class _AddFestivalViewState extends State<InvoiceDetailView> {
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
        child: Container(
          height: calculateTotalHeight(context),
          child:  ClipPath(
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
