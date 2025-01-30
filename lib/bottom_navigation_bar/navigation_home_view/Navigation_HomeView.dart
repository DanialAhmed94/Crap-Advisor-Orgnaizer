import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/new_bullitin_managment/newBulletin_managmentView.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/stage_management_homeView.dart';
import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletManagement_View.dart';
import 'package:crap_advisor_orgnaizer/homw_view/notificationView.dart';
import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../annim/transition.dart';
import '../../constants/AppConstants.dart';
import '../../premium_view/premium_view.dart';
import '../../provider/festivalCollection_provider.dart';
import '../../provider/notificationProvider.dart';
import '../socialMedia/socialpstview.dart';
import 'eventMangement_view/eventManagement_homeView.dart';
import 'festival_managment/festival_managment_homeView.dart';
import 'kidsManagement_view/k=kidsManagement_homeView.dart';
import 'registeredUsers/registeredusers.dart';

class NavigationHomeview extends StatefulWidget {
  const NavigationHomeview({super.key});

  @override
  State<NavigationHomeview> createState() => _NavigationHomeviewState();
}

class _NavigationHomeviewState extends State<NavigationHomeview> {
  late Future<void> _fetchFestivalsFuture;
  String? _displayName;
  bool _isUsernameLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch festivals once and store in provider
    _fetchFestivalsFuture = Provider.of<FestivalProvider>(context, listen: false).fetchFestivals(context);

