import 'package:crap_advisor_orgnaizer/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/AppConstants.dart';

class ProfileDetailView extends StatefulWidget {
  const ProfileDetailView({super.key});

  @override
  State<ProfileDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ProfileDetailView> {
  String? _name = '';
  String? _email = '';
  String? _phone = '';
  String? _organizationName = '';
  String? _organizationAddress = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Load the profile data asynchronously
    final name = await getUserName() ?? "";
    final email = await getUserEmail() ?? "";
    final phone = await getUserPhone() ?? "";
    final orgAddress = await getOrgAddress() ?? "";
    final orgName = await getOrgName() ?? "";

    // Update the state to refresh the UI after loading data
    setState(() {
      _name = name;
      _email = email;
      _phone = phone;
      _organizationAddress = orgAddress;
      _organizationName = orgName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                "Manage Profile",
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
                      const Text("Name: ", style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          _name ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  leading: SvgPicture.asset(
                    AppConstants.myProfile, height: 30, width: 30,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    children: [
                      const Text("Email: ", style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          _email ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  leading: Image.asset(
                    AppConstants.email, height: 30, width: 30,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    children: [
                      const Text("Contact: ", style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          _phone ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  leading: Image.asset(
                    AppConstants.phone, height: 30, width: 30,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    children: [
                      const Text("Organization Name: ", style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                        _organizationName ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 3, // Limit to 2 lines
                          overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                          softWrap: true, // Allow text to wrap to the next line
                        ),
                      ),
                    ],
                  ),
                  leading: Image.asset(
                    AppConstants.devices, height: 35, width: 32,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    children: [
                      const Text("Organization Address: ", style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          _organizationAddress ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 4, // Limit to 2 lines
                          overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                          softWrap: true, // Allow text to wrap to the next line
                        ),
                      ),
                    ],
                  ),
                  leading: Image.asset(
                    AppConstants.member, height: 30, width: 30,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
