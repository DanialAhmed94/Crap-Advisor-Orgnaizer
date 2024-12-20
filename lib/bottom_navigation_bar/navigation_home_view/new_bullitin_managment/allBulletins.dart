
import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../data_model/bulletinCollection_model.dart';
import '../../../provider/bulletinCollection_provider.dart';
import 'bulletinDetailView.dart';

class AllBulletinsView extends StatefulWidget {
  const AllBulletinsView({super.key});

  @override
  State<AllBulletinsView> createState() => _AllBulletinsViewState();
}

class _AllBulletinsViewState extends State<AllBulletinsView> {
  bool _isLoading = false;

  Future<void> _deleteBulletin(BuildContext context, Bulletin bulletin) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Bulletin"),
          content: Text("Are you sure you want to delete this bulletin?"),
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
        // Perform deletion using the provider's delete method
        await Provider.of<BulletinProvider>(context, listen: false)
            .deleteBulletin(context, bulletin.id.toString());

        // Re-fetch bulletins to update the list
        await Provider.of<BulletinProvider>(context, listen: false)
            .fetchBulletins(context);
      } catch (error) {
        // Handle any errors during deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete bulletin. Please try again.',
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
                SizedBox(height: 10),

                // Consumer that listens to BulletinProvider
                Consumer<BulletinProvider>(
                  builder: (context, bulletinProvider, child) {
                    // Fetch bulletins from the provider
                    List<Bulletin> bulletins = bulletinProvider.bulletins;

                    // If the list is empty, show a centered message
                    if (bulletins.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: Text(
                            "No bulletins available",
                            style: TextStyle(
                              fontFamily: "UbuntuMedium",
                              fontSize: 18,
                              color: Colors.black54,
                            ),
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
                                    color: Color(0xFFA7D8F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppConstants.newsBulletinMangementCardIcon,
                                      height: 30,
                                      width: 25,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Bulletin Title
                                Expanded(
                                  child: Text(
                                    bulletin.title ?? "Unknown Title",
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Buttons Column
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // View Detail button
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          FadePageRouteBuilder(
                                            widget: BulletinDetailView(bulletin: bulletin),
                                          ),
                                        );
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
                                    SizedBox(height: 8),
                                    // Delete Button
                                    GestureDetector(
                                      onTap: () async {
                                        await _deleteBulletin(context, bulletin);
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
// import '../../../data_model/bulletinCollection_model.dart';
// import '../../../provider/bulletinCollection_provider.dart';
// import 'bulletinDetailView.dart';
//
// class AllBulletinsView extends StatelessWidget {
//   const AllBulletinsView({super.key});
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
//                       "All News Bulletins",
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
//                 SizedBox(height: 10), // Space between AppBar and bulletins
//
//                 // Consumer that listens to BulletinProvider
//                 Consumer<BulletinProvider>(
//                   builder: (context, bulletinProvider, child) {
//                     // Fetch bulletins from the provider
//                     List<Bulletin> bulletins = bulletinProvider.bulletins;
//
//                     // If the list is empty, show a centered message
//                     if (bulletins.isEmpty) {
//                       return Center(
//                         child: Text(
//                           "No bulletins available",
//                           style: TextStyle(
//                             fontFamily: "UbuntuMedium",
//                             fontSize: 18,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       );
//                     }
//
//                     // If bulletins are available, show them in the UI
//                     return Column(
//                       children: bulletins.map((bulletin) {
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
//                                       color: Color(0xFFA7D8F9),
//                                       shape: BoxShape.circle, // Circular shape
//                                     ),
//                                     child: Center(
//                                       child: SvgPicture.asset(
//                                         AppConstants.newsBulletinMangementCardIcon,
//                                         height: 30,
//                                         width: 25,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     bulletin.title ?? "Unknown Title", // Display bulletin title
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
//                                       Navigator.push(context, FadePageRouteBuilder(widget: BulletinDetailView(bulletin: bulletin,)));
//                                     },
//                                     child: Container(
//                                       height: 40,
//                                       width: 85,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(16),
//                                         color: Color(0xFF8AC85A),
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
//
//
//
