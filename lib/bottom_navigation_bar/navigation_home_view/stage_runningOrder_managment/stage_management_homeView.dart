import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/performanceDetailaview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../provider/performanceCollection_provider.dart';
import 'add_performance_View.dart';
import 'allPerformances_view.dart';


class AddPerformanceHome extends StatelessWidget {
  const AddPerformanceHome({super.key});

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.49 + // Example: Height of welcome message Positioned child
        MediaQuery.of(context).size.height *
            0.09; // Example: Height of welcome message Positioned child

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
                fit: BoxFit.fill,
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
                    "Stage Running Order",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: SvgPicture.asset(AppConstants.greenBackIcon),
                    // Replace with your custom icon
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0, // Remove shadow
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
                    color: Color(0xFF8AC85A),
                    borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,

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
                              color: Colors.white),
                        ),
                        Text(
                          "Performance",
                          style: TextStyle(
                              height: 1.0,
                              fontFamily: "UbuntuBold",
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: SvgPicture.asset(AppConstants.forwardIcon),
                          onTap: (){
                            Navigator.push(context, FadePageRouteBuilder(widget: AddPerformanceView()));
                          },),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                      ],
                    ),
                    SvgPicture.asset(AppConstants.stageRunningOrderCardIcon),
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
                    "Performances",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "UbuntuMedium",
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.37),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: AllPerformancesView()));
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "UbuntuMedium",
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height * 0.48,
              left: MediaQuery.of(context).size.width * 0.066,
              right: MediaQuery.of(context).size.width * 0.066,
              child: FutureBuilder<void>(
                future: Provider.of<PerformanceProvider>(context, listen: false).fetchPerformances(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(), // Show loading indicator
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Failed to load performances: ${snapshot.error}",
                        style: TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else {
                    final performances = Provider.of<PerformanceProvider>(context).performances;

                    if (performances.isEmpty) {
                      return Center(
                        child: Text(
                          "You haven't added any performances yet!",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                          ),
                        ),
                      );
                    } else {
                      final maxPerformancesToShow = 4;
                      final performancesToShow = performances.take(maxPerformancesToShow).toList();

                      return Column(
                        children: performancesToShow.map((performance) {
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
                                        child: SvgPicture.asset(AppConstants.performancesIcon), // Use your icon
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      performance.performanceTitle??"", // Use performance title or any other field
                                      style: TextStyle(
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 8),
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
                    }
                  }
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
