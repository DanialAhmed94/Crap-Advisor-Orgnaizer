import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../data_model/eventColection_model.dart';
import '../../../provider/eventCollection_provider.dart';
import '../../../provider/invoiceCOLLECTION-provider.dart';
import 'eventDetailView.dart';

class AllEventsView extends StatelessWidget {
  const AllEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: AppBar(
                    centerTitle: true,
                    title: Text(
                      "All Events",
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
                    elevation: 0, // Remove shadow
                  ),
                ),
                SizedBox(height: 10), // Space between AppBar and events

                // Consumer that listens to EventProvider
                Consumer<EventProvider>(
                  builder: (context, eventProvider, child) {
                    // Fetch events from the provider
                    List<EventData> events = eventProvider.events;

                    // If the list is empty, show a centered message
                    if (events.isEmpty) {
                      return Center(
                        child: Text(
                          "No events available",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: events.map((event) {
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
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD3FCFF),
                                      shape: BoxShape.circle,
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
                                    event.eventTitle ?? "No title",
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: GestureDetector(
                                    onTap: () {
                                      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
                                      final invoice = invoiceProvider.getInvoiceByEventId(int.parse(event.id.toString()));

                                      Navigator.push(
                                        context,
                                        FadePageRouteBuilder(
                                          widget: EventDetailView(
                                            event: event,
                                            invoice: invoice,
                                          ),
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
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );

                    // If events are available, show them in the UI
                    // return Column(
                    //   children: events.map((event) {
                    //     return Card(
                    //       elevation: 2,
                    //       color: Colors.white,
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(10),
                    //           color: Colors.white,
                    //         ),
                    //         width: MediaQuery.of(context).size.width * 0.93,
                    //         height: MediaQuery.of(context).size.height * 0.1,
                    //         child: Row(
                    //           children: [
                    //             Padding(
                    //               padding: const EdgeInsets.only(left: 16, right: 8),
                    //               child: Container(
                    //                 width: 50.0, // Adjust the width as needed
                    //                 height: 50.0, // Adjust the height as needed
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xFFD3FCFF),
                    //                   shape: BoxShape.circle, // Circular shape
                    //                 ),
                    //                 child: Center(
                    //                   child: SvgPicture.asset(
                    //                     AppConstants.eventMangementCardIcon,
                    //                     height: 30,
                    //                     width: 30,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Text(
                    //                 event.eventTitle ?? "No title", // Display event title
                    //                 style: TextStyle(
                    //                   fontFamily: "UbuntuMedium",
                    //                   fontSize: 15,
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //                 maxLines: 2,
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.only(right: 25),
                    //               child: Container(
                    //                 height: 40,
                    //                 width: 85,
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(16),
                    //                   color: Colors.blue,
                    //                 ),
                    //                 child: Center(
                    //                   child: Text(
                    //                     "View Detail",
                    //                     textAlign: TextAlign.center,
                    //                     style: TextStyle(
                    //                       fontFamily: "UbuntuMedium",
                    //                       fontSize: 12,
                    //                       color: Colors.white,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //   }).toList(),
                    // );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
