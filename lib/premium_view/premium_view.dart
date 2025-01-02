// import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import '../annim/transition.dart';
// import '../homw_view/home_view.dart';
//
// class PremiumView extends StatelessWidget {
//   const PremiumView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               AppConstants.planBackground,
//               fit: BoxFit.fill,
//             ),
//           ),
//           SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).size.height * 0.1,
//               ),
//               child: Column(
//                 children: [
//                   // Replace Positioned with Align for better layout management
//                   Align(
//                     alignment: Alignment.topCenter,
//                     child: Image.asset(
//                       AppConstants.newLogo,
//                       height: 150,
//                       width: 150,
//                     ),
//                   ),
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.13,
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFF8FAFC),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "FestivalResource",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: "UbuntuBold",
//                           fontSize: 32,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     width: MediaQuery.of(context).size.width * 0.75,
//                     constraints: BoxConstraints(
//                       // Set a maximum height instead of a fixed height
//                       maxHeight: MediaQuery.of(context).size.height * 0.5,
//                     ),
//                     padding: EdgeInsets.all(16.0), // Add padding for consistent spacing
//
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
//                         children: [
//                           RichText(
//                             textAlign: TextAlign.left,
//                             text: TextSpan(
//                               text: "FestivalResource like Crapadivser is completely free to sub 5000 capacity events and has a host of free features ",
//                               style: TextStyle(
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                               children: <TextSpan>[
//                                 TextSpan(
//                                   text: "included.",
//                                   style: TextStyle(
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold, // Emphasize "included"
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           RichText(
//                             textAlign: TextAlign.left,
//                             text: TextSpan(
//                               text: "In FestivalResource toolkit you can list your performances, post running orders and upload bulletins and more all for ",
//                               style: TextStyle(
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                               children: <TextSpan>[
//                                 TextSpan(
//                                   text: "free.",
//                                   style: TextStyle(
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold, // Emphasize "free"
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           RichText(
//                             textAlign: TextAlign.left,
//                             text: TextSpan(
//                               text: "Festival Resource Toolkit is created in the spirit of festival and is intended to help smaller festivals and events offering a free resource app for their clients. If you do have more than a couple of stages and have a bigger capacity, FestivalResource is upgradeable for bigger ",
//                               style: TextStyle(
//                                 fontFamily: "UbuntuMedium",
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                               children: <TextSpan>[
//                                 TextSpan(
//                                   text: "events.",
//                                   style: TextStyle(
//                                     fontFamily: "UbuntuMedium",
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold, // Emphasize "events"
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   // Annual Subscription Card
//                   Container(
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     height: 80,
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       color: Color(0xFF5C9D37),
//                       child: Center(
//                         child: Text(
//                           "Free App",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontFamily: "InterMedium",
//                             fontSize: 20,
//                           ),
//                         ),
//                       ),
//                       // child: Padding(
//                       //   padding: const EdgeInsets.all(8.0),
//                       //   child: Column(
//                       //     crossAxisAlignment: CrossAxisAlignment.start,
//                       //     children: [
//                       //       Row(
//                       //         children: [
//                       //           Text(
//                       //             "Annual",
//                       //             style: TextStyle(
//                       //               fontSize: 16,
//                       //               color: Colors.white,
//                       //               fontWeight: FontWeight.bold,
//                       //             ),
//                       //           ),
//                       //           Spacer(),
//                       //           Container(
//                       //             height: 30,
//                       //             width: 130,
//                       //             decoration: BoxDecoration(
//                       //               borderRadius: BorderRadius.circular(10),
//                       //             ),
//                       //             child: Center(
//                       //               child: Text(
//                       //                 "Best Value Offer",
//                       //                 style: TextStyle(
//                       //                   fontWeight: FontWeight.bold,
//                       //                   fontSize: 14,
//                       //                   color: Colors.white,
//                       //                 ),
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         ],
//                       //       ),
//                       //       Text(
//                       //         "\$0/year",
//                       //         style: TextStyle(
//                       //           fontSize: 16,
//                       //           color: Colors.white,
//                       //           fontWeight: FontWeight.bold,
//                       //         ),
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   // Monthly Subscription Card
//                   GestureDetector(
//                     onTap: () => Navigator.pushReplacement(
//                       context,
//                       FadePageRouteBuilder(
//                         widget: HomeView(),
//                       ),
//                     ),
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       height: 80,
//                       child: Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         color: const Color(0xFF8AC85A),
//                         child: Center(
//                           child: Text(
//                             "High Capacity event Start 7-day free trial",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontFamily: "InterMedium",
//                               fontSize: 20,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   Text(
//                     "Enjoy a risk-free 7-day trial. No commitment required; cancel anytime",
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'By placing this order, you agree to the ',
//                         style: TextStyle(color: Colors.black),
//                         children: <TextSpan>[
//                           TextSpan(
//                             text: 'Terms of Service',
//                             style: TextStyle(color: Color(0xFFFFD400)),
//                           ),
//                           TextSpan(
//                             text: ' and ',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                           TextSpan(
//                             text: 'Privacy Policy',
//                             style: TextStyle(color: Color(0xFFFFD400)),
//                           ),
//                           TextSpan(
//                             text: '. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
//                             style: TextStyle(color: Colors.black),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
