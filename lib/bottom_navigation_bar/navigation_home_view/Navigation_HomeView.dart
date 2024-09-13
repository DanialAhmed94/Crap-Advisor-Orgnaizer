import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/new_bullitin_managment/newBulletin_managmentView.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/stage_management_homeView.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletManagement_View.dart';
import 'package:crap_advisor_orgnaizer/homw_view/notificationView.dart';
import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../annim/transition.dart';
import '../../constants/AppConstants.dart';
import '../../provider/festivalCollection_provider.dart';
import 'eventMangement_view/eventManagement_homeView.dart';
import 'festival_managment/festival_managment_homeView.dart';
import 'kidsManagement_view/k=kidsManagement_homeView.dart';

class NavigationHomeview extends StatefulWidget {
  const NavigationHomeview({super.key});

  @override
  State<NavigationHomeview> createState() => _NavigationHomeviewState();
}

class _NavigationHomeviewState extends State<NavigationHomeview> {
  late Future<void> _fetchFestivalsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the Future in initState
    _fetchFestivalsFuture =
        Provider.of<FestivalProvider>(context, listen: false)
            .fetchFestivals(context);
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.58 + // Example: Height of welcome message Positioned child
        MediaQuery.of(context).size.height *
            0.16; // Example: Height of welcome message Positioned child

    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(height: calculateTotalHeight(context)),
            Positioned.fill(
              child: Image.asset(
                AppConstants.planBackground,
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.07,
              left: 16, // Added left padding for alignment
              right: 16, // Added right padding for alignment
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Aligns children to the start of the column
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                        fontFamily: "UbuntuRegular",
                        fontSize: 14,
                        color: Color(0xFF706F6F)),
                  ),
                  //SizedBox(height: 8), // Adds spacing between text and row
                  FutureBuilder<String?>(
                    future: getUserName(),
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        String displayName =
                            snapshot.data ?? 'No username found';
                        return Row(
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 17,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Spacer(),
                            // Container(
                            //   height: 50,
                            //   width: 90,
                            //   child: SvgPicture.asset(AppConstants.proIcon),
                            // ),
                            // SizedBox(width: 13),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    FadePageRouteBuilder(
                                        widget: NotificationView()));
                              },
                              child: SvgPicture.asset(
                                AppConstants.bellIcon,
                                color: Color(0xFF788595),
                              ),
                            ),

                            SizedBox(width: 4),
                          ],
                        );
                      } else {
                        // Handle the case where snapshot has no data
                        return Center(child: Text('No username found'));
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          FadePageRouteBuilder(widget: BottomPremiumView()));
                    },
                    child: Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    "  Get Premium",
                                    style: TextStyle(
                                        fontFamily: "MontserratBold",
                                        fontSize: 24,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      "Upgrade to Premium to enjoy all features",
                                      style: TextStyle(
                                        fontFamily: "MontserratMedium",
                                        fontSize: 15,
                                        color: Color(0xFFAEB1C2),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8, left: 16),
                              child: Container(
                                height: 60,
                                width: 60,
                                child:
                                    SvgPicture.asset(AppConstants.crownProIcon),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.34, // Adjusted position to avoid overlapping
              left: 16,
              right: 16,
              child: GestureDetector(
                child: GridTile(
                  child: Stack(
                    // fit: StackFit.expand,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.black,
                          ),
                          child: SvgPicture.asset(
                            AppConstants.tile1Background,
                            fit: BoxFit.fill,
                          )),
                      Positioned(
                        top: 40,
                        left: 60,
                        // Change this value to position the icon as desired
                        // Change this value to position the icon as desired
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SvgPicture.asset(AppConstants.tile1Top),
                            ),
                            Text(
                              "Add",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            Text(
                              "Festival",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        ), // Replace with your custom icon
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context, FadePageRouteBuilder(widget: AddFestivalHome()));
                },
              ),
            ), // Gridtile 1

            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.34, // Adjusted position to avoid overlapping
              left: MediaQuery.of(context).size.width * 0.51,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      FadePageRouteBuilder(widget: AddPerformanceHome()));
                },
                child: GridTile(
                  child: Container(
                    // height: 150,
                    //  color: Colors.green,
                    child: Stack(
                      // fit: StackFit.expand,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.16,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black),
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: SvgPicture.asset(
                              AppConstants.tile2Background,
                              fit: BoxFit.cover,
                            )),
                        Positioned(
                          top: 35,
                          left: 40,
                          // Change this value to position the icon as desired
                          // Change this value to position the icon as desired
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SvgPicture.asset(AppConstants.tile2Top),
                              ),
                              Text(
                                "Stage Running",
                                style: TextStyle(
                                    height: 1.0,
                                    fontFamily: "UbuntuBold",
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                              Text(
                                "Order",
                                style: TextStyle(
                                    height: 1.0,
                                    fontFamily: "UbuntuBold",
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ],
                          ), // Replace with your custom icon
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ), // Gridtile 2
            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.34, // Adjusted position to avoid overlapping
              left: MediaQuery.of(context).size.width *
                  0.51, // Position the new SVG at the top left
              child: SvgPicture.asset(
                AppConstants.proIcon, // Replace with your new SVG asset
                width: 24, // Adjust the size as needed
                height: 24,
              ),
            ), // proIcon

            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.55, // Adjusted position to avoid overlapping
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      FadePageRouteBuilder(widget: AddEventManagementView()));
                },
                child: GridTile(
                  child: Stack(
                    // fit: StackFit.expand,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.16,
                          width: MediaQuery.of(context).size.width * 0.46,
                          child: SvgPicture.asset(
                            AppConstants.tile3Background,
                          )),
                      Positioned(
                        top: 33,
                        left: 45,
                        // Change this value to position the icon as desired
                        // Change this value to position the icon as desired
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SvgPicture.asset(AppConstants.tile3Top),
                            ),
                            Text(
                              "Event ",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            Text(
                              "Management",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        ), // Replace with your custom icon
                      ),
                    ],
                  ),
                ),
              ),
            ), // Gridtile 3

            Positioned(
              top: MediaQuery.of(context).size.height * 0.51,
              left: MediaQuery.of(context).size.width * 0.51,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, FadePageRouteBuilder(widget: AddToiletHome())),
                child: GridTile(
                  child: Stack(
                    // fit: StackFit.expand,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset(
                            AppConstants.tile4Background,
                            fit: BoxFit.fill,
                          )),
                      Positioned(
                        top: 35,
                        left: 45,
                        // Change this value to position the icon as desired
                        // Change this value to position the icon as desired
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SvgPicture.asset(AppConstants.tile4Top),
                            ),
                            Text(
                              "Toilet",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            Text(
                              "Management",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        ), // Replace with your custom icon
                      ),
                    ],
                  ),
                ),
              ),
            ), // Gridtile 4

            Positioned(
              top: MediaQuery.of(context).size.height * 0.72,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      FadePageRouteBuilder(widget: AddNewsBullitinHome()));
                },
                child: GridTile(
                  child: Stack(
                    // fit: StackFit.expand,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset(
                            AppConstants.tile5Background,
                            fit: BoxFit.fill,
                          )),
                      Positioned(
                        top: 40,
                        left: 44,
                        // Change this value to position the icon as desired
                        // Change this value to position the icon as desired
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SvgPicture.asset(AppConstants.tile5Top),
                            ),
                            Text(
                              "News Bulletin",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            Text(
                              "Management",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        ), // Replace with your custom icon
                      ),
                    ],
                  ),
                ),
              ),
            ), // Gridtile 5
            Positioned(
              top: MediaQuery.of(context).size.height * 0.72,
              left: 16,
              // Position the new SVG at the top left
              child: SvgPicture.asset(
                AppConstants.proIcon, // Replace with your new SVG asset
                width: 24, // Adjust the size as needed
                height: 24,
              ),
            ), // proIcon

            Positioned(
              top: MediaQuery.of(context).size.height * 0.72,
              left: MediaQuery.of(context).size.width * 0.51,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      FadePageRouteBuilder(widget: AddKidsActivityHome()));
                },
                child: GridTile(
                  child: Stack(
                    // fit: StackFit.expand,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.16,
                          width: MediaQuery.of(context).size.width * 0.46,
                          child: SvgPicture.asset(
                            AppConstants.tile6Background,
                          )),
                      Positioned(
                        top: 22,
                        left: 60,
                        // Change this value to position the icon as desired
                        // Change this value to position the icon as desired
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SvgPicture.asset(AppConstants.tile6Top),
                            ),
                            Text(
                              "Kids",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            Text(
                              "Activity",
                              style: TextStyle(
                                  height: 1.0,
                                  fontFamily: "UbuntuBold",
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                          ],
                        ), // Replace with your custom icon
                      ),
                    ],
                  ),
                ),
              ),
            ), // Gridtile 6

            Positioned(
              top: MediaQuery.of(context).size.height * 0.93,
              left: 16,
              right: 16,
              child: FutureBuilder(
                future: _fetchFestivalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Column(
                      children: [
                        // Display Total Festivals
                        Card(
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
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD3FCFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                          AppConstants.totalFestivals),
                                    ),
                                  ),
                                ),
                                Text(
                                  " Total Festivals",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color(0xFF8AC85A),
                                    ),
                                    child: Center(
                                      child: Text(
                                        Provider.of<FestivalProvider>(context)
                                            .totalFestivals
                                            .toString(),
                                        style: TextStyle(
                                            fontFamily: "UbuntuMedium",
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Display Total Attendees
                        Card(
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
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD3FCFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                          AppConstants.totalAttendees),
                                    ),
                                  ),
                                ),
                                Text(
                                  " Total Attendees",
                                  style: TextStyle(
                                      fontFamily: "UbuntuMedium", fontSize: 15),
                                  maxLines: 2,
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Container(
                                    height: 50,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color(0xFF8AC85A),
                                    ),
                                    child: Center(
                                      child: Text(
                                        Provider.of<FestivalProvider>(context)
                                            .totalAttendees
                                            .toString(),
                                        style: TextStyle(
                                            fontFamily: "UbuntuMedium",
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
