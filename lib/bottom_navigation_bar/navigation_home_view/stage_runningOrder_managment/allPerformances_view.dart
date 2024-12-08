import 'package:crap_advisor_orgnaizer/bottom_navigation_bar/navigation_home_view/stage_runningOrder_managment/performanceDetailaview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transition.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/performanceCollection_model.dart';
import '../../../provider/performanceCollection_provider.dart';

class AllPerformancesView extends StatefulWidget {
  const AllPerformancesView({super.key});

  @override
  State<AllPerformancesView> createState() => _AllPerformancesViewState();
}

class _AllPerformancesViewState extends State<AllPerformancesView> {
  bool _isLoading = false;

  Future<void> _deletePerformance(BuildContext context, Performance performance) async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Performance"),
          content: Text("Are you sure you want to delete this performance?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels deletion
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms deletion
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Perform deletion using the provider
        await Provider.of<PerformanceProvider>(context, listen: false)
            .deletePerformance(context, performance.id.toString());

        // Re-fetch performances to update the list
        await Provider.of<PerformanceProvider>(context, listen: false)
            .fetchPerformances(context);


      } catch (error) {
        // Handle any errors during deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete performance. Please try again.',
              style: TextStyle(fontFamily: "Ubuntu"),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Add AppBar here if needed
      body: Stack(
        children: [
          // Background image
          // Background image
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  // AppBar Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      IconButton(
                        icon: SvgPicture.asset(AppConstants.greenBackIcon),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      // Title
                      Text(
                        "All Performances",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Placeholder for symmetry
                      SizedBox(width: 40), // Adjust based on back button size
                    ],
                  ),
                  SizedBox(height: 20), // Space between AppBar and performances
                  Consumer<PerformanceProvider>(
                    builder: (context, performanceProvider, child) {
                      // Access the performances list from the provider
                      List<Performance> performances = performanceProvider.performances;

                      // If the list is empty, show a centered message
                      if (performances.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No performances available",
                              style: TextStyle(
                                fontFamily: "UbuntuMedium",
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }

                      // If the list is not empty, show the performance cards
                      return Column(
                        children: performances.map((performance) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  // Performance Icon
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF8AC85A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AppConstants.performancesIcon,
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  // Performance Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          performance.performanceTitle ?? "",
                                          style: TextStyle(
                                            fontFamily: "UbuntuMedium",
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          "Artist: ${performance.artistName ?? "N/A"}",
                                          style: TextStyle(
                                            fontFamily: "Ubuntu",
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 2.0),
                                        Text(
                                          "Date: ${performance.startDate ?? "N/A"}",
                                          style: TextStyle(
                                            fontFamily: "Ubuntu",
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Action Buttons
                                  Column(
                                    children: [
                                      // View Detail Button
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            FadePageRouteBuilder(
                                              widget: PerformanceDetailView(performance: performance),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF8AC85A),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        child: Text(
                                          "View Detail",
                                          style: TextStyle(
                                            fontFamily: "UbuntuMedium",
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      // Delete Button
                                      GestureDetector(
                                        onTap: () async {
                                          await _deletePerformance(context, performance);
                                        },
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
          ),
          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
