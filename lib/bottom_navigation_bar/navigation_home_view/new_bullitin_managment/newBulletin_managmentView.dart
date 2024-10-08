import 'package:crap_advisor_orgnaizer/annim/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../constants/AppConstants.dart';
import '../../../provider/bulletinCollection_provider.dart';
import 'addNewsBulletin_View.dart';
import 'allBulletins.dart';
import 'bulletinDetailView.dart';

class AddNewsBullitinHome extends StatefulWidget {
  const AddNewsBullitinHome({super.key});

  @override
  _AddNewsBullitinHomeState createState() => _AddNewsBullitinHomeState();
}

class _AddNewsBullitinHomeState extends State<AddNewsBullitinHome> {
  late Future<void> _bulletinsFuture;

  @override
  void initState() {
    super.initState();
    _bulletinsFuture = Provider.of<BulletinProvider>(context, listen: false).fetchBulletins(context);
  }

  double calculateTotalHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.07 +
        MediaQuery.of(context).size.height * 0.37 +
        MediaQuery.of(context).size.height * 0.58 +
        MediaQuery.of(context).size.height * 0.09; // Adjust as necessary
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
                    "Bulletin Management",
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
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: MediaQuery.of(context).size.width * 0.066,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.87,
                decoration: BoxDecoration(
                  color: Color(0xFF8AC85A),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                          "Add News",
                          style: TextStyle(
                            height: 1.0,
                            fontFamily: "UbuntuBold",
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Bulletin",
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
                            Navigator.push(context, FadePageRouteBuilder(widget: AddNewsBulletinView()));
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                      ],
                    ),
                    SvgPicture.asset(AppConstants.newsBulletinMangementCardIcon),
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
                    "Bulletins",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "UbuntuMedium",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.49),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: AllBulletinsView()));
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
              child: FutureBuilder<void>(
                future: _bulletinsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Failed to load bulletins: ${snapshot.error}",
                        style: TextStyle(
                          fontFamily: "UbuntuMedium",
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else {
                    final bulletins = Provider.of<BulletinProvider>(context).bulletins;

                    if (bulletins.isEmpty) {
                      return Center(
                        child: Text(
                          "No bulletins available!",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                          ),
                        ),
                      );
                    } else {
                      final maxBulletinsToShow = 4; // Limit the number of bulletins to show
                      final bulletinsToShow = bulletins.take(maxBulletinsToShow).toList();

                      return Column(
                        children: bulletinsToShow.map((bulletin) {
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
                                        color: Color(0xFF8AC85A),
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
                                      bulletin.title ?? "No title", // Use bulletin title or any other field
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
