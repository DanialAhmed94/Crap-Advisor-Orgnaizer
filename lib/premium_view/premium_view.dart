import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../annim/transition.dart';
import '../homw_view/home_view.dart';

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: Column(
                children: [
                  // Replace Positioned with Align for better layout management
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      AppConstants.newLogo,
                      height: 150,
                      width: 150,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.13,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "FestivalResource Unlimited",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "UbuntuBold",
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Center(
                      child: Text(
                        "FestivalResource like Crapadivser is completely free to all. It is intended to help smaller producers. if you do have more than a few stages and would like to expand the app are offering your festie people to include more facilities we got byou covered there too.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Annual Subscription Card
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: const Color(0xFF8AC85A),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Annual",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: 30,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Best Value Offer",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "\$999/year",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Monthly Subscription Card
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: const Color(0xFF8AC85A),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Monthly",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: 30,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Best Value Offer",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "\$999/month",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      FadePageRouteBuilder(
                        widget: HomeView(),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8AC85A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Start 7 days free trial",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enjoy a risk-free 7-day trial. No commitment required; cancel anytime",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                    child: RichText(
                      text: TextSpan(
                        text: 'By placing this order, you agree to the ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: Color(0xFFFFD400)),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: Color(0xFFFFD400)),
                          ),
                          TextSpan(
                            text: '. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
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


// import 'package:crap_advisor_orgnaizer/constants/AppConstants.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
//
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
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//             ),
//           ),
//           Positioned(
//             top: MediaQuery.of(context).size.height * 0.05,
//             left: MediaQuery.of(context).size.width * 0.281,
//             child: Image.asset(
//               AppConstants.newLogo,
//               height: 150,
//               width: 150,
//             ),
//
//           ),
//           Positioned(
//             left: 20,
//             right: 20,
//             top: MediaQuery.of(context).size.height * 0.13,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.47,
//               width: MediaQuery.of(context).size.width,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                       height: MediaQuery.of(context).size.height * 0.13,
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       decoration: BoxDecoration(
//                           color: Color(0xFFF8FAFC),
//                           borderRadius: BorderRadius.circular(16)),
//                       child: Center(
//                           child: Text(
//                         "FestivalResource Unlimited",
//                         textAlign: TextAlign.center,
//                         style:
//                             TextStyle(fontFamily: "UbuntuBold", fontSize: 32),
//                       ))),
//
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.3,
//                     width: MediaQuery.of(context).size.width * 0.7,
//                     child: Center(
//                       child: Text(
//                         textAlign: TextAlign.center,
//                         "FestivalResource like Crapadivser is completely free to all. It is intended to help smaller producers. if you do have more than a few stages and would like to expand the app are offering your festie people to include more facilities we got byou covered there too.",
//                         style:
//                             TextStyle(fontFamily: "UbuntuMedium", fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: MediaQuery.of(context).size.height*0.58,
//               right: 20,
//               left: 20,
//               //bottom: MediaQuery.of(context).size.height * 0.08,
//               child: Column(
//                 children: [
//                   Container(
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     height: 80,
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             10.0), // Set circular border radius
//                       ),
//                       color: const Color(0xFF8AC85A)
//                       ,
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 15, right: 8, top: 8, bottom: 8),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "Annual",
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 Spacer(),
//                                 Container(
//                                   height: 30,
//                                   width: 130,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                      ),
//                                   child: Center(
//                                       child: Text(
//                                         "Best Value Offer",
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 14,
//                                             color: Colors.white),
//                                       )),
//                                 )
//                               ],
//                             ),
//                             Text(
//                               "\$999/year",
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     height: 80,
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             10.0), // Set circular border radius
//                       ),
//                       color: const Color(0xFF8AC85A)
//                       ,
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             left: 15, right: 8, top: 8, bottom: 8),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "Monthly",
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 Spacer(),
//                                 Container(
//                                   height: 30,
//                                   width: 130,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       ),
//                                   child: Center(
//                                       child: Text(
//                                         "Best Value Offer",
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 14,
//                                             color: Colors.white),
//                                       )),
//                                 )
//                               ],
//                             ),
//                             Text(
//                               "\$999/year",
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   GestureDetector(
//                     onTap: () => Navigator.pushReplacement(
//                       context,
//                       FadePageRouteBuilder(
//                         widget: HomeView(),
//                       ),
//                     ),
//                     child: Center(
//                       child: Container(
//                         height: 50,
//                         width: MediaQuery.of(context).size.width * 0.9,
//                         decoration: BoxDecoration(
//                             color:const Color(0xFF8AC85A)
//                             ,
//                             borderRadius: BorderRadius.circular(20)),
//                         child: Center(
//                             child: Text(
//                               "Start 7 days free trial",
//                               style: TextStyle(color: Colors.white, fontSize: 14),
//                               textAlign: TextAlign.center,
//                             )),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     "Enjoy a risk-free 7-day trial. No commitment required; cancel anytime",
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   )
//                 ],
//               )),
//           Positioned(  top: MediaQuery.of(context).size.height*0.89,
//             right: 20,
//             left: 20,
//           child: RichText(
//             text: TextSpan(
//               text: 'By placing this order, you agree to the ', // Regular text
//               style: TextStyle(color: Colors.black), // Default text color
//               children: <TextSpan>[
//                 TextSpan(
//                   text: 'Terms of Service', // Custom color text
//                   style: TextStyle(color: Color(0xFFFFD400)), // Using #FFD400
//                 ),
//                 TextSpan(
//                   text: ' and ', // Regular text
//                   style: TextStyle(color: Colors.black),
//                 ),
//                 TextSpan(
//                   text: 'Privacy Policy', // Custom color text
//                   style: TextStyle(color: Color(0xFFFFD400)), // Using #FFD400
//                 ),
//                 TextSpan(
//                   text: '. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ],
//             ),
//           )
//
//             ,)
//         ],
//       ),
//     );
//   }
// }
