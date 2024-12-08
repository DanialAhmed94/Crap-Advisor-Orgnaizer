import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../api/deleteRegisteredUser.dart';
import '../../../api/getEventsByFestival.dart';
import '../../../api/getRegisteredUsers.dart';
import '../../../constants/AppConstants.dart';
import '../../../data_model/festivalCollection_model.dart';
import '../../../data_model/registeredUser_model.dart';
import '../../../provider/festivalCollection_provider.dart';
import '../../../utilities/utilities.dart'; // For showErrorDialog, etc.

class RegisteredUsersView extends StatefulWidget {
  const RegisteredUsersView({Key? key}) : super(key: key);

  @override
  State<RegisteredUsersView> createState() => _RegisteredUsersViewState();
}

class _RegisteredUsersViewState extends State<RegisteredUsersView> {
  String? _selectedFestivalId;
  String? _selectedEventId;
  Future<List<Map<String, String>>>? _eventsFuture;

  Future<RegisteredUsersResponse?>? _registeredUsersFuture;

  /// Fetches events for the selected festival and resets the selected event.
  void _fetchEvents(String festivalId) {
    setState(() {
      _eventsFuture = getEventsByFestival(festivalId);
      _selectedEventId = null;
      _registeredUsersFuture = null; // Reset the users future as well
    });
  }

  /// Refreshes the user list by calling the API again with the currently selected event ID.
  void _refreshUserList() {
    if (_selectedEventId != null) {
      setState(() {
        _registeredUsersFuture = getRegisteredUsers(context, _selectedEventId!);
      });
    }
  }

  /// Builds the festival dropdown menu.
  Widget _buildFestivalDropdown() {
    return Consumer<FestivalProvider>(
      builder: (context, festivalProvider, child) {
        return DropdownButtonFormField<String>(
          value: _selectedFestivalId,
          decoration: InputDecoration(
            prefixIcon: SvgPicture.asset(
              AppConstants.dropDownPrefixIcon,
              color: const Color(0xFF8AC85A),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            hintText: 'Select Festival',
          ),
          items: festivalProvider.festivals.map((Festival festival) {
            return DropdownMenuItem<String>(
              value: festival.id.toString(),
              child: Text(
                festival.nameOrganizer ?? "",
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Prevents layout issues with very long names
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFestivalId = newValue;
                _fetchEvents(newValue);
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a festival';
            }
            return null;
          },
        );
      },
    );
  }

  /// Builds the event dropdown menu based on the selected festival.
  Widget _buildEventDropdown() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (_selectedFestivalId == null) {
          return _buildDisabledDropdown('Select festival first');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDisabledDropdown('Loading events...');
        }

        if (snapshot.hasError) {
          return _buildDisabledDropdown('Error loading events');
        }

        final events = snapshot.data;
        if (events == null || events.isEmpty) {
          return _buildDisabledDropdown('No events found');
        }

        // Ensure selected event is still valid
        if (_selectedEventId != null &&
            !events.any((event) => event['event_id'] == _selectedEventId)) {
          _selectedEventId = null;
        }

        return DropdownButtonFormField<String>(
          value: _selectedEventId,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Select Event',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
          ),
          items: events.map((event) {
            return DropdownMenuItem<String>(
              value: event['event_id'],
              child: Text(
                event['event_title'] ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Prevents layout issues with very long names
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEventId = value;
              if (_selectedEventId != null) {
                // Fetch registered users whenever a new event is selected
                _registeredUsersFuture = getRegisteredUsers(context, _selectedEventId!);
              } else {
                _registeredUsersFuture = null;
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an event';
            }
            return null;
          },
        );
      },
    );
  }

  /// Builds a disabled dropdown with a hint text displayed, used for intermediate states.
  Widget _buildDisabledDropdown(String hintText) {
    return DropdownButtonFormField<String>(
      items: const [],
      onChanged: null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Deletes a user and refreshes the user list.
  Future<void> _deleteUser(String userId) async {
    bool success = await deleteRegisteredUser(context, userId); // Implement this API call
    if (success) {
      // Refresh user list after successful delete
      _refreshUserList();
    } else {
      // If delete failed, show error
      showErrorDialog(context, "Failed to delete user.", []);
    }
  }

  /// Builds the list of registered users or a message if no event selected.
  Widget _buildRegisteredUsersList() {
    if (_selectedEventId == null) {
      return const Center(
        child: Text(
          "Select an event to see registered users",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    // Use a FutureBuilder to show loading state, data, or error
    return FutureBuilder<RegisteredUsersResponse?>(
      future: _registeredUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching data
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Show error message if something went wrong
          return Center(
            child: Text("Error loading users"),
          );
        } else {
          // Handle the response
          final response = snapshot.data;
          if (response == null || response.data == null || response.data!.isEmpty) {
            // No users found
            return const Center(
              child: Text(
                "No registered users found for this event.",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          // If we have users, display them in a responsive manner
          final users = response.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              double cardHorizontalPadding = constraints.maxWidth * 0.04;
              double avatarRadius = constraints.maxWidth * 0.07; // scale avatar size
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: cardHorizontalPadding),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: const Color(0xFF8AC85A),
                            child: Text(
                              (user.userName?.isNotEmpty == true
                                  ? user.userName![0].toUpperCase()
                                  : '?'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.userName ?? 'No name',
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.04, // scale text
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.userEmail ?? 'No email',
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.035,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.userPhone ?? 'No contact',
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.035,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Confirm deletion
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.warning, color: Colors.red),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Delete User",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete this user?",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        if (user.id != null) {
                                          _deleteUser(user.id!.toString());
                                        }
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppConstants.planBackground,
              fit: BoxFit.fill,
            ),
          ),

          // App Bar
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(
                centerTitle: true,
                title: const Text(
                  "Registered Users",
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
                elevation: 0,
              ),
            ),
          ),

          // Content
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            bottom: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Decorative container behind the dropdowns
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          spreadRadius: 1.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFestivalDropdown(),
                        const SizedBox(height: 20),
                        _buildEventDropdown(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildRegisteredUsersList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
