import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/eventMangement_view/viewAllEvents_View.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../provider/eventCollection_provider.dart';
import '../../../provider/invoiceCOLLECTION-provider.dart';
import 'addEventView.dart';
import 'eventDetailView.dart';

class AddEventManagementView extends StatelessWidget {
  const AddEventManagementView({super.key});

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.58 + // Example: Height of welcome message Positioned child
        MediaQuery.of(context).size.height *
            0.09; // Example: Height of welcome message Positioned child

    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Stack(
          children: [
            Container(height: calculateTotalHeight(context)),
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
                    "Event Management",
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
              left: MediaQuery.of(context).size.width * 0.066,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.87,
                decoration: BoxDecoration(
                    color: Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Text(
                          "Add",
                          style: TextStyle(
                              height: 1.0,
                              fontFamily: "UbuntuBold",
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Text(
                          "Event",
                          style: TextStyle(
                              height: 1.0,
                              fontFamily: "UbuntuBold",
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: SvgPicture.asset(AppConstants.forwardIcon),
                          onTap: (){
                          Navigator.push(context, FadePageRouteBuilder(widget: AddEventview()));
                          },),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                      ],
                    ),
                    SvgPicture.asset(AppConstants.eventMangementCardIcon),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.42,
              left: MediaQuery.of(context).size.width * 0.066,
              child: Row(
                children: [
                  Text(
                    "Events",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "UbuntuMedium",
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.49),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: AllEventsView()));
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "UbuntuMedium",
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.48,
        left: MediaQuery.of(context).size.width * 0.066,
        right: MediaQuery.of(context).size.width * 0.066,
        child: FutureBuilder<void>(
          future: Provider.of<EventProvider>(context, listen: false)
              .fetchEvents(context)
              .then((_) {
            // Attempt to fetch invoices, but don't stop events if it fails
            return Provider.of<InvoiceProvider>(context, listen: false)
                .fetchInvoices(context)
                .catchError((error) {
              // Handle the invoice fetch failure
              print("Failed to fetch invoices: $error");
              return null; // Continue execution even if invoice fetching fails
            });
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(), // Show loading indicator
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Failed to load data: ${snapshot.error}",
                  style: TextStyle(
                    fontFamily: "UbuntuMedium",
                    fontSize: 18,
                  ),
                ),
              );
            } else {
              final events = Provider.of<EventProvider>(context).events;

              if (events.isEmpty) {
                return Center(
                  child: Text(
                    "No events available!",
                    style: TextStyle(
                      fontFamily: "UbuntuMedium",
                      fontSize: 18,
                    ),
                  ),
                );
              } else {
                final maxEventsToShow = 4; // Limit the number of events to show
                final eventsToShow = events.take(maxEventsToShow).toList();

                return Column(
                  children: eventsToShow.map((event) {
                    return Card(
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        width: MediaQuery.of(context).size.width * 0.93,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 8),
                              child: Container(
                                width: 50.0, // Adjust the width as needed
                                height: 50.0, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  color: Color(0xFFD3FCFF), // Background color
                                  shape: BoxShape.circle, // Circular shape
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    AppConstants.eventMangementCardIcon,
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                event.eventTitle ?? "No title", // Use event title
                                style: TextStyle(
                                  fontFamily: "UbuntuMedium",
                                  fontSize: 15,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: GestureDetector(
                                  onTap: () {
                                    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
                                    final invoice = invoiceProvider.getInvoiceByEventId(int.parse(event.id.toString()));

                                    Navigator.push(
                                      context,
                                      FadePageRouteBuilder(
                                        widget: EventDetailView(event: event,invoice: invoice,),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 85,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "View Detail",
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


                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            }
          },
        ),
      )

      // Positioned(
      //   top: MediaQuery.of(context).size.height * 0.48,
      //   left: MediaQuery.of(context).size.width * 0.066,
      //   right: MediaQuery.of(context).size.width * 0.066,
      //   child: FutureBuilder<void>(
      //     future: Provider.of<EventProvider>(context, listen: false).fetchEvents(context),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return Center(
      //           child: CircularProgressIndicator(), // Show loading indicator
      //         );
      //       } else if (snapshot.hasError) {
      //         return Center(
      //           child: Text(
      //             "Failed to load events: ${snapshot.error}",
      //             style: TextStyle(
      //               fontFamily: "UbuntuMedium",
      //               fontSize: 18,
      //             ),
      //           ),
      //         );
      //       } else {
      //         final events = Provider.of<EventProvider>(context).events;
      //
      //         if (events.isEmpty) {
      //           return Center(
      //             child: Text(
      //               "No events available!",
      //               style: TextStyle(
      //                 fontFamily: "UbuntuMedium",
      //                 fontSize: 18,
      //               ),
      //             ),
      //           );
      //         } else {
      //           final maxEventsToShow = 4; // Limit the number of events to show
      //           final eventsToShow = events.take(maxEventsToShow).toList();
      //
      //           return Column(
      //             children: eventsToShow.map((event) {
      //               return Card(
      //                 elevation: 2,
      //                 color: Colors.white,
      //                 child: Container(
      //                   decoration: BoxDecoration(
      //                     borderRadius: BorderRadius.circular(10),
      //                     color: Colors.white,
      //                   ),
      //                   width: MediaQuery.of(context).size.width * 0.93,
      //                   height: MediaQuery.of(context).size.height * 0.1,
      //                   child: Row(
      //                     children: [
      //                       Padding(
      //                         padding: const EdgeInsets.only(left: 16, right: 8),
      //                         child: Container(
      //                           width: 50.0, // Adjust the width as needed
      //                           height: 50.0, // Adjust the height as needed
      //                           decoration: BoxDecoration(
      //                             color: Color(0xFFD3FCFF), // Background color
      //                             shape: BoxShape.circle, // Circular shape
      //                           ),
      //                           child: Center(
      //                             child: SvgPicture.asset(
      //                               AppConstants.eventMangementCardIcon,
      //                               height: 30,
      //                               width: 30,
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                       Expanded(
      //                         child: Text(
      //                           event.eventTitle ?? "No title", // Use event title
      //                           style: TextStyle(
      //                             fontFamily: "UbuntuMedium",
      //                             fontSize: 15,
      //                             overflow: TextOverflow.ellipsis,
      //                           ),
      //                           maxLines: 2,
      //                         ),
      //                       ),
      //                       Spacer(),
      //                       Padding(
      //                         padding: const EdgeInsets.only(right: 25),
      //                         child: Container(
      //                           height: 40,
      //                           width: 85,
      //                           decoration: BoxDecoration(
      //                             borderRadius: BorderRadius.circular(16),
      //                             color: Colors.blue,
      //                           ),
      //                           child: Center(
      //                             child: Text(
      //                               "View Detail",
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
      //                     ],
      //                   ),
      //                 ),
      //               );
      //             }).toList(),
      //           );
      //         }
      //       }
      //     },
      //   ),
      // ),

      ],
        ),
      ),
    );
  }
}
