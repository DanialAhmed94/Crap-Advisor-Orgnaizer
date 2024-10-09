import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart'; // Import Provider

import '../../constants/AppConstants.dart';
import '../../provider/invoiceCOLLECTION-provider.dart';
import 'ReceiptUIWidget.dart'; // Adjust the path as needed

class RecieptsView extends StatefulWidget {
  const RecieptsView({super.key});

  @override
  State<RecieptsView> createState() => _RecieptsViewState();
}

class _RecieptsViewState extends State<RecieptsView> {
  @override
  void initState() {
    super.initState();
    // Fetch invoices after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false)
          .fetchInvoices(context);
    });
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.9 + // Example: Height of welcome message Positioned child
        MediaQuery.of(context).size.height *
            0.333; // Example: Height of welcome message Positioned child

    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: calculateTotalHeight(context),
          ),
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              centerTitle: true,
              title: const Text(
                "Receipts",
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
              elevation: 0, // Remove shadow
            ),
          ),
          // Positioned ListView for invoices
          Positioned(
            top: kToolbarHeight + 25,
            // Adjust as needed
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<InvoiceProvider>(
              builder: (context, invoiceProvider, child) {
                if (invoiceProvider.invoices.isEmpty) {
                  return Center(
                      child: Text("There is nothing to show here..."));
                } else {
                  return ListView.builder(
                    itemCount: invoiceProvider.invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoiceProvider.invoices[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.1,
                              decoration: BoxDecoration(
                                color: Color(0xFFAEDB4E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        //mainAxisAlignment: MainAxisAlignment.center, // Vertically center the text
                                        children: [
                                          Text(
                                            "Festival Name",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${invoice.festivalName}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow
                                                .ellipsis, // Add ellipsis to long text
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8, top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Event Name",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${invoice.eventName}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow
                                                .ellipsis, // Add ellipsis to long text
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RecieptView(
                            eventId: invoice.eventId,
                            crowdCapacity: invoice.crowdCapacity,
                            pricePerPerson: invoice.pricePerPerson,
                            tax: invoice.taxPercentage,
                            total: invoice.grandTotal,
                            invoiceNumber: invoice.invoicNumber,
                            dob: invoice.date,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Divider(),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