    // Fetch username once and store it locally
    getUserName().then((name) {
      setState(() {
        _displayName = name ?? 'No username found';
        _isUsernameLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the tile list once
    final tiles = _buildTiles(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
           Positioned.fill(
            child: Image(
              image: AssetImage(AppConstants.planBackground),
              fit: BoxFit.fill,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                const Text(
                  "Welcome",
                  style: TextStyle(
                      fontFamily: "UbuntuRegular",
                      fontSize: 14,
                      color: Color(0xFF706F6F)),
                ),
                SizedBox(height: 8),
                _buildUserRow(context),
                // SizedBox(height: 20),
                // _buildPremiumCard(context),
                SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, FadePageRouteBuilder(widget: SocialMediaHomeView()));
                  },
                  child: Image(
                    image: AssetImage(AppConstants.crapChat),
                    fit: BoxFit.cover,
                  ),
                ),

                _buildGrid(tiles),
                SizedBox(height: 20),
                _buildTotals(context),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(BuildContext context) {
    if (_isUsernameLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Text(
          _displayName ?? 'No username found',
          style: const TextStyle(
            fontFamily: "UbuntuMedium",
            fontSize: 17,
            color: Color(0xFF212121),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              FadePageRouteBuilder(widget: NotificationView()),
            );
          },
          child: Stack(
            alignment: Alignment.topRight, // Position badge on top-right
            children: [
              SvgPicture.asset(
                AppConstants.bellIcon,
                color: const Color(0xFF788595),
              ),
              Consumer<NotificationsCollectionProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: provider.totalNotificationCount > 0
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.all(6), // Slightly larger for empty badge
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: provider.totalNotificationCount > 0
                        ? Text(
                      provider.totalNotificationCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : const SizedBox.shrink(), // Empty badge when count is 0
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
  Widget _buildPremiumCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Navigator.push(context, FadePageRouteBuilder(widget: PremiumView()));
      },
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF5C9D37),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "  Get Premium",
                      style: TextStyle(
                          fontFamily: "MontserratBold",
                          fontSize: 24,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
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
                padding: const EdgeInsets.only(right: 8, left: 16),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: SvgPicture.asset(AppConstants.crownProIcon),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // code for staggered grid view
  // Widget _buildGrid(List<Widget> tiles) {
  //   return GridView.custom(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: SliverWovenGridDelegate.count(
  //       crossAxisCount: 2,
  //       mainAxisSpacing: 0,
  //       crossAxisSpacing: 2,
  //       pattern: const [
  //         WovenGridTile(1),
  //         WovenGridTile(
  //           2 / 1.5,
  //           crossAxisRatio: 0.99,
  //           alignment: AlignmentDirectional.centerEnd,
  //         ),
  //       ],
  //     ),
  //     childrenDelegate: SliverChildBuilderDelegate(
  //           (context, index) {
  //         return ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: tiles[index],
  //         );
  //       },
  //       childCount: tiles.length,
  //     ),
  //   );
  // }
  Widget _buildGrid(List<Widget> tiles) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        // Setting this to 1 makes each cell a square.
        childAspectRatio: 1.1,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: tiles[index],
        );
      },
    );
  }

  Widget _buildTotals(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchFestivalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loader until the festival data is fetched
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error if something went wrong
          return Text("Error: ${snapshot.error}");
        } else {
          // Once the Future completes, use a Consumer to rebuild when provider data changes
          return Consumer<FestivalProvider>(
            builder: (context, festivalProvider, child) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: AddFestivalHome()));
                    },
                    child: _buildTotalCard(
                      icon: AppConstants.totalFestivals,
                      title: "Total Festivals",
                      count: festivalProvider.totalFestivals.toString(),
                    ),
                  ),
                  _buildTotalCard(
                    icon: AppConstants.totalAttendees,
                    title: "Total Attendees",
                    count: festivalProvider.totalAttendees.toString(),
                    countWidth: 70,
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildTotalCard({
    required String icon,
    required String title,
    required String count,
    double countWidth = 50,
  }) {
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
                decoration: const BoxDecoration(
                  color: Color(0xFFD3FFD8),
                  shape: BoxShape.circle,
                ),
                child: Center(child: SvgPicture.asset(icon)),
              ),
            ),
            Text(
              " $title",
              style: const TextStyle(fontFamily: "UbuntuMedium", fontSize: 15),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                height: 50,
                width: countWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF8AC85A),
                ),
                child: Center(
                  child: Text(
                    count,
                    style: const TextStyle(
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
    );
  }

  List<Widget> _buildTiles(BuildContext context) {
    return [
      // Tile 1: Add Festival
      _buildTile(
        background: AppConstants.tile1Background,
        icon: AppConstants.tile1Top,
        title1: "Festival",
        title2: "Management",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: AddFestivalHome()));
        },
      ),

      // Tile 2: Stage Running Order (with proIcon)
      _buildTile(
        background: AppConstants.tile2Background,
        icon: AppConstants.tile2Top,
        title1: "Stage Running",
        title2: "Order",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: AddPerformanceHome()));
        },
        proIcon: true,
      ),

      // Tile 3: Event Capacity Management
      _buildTile(
        background: AppConstants.tile3Background,
        icon: AppConstants.tile3Top,
        title1: "Event Capacity",
        title2: "Management",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: AddEventManagementView()));
        },
      ),

      // Tile 4: Toilet Management
      _buildTile(
        background: AppConstants.tile4Background,
        icon: AppConstants.tile4Top,
        title1: "Toilet",
        title2: "Management",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: AddToiletHome()));
        },
      ),

      // Tile 5: News Bulletin Management (with proIcon)
      _buildTile(
        background: AppConstants.tile5Background,
        icon: AppConstants.tile5Top,
        title1: "News Bulletin",
        title2: "Management",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: AddNewsBullitinHome()));
        },
        proIcon: true,
      ),

      // Tile 6: Kids Activity
      _buildTile(
        background: AppConstants.tile6Background,
        icon: AppConstants.tile6Top,
        title1: "Kids",
        title2: "Activity",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: AddKidsActivityHome()));
        },
      ),

      // Tile 7: Registered Users
      _buildTile(
        background: AppConstants.tile2Background,
        // Reusing tile6Background for consistency as in original code
        icon: null, // Using an Image asset here instead of SVG for tile 7 top
        imageIcon: AppConstants.tile7Top,
        title1: "Registered",
        title2: "Users",
        onTap: () {
          Navigator.push(context, FadePageRouteBuilder(widget: RegisteredUsersView()));
        },
      ),
    ];
  }

  Widget _buildTile({
    required String background,
    String? icon,
    String? imageIcon, // for tile 7 which uses an image instead of svg
    required String title1,
    required String title2,
    required VoidCallback onTap,
    bool proIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            SvgPicture.asset(
              background,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            if (proIcon)
              Positioned(
                top: 4,
                left: 4,
                child: SvgPicture.asset(
                  AppConstants.proIcon,
                  width: 18,
                  height: 18,
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    SvgPicture.asset(icon),
                  if (imageIcon != null)
                    Image.asset(imageIcon, height: 60, width: 60),
                  const SizedBox(height: 8),
                  Text(
                    title1,
                    style: const TextStyle(
                      fontFamily: "UbuntuBold",
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    title2,
                    style: const TextStyle(
                      fontFamily: "UbuntuBold",
                      fontSize: 14,
                      color: Colors.white,
                    ),
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

// import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
// import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/new_bullitin_managment/newBulletin_managmentView.dart';
// import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/stage_management_homeView.dart';
// import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/toilet_managment/toiletManagement_View.dart';
// import 'package:crap_advisor_orgnaizer/homw_view/notificationView.dart';
// import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//
// import '../../annim/transition.dart';
// import '../../constants/AppConstants.dart';
// import '../../premium_view/premium_view.dart';
// import '../../provider/festivalCollection_provider.dart';
// import 'eventMangement_view/eventManagement_homeView.dart';
// import 'festival_managment/festival_managment_homeView.dart';
// import 'kidsManagement_view/k=kidsManagement_homeView.dart';
// import 'registeredUsers/registeredusers.dart';
//
// class NavigationHomeview extends StatefulWidget {
//   const NavigationHomeview({super.key});
//
//   @override
//   State<NavigationHomeview> createState() => _NavigationHomeviewState();
// }
//
// class _NavigationHomeviewState extends State<NavigationHomeview> {
//   late Future<void> _fetchFestivalsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the Future in initState
//     _fetchFestivalsFuture =
//         Provider.of<FestivalProvider>(context, listen: false)
//             .fetchFestivals(context);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> tiles = [
//       // Tile 1: Add Festival
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: AddFestivalHome()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile1Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(AppConstants.tile1Top),
//                     SizedBox(height: 8),
//                     Text(
//                       "Festival",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Management",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // Tile 2: Stage Running Order (with proIcon)
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: AddPerformanceHome()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile2Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Positioned(
//                 top: 4,
//                 left: 4,
//                 child: SvgPicture.asset(
//                   AppConstants.proIcon,
//                   width: 18,
//                   height: 18,
//                 ),
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(AppConstants.tile2Top),
//                     SizedBox(height: 8),
//                     Text(
//                       "Stage Running",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Order",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // Tile 3: Event Capacity Management
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: AddEventManagementView()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile3Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(AppConstants.tile3Top),
//                     SizedBox(height: 8),
//                     Text(
//                       "Event Capacity",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Management",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // Tile 4: Toilet Management
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: AddToiletHome()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile4Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(AppConstants.tile4Top),
//                     SizedBox(height: 8),
//                     Text(
//                       "Toilet",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Management",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // Tile 5: News Bulletin Management (with proIcon)
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: AddNewsBullitinHome()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile5Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Positioned(
//                 top: 4,
//                 left: 4,
//                 child: SvgPicture.asset(
//                   AppConstants.proIcon,
//                   width: 18,
//                   height: 18,
//                 ),
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(AppConstants.tile5Top),
//                     SizedBox(height: 8),
//                     Text(
//                       "News Bulletin",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Management",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // Tile 6: Kids Activity
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: AddKidsActivityHome()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile6Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SvgPicture.asset(AppConstants.tile6Top),
//                     SizedBox(height: 8),
//                     Text(
//                       "Kids",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Activity",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       // Tile 7: Registered Users
//       GestureDetector(
//         onTap: () {
//           Navigator.push(context, FadePageRouteBuilder(widget: RegisteredUsersView()));
//         },
//         child: AspectRatio(
//           aspectRatio: 1,
//           child: Stack(
//             children: [
//               SvgPicture.asset(
//                 AppConstants.tile6Background,
//                 width: double.infinity,
//                 height: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset(AppConstants.tile7Top, height: 60,width: 60,),
//                     SizedBox(height: 8),
//                     Text(
//                       "Registered",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       "Users",
//                       style: TextStyle(
//                         fontFamily: "UbuntuBold",
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ];
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Image.asset(
//               AppConstants.planBackground,
//               fit: BoxFit.fill,
//             ),
//           ),
//           // Scrollable content
//           SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.07),
//                 Text(
//                   "Welcome",
//                   style: TextStyle(
//                       fontFamily: "UbuntuRegular",
//                       fontSize: 14,
//                       color: Color(0xFF706F6F)),
//                 ),
//                 FutureBuilder<String?>(
//                   future: getUserName(),
//                   builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     } else if (snapshot.hasData) {
//                       String displayName = snapshot.data ?? 'No username found';
//                       return Row(
//                         children: [
//                           Text(
//                             displayName,
//                             style: TextStyle(
//                               fontFamily: "UbuntuMedium",
//                               fontSize: 17,
//                               color: Color(0xFF212121),
//                             ),
//                           ),
//                           Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   FadePageRouteBuilder(
//                                       widget: NotificationView()));
//                             },
//                             child: SvgPicture.asset(
//                               AppConstants.bellIcon,
//                               color: Color(0xFF788595),
//                             ),
//                           ),
//                           SizedBox(width: 4),
//                         ],
//                       );
//                     } else {
//                       return Center(child: Text('No username found'));
//                     }
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                         context, FadePageRouteBuilder(widget: PremiumView()));
//                   },
//                   child: Card(
//                     elevation: 2,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Color(0xFF5C9D37),
//                       ),
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height * 0.15,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(height: 10),
//                                 Text(
//                                   "  Get Premium",
//                                   style: TextStyle(
//                                       fontFamily: "MontserratBold",
//                                       fontSize: 24,
//                                       color: Colors.white),
//                                 ),
//                                 SizedBox(height: 10),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 8),
//                                   child: Text(
//                                     "Upgrade to Premium to enjoy all features",
//                                     style: TextStyle(
//                                       fontFamily: "MontserratMedium",
//                                       fontSize: 15,
//                                       color: Color(0xFFAEB1C2),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8, left: 16),
//                             child: Container(
//                               height: 60,
//                               width: 60,
//                               child: SvgPicture.asset(AppConstants.crownProIcon),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // The Woven Grid
//                 GridView.custom(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: SliverWovenGridDelegate.count(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 0, // Reduced vertical spacing
//                     crossAxisSpacing: 2,
//                     pattern: [
//                       WovenGridTile(1),
//                       WovenGridTile(
//                         2 / 1.5,
//                         crossAxisRatio: 0.99,
//                         alignment: AlignmentDirectional.centerEnd,
//                       ),
//                     ],
//                   ),
//                   childrenDelegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: tiles[index],
//                       );
//                     },
//                     childCount: tiles.length,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // FutureBuilder for totals
//                 FutureBuilder(
//                   future: _fetchFestivalsFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Text("Error: ${snapshot.error}");
//                     } else {
//                       return Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   FadePageRouteBuilder(
//                                       widget: AddFestivalHome()));
//                             },
//                             child: Card(
//                               elevation: 2,
//                               color: Colors.white,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                 ),
//                                 width: MediaQuery.of(context).size.width * 0.93,
//                                 height:
//                                 MediaQuery.of(context).size.height * 0.1,
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding:
//                                       const EdgeInsets.only(left: 16, right: 8),
//                                       child: Container(
//                                         width: 50.0,
//                                         height: 50.0,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xFFD3FFD8),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Center(
//                                           child: SvgPicture.asset(
//                                               AppConstants.totalFestivals),
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       " Total Festivals",
//                                       style: TextStyle(
//                                           fontFamily: "UbuntuMedium",
//                                           fontSize: 15),
//                                     ),
//                                     Spacer(),
//                                     Padding(
//                                       padding: const EdgeInsets.only(right: 25),
//                                       child: Container(
//                                         height: 50,
//                                         width: 50,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(16),
//                                           color: const Color(0xFF8AC85A),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             Provider.of<FestivalProvider>(context)
//                                                 .totalFestivals
//                                                 .toString(),
//                                             style: TextStyle(
//                                                 fontFamily: "UbuntuMedium",
//                                                 fontSize: 16,
//                                                 color: Colors.white),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   FadePageRouteBuilder(
//                                       widget: AddEventManagementView()));
//                             },
//                             child: Card(
//                               elevation: 2,
//                               color: Colors.white,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                 ),
//                                 width: MediaQuery.of(context).size.width * 0.93,
//                                 height:
//                                 MediaQuery.of(context).size.height * 0.1,
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding:
//                                       const EdgeInsets.only(left: 16, right: 8),
//                                       child: Container(
//                                         width: 50.0,
//                                         height: 50.0,
//                                         decoration: BoxDecoration(
//                                           color: Color(0xFFD3FFD8),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Center(
//                                           child: SvgPicture.asset(
//                                               AppConstants.totalAttendees),
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       " Total Attendees",
//                                       style: TextStyle(
//                                           fontFamily: "UbuntuMedium",
//                                           fontSize: 15),
//                                       maxLines: 2,
//                                     ),
//                                     Spacer(),
//                                     Padding(
//                                       padding: const EdgeInsets.only(right: 16),
//                                       child: Container(
//                                         height: 50,
//                                         width: 70,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(16),
//                                           color: const Color(0xFF8AC85A),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             Provider.of<FestivalProvider>(context)
//                                                 .totalAttendees
//                                                 .toString(),
//                                             style: TextStyle(
//                                                 fontFamily: "UbuntuMedium",
//                                                 fontSize: 16,
//                                                 color: Colors.white),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     }
//                   },
//                 ),
//                 SizedBox(height: 20),
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
