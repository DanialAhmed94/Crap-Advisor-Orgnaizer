import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../data_model/bulletinCollection_model.dart';
import '../../../provider/bulletinCollection_provider.dart';
import 'bulletinDetailView.dart';

class AllBulletinsView extends StatelessWidget {
  const AllBulletinsView({super.key});

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
                      "All News Bulletins",
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
                SizedBox(height: 10), // Space between AppBar and bulletins

                // Consumer that listens to BulletinProvider
                Consumer<BulletinProvider>(
                  builder: (context, bulletinProvider, child) {
                    // Fetch bulletins from the provider
                    List<Bulletin> bulletins = bulletinProvider.bulletins;

                    // If the list is empty, show a centered message
                    if (bulletins.isEmpty) {
                      return Center(
                        child: Text(
                          "No bulletins available",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // If bulletins are available, show them in the UI
                    return Column(
                      children: bulletins.map((bulletin) {
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
                                      color: Color(0xFFA7D8F9),
                                      shape: BoxShape.circle, // Circular shape
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AppConstants.newsBulletinMangementCardIcon,
                                        height: 30,
                                        width: 25,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    bulletin.title ?? "Unknown Title", // Display bulletin title
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
                                    onTap: (){
                                      Navigator.push(context, FadePageRouteBuilder(widget: BulletinDetailView(bulletin: bulletin,)));
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
// class AllBulletinsView extends StatelessWidget {
//   const AllBulletinsView({super.key});
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
//                     "All News Bulletins",
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
//                                 color: Color(0xFFA7D8F9),
//                                 // Background color
//                                 shape: BoxShape.circle, // Circular shape
//                               ),
//                               child: Center(
//                                 child: SvgPicture.asset(
//                                   AppConstants.newsBulletinMangementCardIcon,height: 30,width: 25,),
//                               ),
//                             ),
//                           ),
//                           Text(
//                             " Tickets sold out ",
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
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
