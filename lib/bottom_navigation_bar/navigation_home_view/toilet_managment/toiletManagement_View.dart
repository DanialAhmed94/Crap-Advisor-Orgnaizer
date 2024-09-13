import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../constants/AppConstants.dart';
import '../../../provider/toiletCollection_provider.dart';
import '../../../provider/toiletTypeCollection_provider.dart';
import 'addToiletView.dart';
import 'allToilets_view.dart';

class AddToiletHome extends StatefulWidget {
  const AddToiletHome({super.key});

  @override
  _AddToiletHomeState createState() => _AddToiletHomeState();
}

class _AddToiletHomeState extends State<AddToiletHome> {
  late Future<void> _toiletTypesFuture;
  late Future<void> _toiletsFuture;

  @override
  void initState() {
    super.initState();
    _toiletTypesFuture = Provider.of<ToiletTypeProvider>(context, listen: false).fetchToiletTypes(context);
    _toiletsFuture = Provider.of<ToiletProvider>(context, listen: false).fetchToilets(context);
  }

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height * 0.58 +
        MediaQuery.of(context).size.height * 0.09;

    return totalHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Stack(
          children: [
            Container(height: calculateTotalHeight(context)),
            Positioned.fill(
              child: Image.asset(
                AppConstants.planBackground,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: AppBar(
                  centerTitle: true,
                  title: Text(
                    "Toilet Management",
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
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: MediaQuery.of(context).size.width * 0.066,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.87,
                decoration: BoxDecoration(
                  color: Color(0xFF8000FF),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Text(
                          "Add",
                          style: TextStyle(
                            height: 1.0,
                            fontFamily: "UbuntuBold",
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Toilet",
                          style: TextStyle(
                            height: 1.0,
                            fontFamily: "UbuntuBold",
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: SvgPicture.asset(AppConstants.forwardIcon),
                          onTap: () {
                            Navigator.push(context, FadePageRouteBuilder(widget: AddToiletView()));
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                      ],
                    ),
                    SvgPicture.asset(AppConstants.toiletMangementCardIcon),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.42,
              left: MediaQuery.of(context).size.width * 0.066,
              child: Row(
                children: [
                  Text(
                    "Toilets",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "UbuntuMedium",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.49),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: AllToiletsView()));
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "UbuntuMedium",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.48,
              left: MediaQuery.of(context).size.width * 0.066,
              right: MediaQuery.of(context).size.width * 0.066,
              child: Column(
                children: [
                  // FutureBuilder for Toilet Types
                  FutureBuilder<void>(
                    future: _toiletTypesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Failed to load toilet types: ${snapshot.error}",
                            style: TextStyle(
                              fontFamily: "UbuntuMedium",
                              fontSize: 18,
                            ),
                          ),
                        );
                      } else {
                        // Successfully loaded toilet types
                        return SizedBox.shrink(); // Placeholder for toilet types if needed
                      }
                    },
                  ),

                  // FutureBuilder for Toilets
                  FutureBuilder<void>(
                    future: _toiletsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Failed to load toilets: ${snapshot.error}",
                            style: TextStyle(
                              fontFamily: "UbuntuMedium",
                              fontSize: 18,
                            ),
                          ),
                        );
                      } else {
                        // Successfully loaded toilets
                        final toilets = Provider.of<ToiletProvider>(context).toilets;

                        if (toilets.isEmpty) {
                          return Center(
                            child: Text(
                              "You haven't added any toilets yet!",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 18,
                              ),
                            ),
                          );
                        } else {
                          // Display the toilets in cards
                          final maxToiletsToShow = 4;
                          final toiletsToShow = toilets.take(maxToiletsToShow).toList();

                          return Column(
                            children: toiletsToShow.map((toilet) {
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
                                            color: Color(0xFFD5A5FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(AppConstants.comode1Icon),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        toilet.what3Words ?? "Unknown Toilet",
                                        style: TextStyle(
                                          fontFamily: "UbuntuMedium",
                                          fontSize: 15,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 2,
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 25),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              FadePageRouteBuilder(
                                                widget: ToiletDetailView(toiletData: toilet),
                                              ),
                                            );
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
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
