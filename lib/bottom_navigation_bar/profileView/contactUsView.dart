import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/AppConstants.dart';

class ContactDetailView extends StatefulWidget {
  const ContactDetailView({super.key});

  @override
  State<ContactDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ContactDetailView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            AppConstants.planBackground,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            centerTitle: true,
            title: const Text(
              "Contact Us",
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
        Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          bottom: 0,
          left: 0,
          right: 0,
          child: ListView(
            children: [

              ListTile(
                title: Row(
                  children: [
                    Text(
                      "info@astraldesignapp.com",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                leading: Image.asset(AppConstants.email, height: 30,width: 30,),
              ),

              const Divider(),
              ListTile(
                title: Row(
                  children: [
                    Text(
                      "www.crapadvisor.com",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                leading: Image.asset(AppConstants.web,height: 30,width: 30,),
              ),

              const Divider(),
              ListTile(
                title: Row(
                  children: [
                    Text(
                      "facebook/crapadvisor",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                leading: Image.asset(AppConstants.facebook,height: 30,width: 30,),
              ),

              const Divider(),
              ListTile(
                title: Row(
                  children: [
                    Text(
                      "instagram/crapadvisor",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                leading: Image.asset(AppConstants.instagram,height: 30,width: 30,),
              ),
              const Divider(),
            ],
          ),
        ),

      ],)
    );
  }
}


