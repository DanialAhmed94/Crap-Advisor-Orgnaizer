import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transition.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/toiletCollection_model.dart';
import '../../../provider/toiletCollection_provider.dart';

class AllToiletsView extends StatefulWidget {
  const AllToiletsView({super.key});

  @override
  State<AllToiletsView> createState() => _AllToiletsViewState();
}

class _AllToiletsViewState extends State<AllToiletsView> {
  bool _isLoading = false;

  Future<void> _deleteToilet(BuildContext context, ToiletData toilet) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Toilet"),
          content: Text("Are you sure you want to delete this toilet?"),
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
        // Perform deletion using the provider
        await Provider.of<ToiletProvider>(context, listen: false)
            .deleteToilet(context, toilet.id.toString());

        // Re-fetch toilets to update the list
        await Provider.of<ToiletProvider>(context, listen: false)
            .fetchToilets(context);
      } catch (error) {
        // Handle any errors during deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete toilet. Please try again.',
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
                // AppBar
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: AppBar(
                    centerTitle: true,
                    title: Text(
                      "All Toilets",
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
                SizedBox(height: 10), // Space between AppBar and content

                // Consumer to display toilets from the provider
                Consumer<ToiletProvider>(
                  builder: (context, toiletProvider, child) {
                    List<ToiletData> toilets = toiletProvider.toilets;

                    if (toilets.isEmpty) {
                      return Center(
                        child: Text(
                          "No toilets available",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // Display toilets in a list
                    return Column(
                      children: toilets.map((toilet) {
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
                                  padding:
                                  const EdgeInsets.only(left: 16, right: 8),
                                  child: Container(
                                    width: 50.0, // Container width
                                    height: 50.0, // Container height
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD5A5FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        "https://stagingcrapadvisor.semicolonstech.com/asset/toilet_types/" +
                                            toilet.toiletType.image,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                    .expectedTotalBytes !=
                                                    null
                                                    ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                        .expectedTotalBytes ??
                                                        1)
                                                    : null,
                                              ),
                                            );
                                          }
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/images/test-toiletType.jpeg",
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    toilet.toiletType.name ?? "",
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // View Detail button
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            FadePageRouteBuilder(
                                              widget: ToiletDetailView(
                                                  toiletData: toilet),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 85,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                            color: Color(0xFF66D265),
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
                                          await _deleteToilet(context, toilet);
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

// import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletDetailView.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
//
// import '../../../annim/transition.dart';
// import '../../../constants/AppConstants.dart';
// import '../../../data_model/toiletCollection_model.dart';
// import '../../../provider/toiletCollection_provider.dart';
//
// class AllToiletsView extends StatelessWidget {
//   const AllToiletsView({super.key});
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
//                 // AppBar
//                 Container(
//                   padding: EdgeInsets.only(top: 10),
//                   child: AppBar(
//                     centerTitle: true,
//                     title: Text(
//                       "All Toilets",
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
//                 SizedBox(height: 10), // Space between AppBar and content
//
//                 // Consumer to display toilets from the provider
//                 Consumer<ToiletProvider>(
//                   builder: (context, toiletProvider, child) {
//                     List<ToiletData> toilets = toiletProvider.toilets;
//
//                     if (toilets.isEmpty) {
//                       return Center(
//                         child: Text(
//                           "No toilets available",
//                           style: TextStyle(
//                             fontFamily: "UbuntuMedium",
//                             fontSize: 18,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       );
//                     }
//
//                     // Display toilets in a list
//                     return Column(
//                       children: toilets.map((toilet) {
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
//                                   padding:
//                                       const EdgeInsets.only(left: 16, right: 8),
//                                   child: Container(
//                                     width: 50.0, // Container width
//                                     height: 50.0, // Container height
//                                     decoration: BoxDecoration(
//                                       color: Color(0xFFD5A5FF),
//                                       // Background color of the container
//                                       shape: BoxShape
//                                           .circle, // Ensures the container is circular
//                                     ),
//                                     child: ClipOval(
//                                       // Clips the image to ensure it has a circular shape
//                                       child: Image.network(
//                                         "https://stagingcrapadvisor.semicolonstech.com/asset/toilet_types/" +
//                                             toilet.toiletType.image,
//                                         fit: BoxFit.cover,
//                                         // Ensures the image fills the container and is clipped to circular shape
//                                         loadingBuilder: (BuildContext context,
//                                             Widget child,
//                                             ImageChunkEvent? loadingProgress) {
//                                           if (loadingProgress == null) {
//                                             return child; // Once the image is loaded, it displays the image
//                                           } else {
//                                             return Center(
//                                               child: CircularProgressIndicator(
//                                                 // Shows loader while image is loading
//                                                 value: loadingProgress
//                                                             .expectedTotalBytes !=
//                                                         null
//                                                     ? loadingProgress
//                                                             .cumulativeBytesLoaded /
//                                                         (loadingProgress
//                                                                 .expectedTotalBytes ??
//                                                             1)
//                                                     : null,
//                                               ),
//                                             );
//                                           }
//                                         },
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                           return Image.asset(
//                                             "assets/images/test-toiletType.jpeg",
//                                             // Fallback image if the network image fails
//                                             fit: BoxFit
//                                                 .cover, // Ensure fallback image also fits in a circular shape
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     toilet.toiletType.name ?? "",
//                                     // Use appropriate model field
//                                     style: TextStyle(
//                                       fontFamily: "UbuntuMedium",
//                                       fontSize: 15,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 25),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         FadePageRouteBuilder(
//                                           widget: ToiletDetailView(
//                                               toiletData: toilet),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       height: 40,
//                                       width: 85,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(16),
//                                         color: Color(0xFF66D265),
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
