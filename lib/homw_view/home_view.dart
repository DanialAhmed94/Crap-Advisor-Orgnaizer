import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/Navigation_HomeView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../bottom_navigation_bar/PremiumView/bottomPremiumView.dart';
import '../bottom_navigation_bar/profileView/profileHomeView.dart';
import '../bottom_navigation_bar/socialMedia/socialpstview.dart';
import '../constants/AppConstants.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [


          IndexedStack(
              index: _index,
              children: [
                NavigationHomeview(),
                SocialMediaHomeView(isFromCard: false,),
               // BotomPremiumView(),
                ProfileHomeview(),
                // Add other views here for different tabs
              ],
            ),

        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.white, // Set selected item text color
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'InterSemiBold',
          fontSize: 12,
          color: Colors.white,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'InterSemiBold',
          fontSize: 12,
          color: Colors.white,
        ),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppConstants.homeUnselected),
            activeIcon: SvgPicture.asset(AppConstants.homeSelected,color: const Color(0xFF8AC85A),),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppConstants.feedUnselected),
            activeIcon: SvgPicture.asset(AppConstants.feedSelected,color: const Color(0xFF8AC85A),),
            label: "",
          ),
          // BottomNavigationBarItem(
          //   icon: SvgPicture.asset(AppConstants.proUnselected),
          //   activeIcon: SvgPicture.asset(AppConstants.proSelected,color: const Color(0xFF8AC85A),),
          //   label: "",
          // ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(AppConstants.profileUnselected),
            activeIcon: SvgPicture.asset(AppConstants.profileSelected,color: const Color(0xFF8AC85A),),
            label: "",
          ),
        ],
      ),
    );
  }
}
