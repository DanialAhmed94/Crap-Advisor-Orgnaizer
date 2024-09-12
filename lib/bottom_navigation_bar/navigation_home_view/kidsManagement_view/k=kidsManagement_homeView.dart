import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/kidsManagement_view/activityDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../constants/AppConstants.dart';
import '../../../provider/activityCollection_provider.dart';
import 'addActivity_view.dart';
import 'allActivities_View.dart';


class AddKidsActivityHome extends StatelessWidget {
  const AddKidsActivityHome({super.key});

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.58 + // Example: Height of welcome message Positioned child
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
                    "Kids Activity",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: SvgPicture.asset(AppConstants.backIcon),
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
                    color: Color(0xFF3DA992),

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
                          "Add Kids",
                          style: TextStyle(
                              height: 1.0,
                              fontFamily: "UbuntuBold",
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Text(
                          "Activity",
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
                            Navigator.push(context, FadePageRouteBuilder(widget: AddActivityView()));
                          },),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                      ],
                    ),
                    SvgPicture.asset(AppConstants.tile6Top,height: 100,width: 100,),
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
                    "Activities",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "UbuntuMedium",
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.49),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: AllActivitiesView()));
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
                future: Provider.of<ActivityProvider>(context, listen: false).fetchActivities(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(), // Show loading indicator
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Failed to load activities: ${snapshot.error}",
                        style: TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else {
                    final activities = Provider.of<ActivityProvider>(context).activities;

                    if (activities.isEmpty) {
                      return Center(
                        child: Text(
                          "No activities available!",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                          ),
                        ),
                      );
                    } else {
                      final maxActivitiesToShow = 4; // Limit the number of activities to show
                      final activitiesToShow = activities.take(maxActivitiesToShow).toList();

                      return Column(
                        children: activitiesToShow.map((activity) {
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
                                        color: Color(0xFF3DA992).withOpacity(0.7),
                                        shape: BoxShape.circle, // Circular shape
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          AppConstants.tile6Top,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      activity.activityTitle ?? "No title", // Use activity title or any other field
                                      style: TextStyle(
                                        fontFamily: "UbuntuMedium",
                                        fontSize: 15,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 25),
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, FadePageRouteBuilder(widget: ActivityDetailView(activity: activity)));
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
            ),

          ],
        ),
      ),
    );
  }
}
