import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/AppConstants.dart';
import '../../../data_model/activityCollection_model.dart';
import '../../../provider/activityCollection_provider.dart';
import 'activityDetailView.dart';

class AllActivitiesView extends StatelessWidget {
  const AllActivitiesView({super.key});

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
                      "All Activities",
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
                SizedBox(height: 10), // Space between AppBar and activities

                // Consumer that listens to ActivityProvider
                Consumer<ActivityProvider>(
                  builder: (context, activityProvider, child) {
                    // Fetch activities from the provider
                    List<Activity> activities = activityProvider.activities;

                    // If the list is empty, show a centered message
                    if (activities.isEmpty) {
                      return Center(
                        child: Text(
                          "No activities available",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // If activities are available, show them in the UI
                    return Column(
                      children: activities.map((activity) {
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
                                    activity.activityTitle ?? "No title", // Display activity title
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
