import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/performanceDetailaview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transition.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/performanceCollection_model.dart';
import '../../../provider/performanceCollection_provider.dart';

class AllPerformancesView extends StatelessWidget {
  const AllPerformancesView({super.key});

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
                      "All Performances",
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
                SizedBox(height: 10), // Space between AppBar and performances
                Consumer<PerformanceProvider>(
                  builder: (context, performanceProvider, child) {
                    // Access the performances list from the provider
                    List<Performance> performances = performanceProvider.performances;

                    // If the list is empty, show a centered message
                    if (performances.isEmpty) {
                      return Center(
                        child: Text(
                          "No performances available",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // If the list is not empty, show the performance cards
                    return Column(
                      children: performances.map((performance) {
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
                                      color: Color(0xFF8AC85A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(AppConstants.performancesIcon),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    performance.performanceTitle ?? "", // Use the appropriate field from your model
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, FadePageRouteBuilder(widget: PerformanceDetailView(performance: performance,)));
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 85,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Color(0xFF8AC85A),
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

// import 'package:crap_advisor_orgnaizer/annim/transition.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../constants/AppConstants.dart';
//
// class AllPerformancesView extends StatelessWidget {
//   const AllPerformancesView({super.key});
//
//   double calculateTotalHeight(BuildContext context) {
//     double totalHeight = 0.0;
//
//     totalHeight = totalHeight +
//         MediaQuery.of(context).size.height * 0.07 +
//         MediaQuery.of(context).size.height * 0.37 +
//         MediaQuery.of(context).size.height *
//             0.58 + // Example: Height of welcome message Positioned child
//         MediaQuery.of(context).size.height *
//             0.3; // Example: Height of welcome message Positioned child
//
//     return totalHeight;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: Stack(
//           children: [
//             Container(height: calculateTotalHeight(context)),
//             Positioned.fill(
//               child: Image.asset(
//                 AppConstants.planBackground,
//                 fit: BoxFit.cover,
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
//                     "All Performances",
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
//               top: MediaQuery.of(context).size.height * 0.13,
//               left: MediaQuery.of(context).size.width * 0.066,
//               right: MediaQuery.of(context).size.width * 0.066,
//               child: Column(
//                 children: [
//                   Card(
//                     elevation: 2,
//                     color: Colors.white,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.white,
//                       ),
//                       width: MediaQuery.of(context).size.width * 0.93,
//                       height: MediaQuery.of(context).size.height * 0.1,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 16, right: 8),
//                             child: Container(
//                               width: 50.0, // Adjust the width as needed
//                               height: 50.0, // Adjust the height as needed
//                               decoration: BoxDecoration(
//                                 color: Color(0xFFFFD0B0),
//                                 // Background color
//                                 shape: BoxShape.circle, // Circular shape
//                               ),
//                               child: Center(
//                                 child: SvgPicture.asset(
//                                     AppConstants.performancesIcon),
//                               ),
//                             ),
//                           ),
//                           Text(
//                             "Music",
//                             style: TextStyle(
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15,
//                                 overflow: TextOverflow.ellipsis),
//                             maxLines: 2,
//                           ),
//                           Spacer(),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 25),
//                             child: Container(
//                               height: 40,
//                               width: 85,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: Colors.blue),
//                               child: Center(
//                                 child: Text(
//                                   "View Detail",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontFamily: "UbuntuMedium",
//                                       fontSize: 12,
//                                       color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Card(
//                     elevation: 2,
//                     color: Colors.white,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.white,
//                       ),
//                       width: MediaQuery.of(context).size.width * 0.93,
//                       height: MediaQuery.of(context).size.height * 0.1,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 16, right: 8),
//                             child: Container(
//                               width: 50.0, // Adjust the width as needed
//                               height: 50.0, // Adjust the height as needed
//                               decoration: BoxDecoration(
//                                 color: Color(0xFFFFD0B0),
//                                 // Background color
//                                 shape: BoxShape.circle, // Circular shape
//                               ),
//                               child: Center(
//                                 child: SvgPicture.asset(
//                                     AppConstants.performancesIcon),
//                               ),
//                             ),
//                           ),
//                           Text(
//                             "Cultural",
//                             style: TextStyle(
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 15,
//                                 overflow: TextOverflow.ellipsis),
//                             maxLines: 2,
//                           ),
//                           Spacer(),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 25),
//                             child: Container(
//                               height: 40,
//                               width: 85,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   color: Colors.blue),
//                               child: Center(
//                                 child: Text(
//                                   "View Detail",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontFamily: "UbuntuMedium",
//                                       fontSize: 12,
//                                       color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//
//
//
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
