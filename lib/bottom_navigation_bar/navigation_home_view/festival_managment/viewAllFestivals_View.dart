import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transition.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import 'festivalDetailView.dart';

class AllFestivalView extends StatelessWidget {
  const AllFestivalView({super.key});

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
           // physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
               // SizedBox(height: MediaQuery.of(context).size.height * 0.07),
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
                    // Access the festivals list from the provider
                    List<Festival> festivals = festivalProvider.festivals;

                    // If the list is empty, show a centered message
                    if (festivals.isEmpty) {
                      return Center(
                        child: Text(
                          "No festivals available",
                          style: TextStyle(
                            fontFamily: "UbuntuMedium",
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // If the list is not empty, show the festival cards
                    return Column(
                      children: festivals.map((festival) {
                        return Stack(
                          children: [
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
                                      padding: const EdgeInsets.only(left: 16, right: 8),
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF8AC85A),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(AppConstants.totalFestivals),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        festival.nameOrganizer ?? "",
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
                            ),
                            Positioned(
                              right: 10,
                              top:-5,

                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'Unofficial',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: "UbuntuMedium",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        ;
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
// Card(
// elevation: 2,
// color: Colors.white,
// child: Container(
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(10),
// color: Colors.white,
// ),
// width: MediaQuery.of(context).size.width * 0.93,
// height: MediaQuery.of(context).size.height * 0.1,
// child: Row(
// children: [
// Padding(
// padding: const EdgeInsets.only(left: 16, right: 8),
// child: Container(
// width: 50.0,
// height: 50.0,
// decoration: BoxDecoration(
// color: Color(0xFF8AC85A),
// shape: BoxShape.circle,
// ),
// child: Center(
// child: SvgPicture.asset(AppConstants.totalFestivals),
// ),
// ),
// ),
// Expanded(
// child: Text(
// festival.nameOrganizer ?? "",
// style: TextStyle(
// fontFamily: "UbuntuMedium",
// fontSize: 15,
// ),
// maxLines: 1,
// overflow: TextOverflow.ellipsis,
// ),
// ),
// Padding(
// padding: const EdgeInsets.only(right: 25),
// child: Container(
// height: 40,
// width: 85,
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(16),
// color:Color(0xFF8AC85A),
// ),
// child: Center(
// child: Text(
// "View Detail",
// textAlign: TextAlign.center,
// style: TextStyle(
// fontFamily: "UbuntuMedium",
// fontSize: 12,
// color: Colors.white,
// ),
// ),
// ),
// ),
// ),
// ],
// ),
// ),
// )