import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/festival_managment/viewAllFestivals_View.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // Import provider
import '../../../constants/AppConstants.dart';
import '../../../provider/festivalCollection_provider.dart';
import 'addFestivalView.dart';
import 'festivalDetailView.dart';

class AddFestivalHome extends StatelessWidget {
  const AddFestivalHome({super.key});

  double calculateTotalHeight(BuildContext context) {
    double totalHeight = 0.0;

    totalHeight = totalHeight +
        MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height *
            0.5 + // Example: Height of welcome message Positioned child
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
                    "Festival Management",
                    style: TextStyle(
                      fontFamily: "Ubuntu",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: SvgPicture.asset(
                      AppConstants.greenBackIcon,
                    ),
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
                    color: Color(0xFF8AC85A),
                    borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                          "Add",
                          style: TextStyle(
                              height: 1.0,
                              fontFamily: "UbuntuBold",
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Text(
                          "Festivals",
                          style: TextStyle(
                              height: 1.0,
                              fontFamily: "UbuntuBold",
                              fontSize: 28,
                              color: Colors.white),
                        ),
                        Spacer(),
                        GestureDetector(
                          child: SvgPicture.asset(AppConstants.forwardIcon),
                          onTap: () {
                            Navigator.push(
                                context,
                                FadePageRouteBuilder(
                                    widget: AddFestivalView()));
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                      ],
                    ),
                    SvgPicture.asset(AppConstants.festivalMangementCardIcon),
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
                    "Festivals",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "UbuntuMedium",
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.49),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          FadePageRouteBuilder(widget: AllFestivalView()));
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
              child: Consumer<FestivalProvider>(
                builder: (context, festivalProvider, child) {
                  final festivals = festivalProvider.festivals;

                  if (festivals.isEmpty) {
                    return Center(
                      child: Text(
                        "You haven't added any festivals yet!",
                        style: TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else {
                    final maxFestivalsToShow = 4;
                    final festivalsToShow =
                        festivals.take(maxFestivalsToShow).toList();

                    return Column(
                      children: festivalsToShow.map((festival) {
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
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF8AC85A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                          AppConstants.totalFestivals),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  // Use Expanded to allow the text to take available space
                                  child: Text(
                                    festival.nameOrganizer ?? "",
                                    style: TextStyle(
                                      fontFamily: "UbuntuMedium",
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    // Ensures the text fits in a single line
                                    overflow: TextOverflow
                                        .ellipsis, // Adds "..." at the end if the text is too long
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Add a small space between the text and button
                                Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: GestureDetector(
                                    onTap: (){Navigator.push(
                                        context,
                                        FadePageRouteBuilder(
                                            widget: FestivalDetailView(
                                                festival: festival)));},
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
