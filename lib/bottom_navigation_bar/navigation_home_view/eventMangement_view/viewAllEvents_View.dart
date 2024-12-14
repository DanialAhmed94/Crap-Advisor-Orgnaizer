// event_card.dart

import 'dart:ui';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import SpinKit

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../data_model/eventColection_model.dart';
import '../../../provider/eventCollection_provider.dart';
import '../../../utilities/utilities.dart';
import 'eventDetailView.dart';
import 'package:crap_advisor_orgnaizer/annim/transition.dart';
// all_events_view.dart



class AllEventsView extends StatelessWidget {
  const AllEventsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch the screen size for responsive design if needed
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          // Background image
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // AppBar Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          icon: SvgPicture.asset(AppConstants.backIcon),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "All Events",
                              style: TextStyle(
                                fontFamily: "Ubuntu",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        // Placeholder for symmetry (can be an empty container)
                        const SizedBox(width: 48), // Adjust based on back button size
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Events List
                  Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      // Fetch events from the provider
                      List<EventData> events = eventProvider.events;

                      // If the list is empty, show a centered message
                      if (events.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "No events available",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }

                      // If events are available, display them using EventCard
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return EventCard(event: events[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class EventCard extends StatefulWidget {
  final EventData event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with SingleTickerProviderStateMixin {
  bool _isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    // Fetch necessary event details
    final String title = widget.event.eventTitle ?? "No Title";
    final String festivalName = widget.event.festival?.nameOrganizer ?? "No Festival";
    final String date = widget.event.startDate ?? "No Date";

    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Event Icon
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF48CF51),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppConstants.eventMangementCardIcon,
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Festival Name
                      Text(
                        "Festival: $festivalName",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      // Event Date
                      Text(
                        "Date: $date",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Column(
                  children: [
                    // View Detail Button
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          FadePageRouteBuilder(
                            widget: EventDetailView(event: widget.event),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48CF51),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        "View Detail",
                        style: TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Delete Button
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () async {
                        await _deleteEvent(context, widget.event);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Loading Overlay
        if (_isLoading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Match the card's border radius
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitCircle(
                          color: Colors.white,
                          size: 50.0,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Deleting...",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Ubuntu",
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _deleteEvent(BuildContext context, EventData event) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels deletion
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms deletion
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Perform deletion using the provider
        bool success = await Provider.of<EventProvider>(context, listen: false)
            .deleteEvent(context, event.id.toString());

        if (success) {
          // Re-fetch events to update the list
          await Provider.of<EventProvider>(context, listen: false)
              .fetchEvents(context);

          // Optionally, show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Event deleted successfully.',
                style: TextStyle(fontFamily: "Ubuntu"),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        // Handle any errors during deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete event: $error',
              style: const TextStyle(fontFamily: "Ubuntu"),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}



// import 'package:crap_advisor_orgnaizer/annim/transition.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
//
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/eventColection_model.dart';
// import '../../../provider/eventCollection_provider.dart';
// import '../../../provider/invoiceCOLLECTION-provider.dart';
// import 'eventDetailView.dart';
//
// class AllEventsView extends StatelessWidget {
//   const AllEventsView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: Image.asset(
//               AppConstants.planBackground,
//               fit: BoxFit.fill,
//             ),
//           ),
//           // Main content
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   padding: EdgeInsets.only(top: 10),
//                   child: AppBar(
//                     centerTitle: true,
//                     title: Text(
//                       "All Events",
//                       style: TextStyle(
//                         fontFamily: "Ubuntu",
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     leading: IconButton(
//                       icon: SvgPicture.asset(AppConstants.backIcon),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     backgroundColor: Colors.transparent,
//                     elevation: 0, // Remove shadow
//                   ),
//                 ),
//                 SizedBox(height: 10), // Space between AppBar and events
//
//                 // Consumer that listens to EventProvider
//                 Consumer<EventProvider>(
//                   builder: (context, eventProvider, child) {
//                     // Fetch events from the provider
//                     List<EventData> events = eventProvider.events;
//
//                     // If the list is empty, show a centered message
//                     if (events.isEmpty) {
//                       return Center(
//                         child: Text(
//                           "No events available",
//                           style: TextStyle(
//                             fontFamily: "UbuntuMedium",
//                             fontSize: 18,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       );
//                     }
//                     return Column(
//                       children: events.map((event) {
//                         return Card(
//                           elevation: 2,
//                           color: Colors.white,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Colors.white,
//                             ),
//                             width: MediaQuery.of(context).size.width * 0.93,
//                             height: MediaQuery.of(context).size.height * 0.1,
//                             child: Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 16, right: 8),
//                                   child: Container(
//                                     width: 50.0,
//                                     height: 50.0,
//                                     decoration: BoxDecoration(
//                                       color:Color(0xFF48CF51),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Center(
//                                       child: SvgPicture.asset(
//                                         AppConstants.eventMangementCardIcon,
//                                         height: 30,
//                                         width: 30,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     event.eventTitle ?? "No title",
//                                     style: TextStyle(
//                                       fontFamily: "UbuntuMedium",
//                                       fontSize: 15,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     maxLines: 2,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 25),
//                                   child: GestureDetector(
//                                     onTap: () {
//
//                                       Navigator.push(
//                                         context,
//                                         FadePageRouteBuilder(
//                                           widget: EventDetailView(
//                                             event: event,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       height: 40,
//                                       width: 85,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(16),
//                                         color : Color(0xFF48CF51),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           "View Detail",
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontFamily: "UbuntuMedium",
//                                             fontSize: 12,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     );
//
//                     // If events are available, show them in the UI
//                     // return Column(
//                     //   children: events.map((event) {
//                     //     return Card(
//                     //       elevation: 2,
//                     //       color: Colors.white,
//                     //       child: Container(
//                     //         decoration: BoxDecoration(
//                     //           borderRadius: BorderRadius.circular(10),
//                     //           color: Colors.white,
//                     //         ),
//                     //         width: MediaQuery.of(context).size.width * 0.93,
//                     //         height: MediaQuery.of(context).size.height * 0.1,
//                     //         child: Row(
//                     //           children: [
//                     //             Padding(
//                     //               padding: const EdgeInsets.only(left: 16, right: 8),
//                     //               child: Container(
//                     //                 width: 50.0, // Adjust the width as needed
//                     //                 height: 50.0, // Adjust the height as needed
//                     //                 decoration: BoxDecoration(
//                     //                   color: Color(0xFFD3FCFF),
//                     //                   shape: BoxShape.circle, // Circular shape
//                     //                 ),
//                     //                 child: Center(
//                     //                   child: SvgPicture.asset(
//                     //                     AppConstants.eventMangementCardIcon,
//                     //                     height: 30,
//                     //                     width: 30,
//                     //                   ),
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //             Expanded(
//                     //               child: Text(
//                     //                 event.eventTitle ?? "No title", // Display event title
//                     //                 style: TextStyle(
//                     //                   fontFamily: "UbuntuMedium",
//                     //                   fontSize: 15,
//                     //                   overflow: TextOverflow.ellipsis,
//                     //                 ),
//                     //                 maxLines: 2,
//                     //               ),
//                     //             ),
//                     //             Padding(
//                     //               padding: const EdgeInsets.only(right: 25),
//                     //               child: Container(
//                     //                 height: 40,
//                     //                 width: 85,
//                     //                 decoration: BoxDecoration(
//                     //                   borderRadius: BorderRadius.circular(16),
//                     //                   color: Colors.blue,
//                     //                 ),
//                     //                 child: Center(
//                     //                   child: Text(
//                     //                     "View Detail",
//                     //                     textAlign: TextAlign.center,
//                     //                     style: TextStyle(
//                     //                       fontFamily: "UbuntuMedium",
//                     //                       fontSize: 12,
//                     //                       color: Colors.white,
//                     //                     ),
//                     //                   ),
//                     //                 ),
//                     //               ),
//                     //             ),
//                     //           ],
//                     //         ),
//                     //       ),
//                     //     );
//                     //   }).toList(),
//                     // );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
