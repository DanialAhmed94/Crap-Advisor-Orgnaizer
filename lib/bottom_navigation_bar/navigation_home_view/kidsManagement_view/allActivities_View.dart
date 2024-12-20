import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../data_model/activityCollection_model.dart';
import '../../../provider/activityCollection_provider.dart';
import 'activityDetailView.dart';

class AllActivitiesView extends StatefulWidget {
  const AllActivitiesView({super.key});

  @override
  State<AllActivitiesView> createState() => _AllActivitiesViewState();
}

class _AllActivitiesViewState extends State<AllActivitiesView> {
  bool _isLoading = false;

  Future<void> _deleteActivity(BuildContext context, Activity activity) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Activity"),
          content: Text("Are you sure you want to delete this activity?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels deletion
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms deletion
              },
              child: Text(
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

        await Provider.of<ActivityProvider>(context, listen: false)
            .deleteActivity(context, activity.id.toString());

        // Re-fetch activities to update the list
        await Provider.of<ActivityProvider>(context, listen: false)
            .fetchActivities(context);
      } catch (error) {
        // Handle any errors during deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete activity. Please try again.',
              style: TextStyle(fontFamily: "Ubuntu"),
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
                      "All Activities",
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
                ),
                SizedBox(height: 10),

                // Consumer that listens to ActivityProvider
                Consumer<ActivityProvider>(
                  builder: (context, activityProvider, child) {
                    // Fetch activities from the provider
                    List<Activity> activities = activityProvider.activities;

                    // If the list is empty, show a centered message
                    if (activities.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Text(
                            "No activities available",
                            style: TextStyle(
                              fontFamily: "UbuntuMedium",
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    // If activities are available, show them in the UI
                    return Column(
                      children: activities.map((activity) {
                        return Card(
                          elevation: 2,
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.93,
                            height: MediaQuery.of(context).size.height * 0.12,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // Icon Circle
                                Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFAEDB4E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppConstants.tile6Top,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Activity Title
                                Expanded(
                                  child: Text(
                                    activity.activityTitle ?? "No title",
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                // Buttons Column
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // View Detail button
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            FadePageRouteBuilder(
                                              widget: ActivityDetailView(activity: activity),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 85,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: Color(0xFFAEDB4E),
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
                                      SizedBox(height: 8),
                                      // Delete Button
                                      GestureDetector(
                                        onTap: () async {
                                          await _deleteActivity(context, activity);
                                        },
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent,
                                          ),
                                          child: Center(
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
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// import 'package:crap_advisor_orgnaizer/annim/transition.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
//
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/activityCollection_model.dart';
// import '../../../provider/activityCollection_provider.dart';
// import 'activityDetailView.dart';
//
// class AllActivitiesView extends StatelessWidget {
//   const AllActivitiesView({super.key});
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
//                       "All Activities",
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
//                 SizedBox(height: 10), // Space between AppBar and activities
//
//                 // Consumer that listens to ActivityProvider
//                 Consumer<ActivityProvider>(
//                   builder: (context, activityProvider, child) {
//                     // Fetch activities from the provider
//                     List<Activity> activities = activityProvider.activities;
//
//                     // If the list is empty, show a centered message
//                     if (activities.isEmpty) {
//                       return Center(
//                         child: Text(
//                           "No activities available",
//                           style: TextStyle(
//                             fontFamily: "UbuntuMedium",
//                             fontSize: 18,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       );
//                     }
//
//                     // If activities are available, show them in the UI
//                     return Column(
//                       children: activities.map((activity) {
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
//                                     width: 50.0, // Adjust the width as needed
//                                     height: 50.0, // Adjust the height as needed
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFFAEDB4E),
//                                       shape: BoxShape.circle, // Circular shape
//                                     ),
//                                     child: Center(
//                                       child: SvgPicture.asset(
//                                         AppConstants.tile6Top,
//                                         height: 30,
//                                         width: 30,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     activity.activityTitle ?? "No title", // Display activity title
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
//                                     onTap: (){
//                                       Navigator.push(context, FadePageRouteBuilder(widget: ActivityDetailView(activity: activity)));
//                                     },
//                                     child: Container(
//                                       height: 40,
//                                       width: 85,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(16),
//                                         color: Color(0xFFAEDB4E),
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
