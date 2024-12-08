import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transition.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import 'festivalDetailView.dart';

class AllFestivalView extends StatefulWidget {
  const AllFestivalView({Key? key}) : super(key: key);

  @override
  State<AllFestivalView> createState() => _AllFestivalViewState();
}

class _AllFestivalViewState extends State<AllFestivalView> {
  bool _isLoading = false;

  Future<void> _deleteFestival(BuildContext context, Festival festival) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Festival"),
          content: Text("Are you sure you want to delete this festival?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
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

      // Perform deletion
      await Provider.of<FestivalProvider>(context, listen: false)
          .deleteFestival(context, festival.id.toString());

      // Re-fetch festivals to update the list
      await Provider.of<FestivalProvider>(context, listen: false)
          .fetchFestivals(context);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          SingleChildScrollView(
            child: Column(
              children: [
                // AppBar
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: AppBar(
                    centerTitle: true,
                    title: Text(
                      "All Festivals",
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
                SizedBox(height: 10), // Space between AppBar and festivals
                Consumer<FestivalProvider>(
                  builder: (context, festivalProvider, child) {
                    List<Festival> festivals = festivalProvider.festivals;

                    if (festivals.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "No festivals available",
                            style: TextStyle(
                              fontFamily: "UbuntuMedium",
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: festivals.map((festival) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Stack(
                              children: [
                                // Main Content of the Card
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                  ),
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      // Festival Icon/Image
                                      Container(
                                        width: 60.0,
                                        height: 60.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF8AC85A),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            AppConstants.totalFestivals,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      // Festival Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              festival.nameOrganizer ?? "",
                                              style: TextStyle(
                                                fontFamily: "UbuntuMedium",
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "From: ${festival.startingDate ?? "N/A"}",
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
                                      Row(
                                        children: [
                                          // View Detail Button
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                FadePageRouteBuilder(
                                                  widget: FestivalDetailView(
                                                    festival: festival,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 35,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                                color: Color(0xFF8AC85A),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "View Detail",
                                                  style: TextStyle(
                                                    fontFamily: "UbuntuMedium",
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          // Delete Button
                                          GestureDetector(
                                            onTap: () async {
                                              await _deleteFestival(
                                                  context, festival);
                                            },
                                            child: Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.redAccent,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Badge Overlay
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Unofficial",
                                      style: TextStyle(
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 12,
                                        color: Colors.white,
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

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
