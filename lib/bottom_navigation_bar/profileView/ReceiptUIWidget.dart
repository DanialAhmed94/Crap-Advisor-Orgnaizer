import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../constants/AppConstants.dart';

class RecieptView extends StatelessWidget {
  final int? eventId;
  final String crowdCapacity;
  final String pricePerPerson;
  final String total;
  final String tax;
  final String invoiceNumber;
  final String dob;

  RecieptView({
    required this.eventId,
    required this.crowdCapacity,
    required this.pricePerPerson,
    required this.total,
    required this.tax,
    required this.invoiceNumber,
    required this.dob,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice #$invoiceNumber',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Date: $dob'),
            SizedBox(height: 10),
            Table(
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.black, width: 1),
              ),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Sr#',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Crowd Capacity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '\$ per person',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('1'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(crowdCapacity),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('\$$pricePerPerson'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('\$$total'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(thickness: 2),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Subtotal: \$$total.00'),
                  Text('Tax: \$$tax.00'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xFFAEDB4E),

                    ),
                    child: Center(
                      child: Text(
                        'Grand Total: \$${total} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
