import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/AppConstants.dart';

class SocialMediaHomeView extends StatelessWidget {
  const SocialMediaHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                title: Text(
                  "Feed",
                  style: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: Image.asset(AppConstants.logo),
                  onPressed: null,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.11, // Place below the AppBar
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: 10, // Change based on the number of posts
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'This work is in process.',
                            style: TextStyle(fontFamily: "Ubuntu"),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Information and Time
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                              AssetImage('assets/images/user.png'), // Replace with user image
                            ),
                            title: Text('James'), // Replace with actual user name
                            subtitle: Text('London, UK'),
                            trailing: Text('2 Hr ago'), // Replace with time ago data
                          ),

                          // Post Image
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.asset(
                                'assets/images/toilet.png', // Replace with post image
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * 0.4, // 50% of screen height
                              ),
                            ),
                          ),

                          // Like and Comment Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text('2.4k'),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('147'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button (Plus Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for button (e.g., navigate to post creation page)
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
}
