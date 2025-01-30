import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

import '../constants/AppConstants.dart';

class GoogleMapView extends StatefulWidget {
  late bool isFromFestival;
  GoogleMapView({required this.isFromFestival});
  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView>
    with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(0.0, 0.0); // Default location while loading
  Set<Marker> _markers = {};
  String? selectedLatitude;
  String? selectedLongitude;
  String? selectedAddress;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? currentLocationMarker;

  @override
  void initState() {
    // Register the observer
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestLocationPermission();
    _loadCustomMarkerIcon();
    super.initState();
  }

  @override
  void dispose() {
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<String> _getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Format the address according to UK standard
        return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      }
    } catch (e) {
      print(e);
    }
    return "Unknown Address";
  }

  Future<void> _loadCustomMarkerIcon() async {
    currentLocationMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppConstants.currentLocationMarker,
    );

    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppConstants.customMarker,
    );
  }

  // App lifecycle changes handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is back in the foreground, check the location permission again
      _checkAndRequestLocationPermission();
    }
  }

  // Method to check and request permission
  Future<void> _checkAndRequestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // If permission is granted, fetch the current location
      _getCurrentLocation();
    } else if (permission == LocationPermission.denied) {
      // Permission is denied, show a dialog or try again
      _showPermissionDeniedDialog();
    } else if (permission == LocationPermission.deniedForever) {
      // If permission is permanently denied, show a settings dialog
      _showPermissionPermanentlyDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);

      // Add or update the marker for the user's current location
      _markers
          .removeWhere((marker) => marker.markerId == MarkerId('userLocation'));
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          icon: currentLocationMarker ?? BitmapDescriptor.defaultMarker,
          position: _initialPosition,
          infoWindow: InfoWindow(
            title: 'Your Location',
          ),
        ),
      );

      // Move the map camera to the user's current location
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_initialPosition),
      );
    });
  }

  // Show dialog if location services are disabled
  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Disabled"),
          content: Text(
              "Location services are disabled. Please enable them in settings."),
          actions: <Widget>[
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog if permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Denied"),
          content: Text(
              "Location access is needed to show your location on the map."),
          actions: <Widget>[
            TextButton(
              child: Text("Ask Again"),
              onPressed: () {
                Navigator.of(context).pop();
                _checkAndRequestLocationPermission();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog if permission is permanently denied
  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Permanently Denied"),
          content: Text(
              "You have permanently denied location access. Please go to settings to allow access."),
          actions: <Widget>[
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                openAppSettings();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog if permission is restricted (mostly iOS)
  void _showPermissionRestrictedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Restricted"),
          content: Text("Location access is restricted and cannot be granted."),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                print("GoogleMap controller created.");
              },
              onTap: (LatLng tappedLocation) async {
                setState(() {
                  // Remove the marker for the selected location, not the user location
                  _markers.removeWhere((marker) =>
                  marker.markerId == MarkerId('tappedLocation'));
                  _markers.add(
                    Marker(
                      icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                      markerId: MarkerId('tappedLocation'),
                      position: tappedLocation,
                      infoWindow: InfoWindow(
                        title: 'Selected Location',
                      ),
                    ),
                  );
                  // Save the tapped location in variables
                  selectedLatitude = tappedLocation.latitude.toString();
                  selectedLongitude = tappedLocation.longitude.toString();
                });
                // Fetch the address asynchronously and then update the state with the address
                _getAddressFromLatLng(
                    tappedLocation.latitude, tappedLocation.longitude)
                    .then((address) {
                  setState(() {
                    selectedAddress =
                        address; // Update the address once it's fetched
                  });
                });
              },
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 15,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                // Fetch the current location of the user
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                // Move the camera to the user's current location
                LatLng currentLocation =
                LatLng(position.latitude, position.longitude);
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    currentLocation,
                    14.0, // Zoom level
                  ),
                );
              },
              child: Icon(
                Icons.my_location,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 29,
            left: 100,
            right: 100,
            child: GestureDetector(
              onTap: () {
                if (selectedLatitude != null && selectedLongitude != null) {
                  Navigator.of(context).pop({
                    'latitude': selectedLatitude.toString(),
                    'longitude': selectedLongitude.toString(),
                    'address': selectedAddress.toString(),
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please select a location by tapping on the map.'),
                    ),
                  );
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.lightGreen,
                  ),
                  height: 50,
                  child: Center(child: Text('Save Location'))),
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
                title: widget.isFromFestival
                    ? Text(
                  "Add Festival's Location",
                  style: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : Text(
                  "Add Activity's Location",
                  style: TextStyle(
                    fontFamily: "Ubuntu",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: SvgPicture.asset(AppConstants.greenBackIcon),
                  // Replace with your custom icon
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.transparent,
                elevation: 0, // Remove shadow
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geocoding/geocoding.dart'; // Import the geocoding package
//
// import '../constants/AppConstants.dart';
//
// class GoogleMapView extends StatefulWidget {
//   late bool isFromFestival;
//   GoogleMapView({required this.isFromFestival});
//   @override
//   State<GoogleMapView> createState() => _GoogleMapViewState();
// }
//
// class _GoogleMapViewState extends State<GoogleMapView>
//     with WidgetsBindingObserver {
//   late GoogleMapController _mapController;
//   LatLng _initialPosition = LatLng(0.0, 0.0); // Default location while loading
//   Set<Marker> _markers = {};
//   String? selectedLatitude;
//   String? selectedLongitude;
//   String? selectedAddress;
//   BitmapDescriptor? customMarkerIcon;
//   BitmapDescriptor? currentLocationMarker;
//
//   @override
//   void initState() {
//     // Register the observer
//     WidgetsBinding.instance.addObserver(this);
//     _checkAndRequestLocationPermission();
//     _loadCustomMarkerIcon();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // Unregister the observer
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         // Format the address according to UK standard
//         return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
//       }
//     } catch (e) {
//       print(e);
//     }
//     return "Unknown Address";
//   }
//
//   // Method to load the custom marker icon
//   Future<void> _loadCustomMarkerIcon() async {
//
//       currentLocationMarker = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: 2.5),
//         AppConstants.currentLocationMarker, // Path to your custom marker
//       );
//
//
//       customMarkerIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: 2.5),
//         AppConstants.customMarker, // Path to your custom marker
//       );
//
//
//   }
//   // App lifecycle changes handling
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // App is back in the foreground, check the location permission again
//       _checkAndRequestLocationPermission();
//     }
//   }
//
//   // Method to check and request permission
//   Future<void> _checkAndRequestLocationPermission() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showLocationServiceDisabledDialog();
//       return;
//     }
//
//     // Check permission status
//     PermissionStatus status = await Permission.location.status;
//
//     if (status.isGranted) {
//       // If permission is granted, fetch the current location
//       _getCurrentLocation();
//     } else if (status.isDenied) {
//       // If permission is denied, request it again
//       var newStatus = await Permission.location.request();
//       if (newStatus.isGranted) {
//         _getCurrentLocation();
//       } else if (newStatus.isDenied) {
//         _showPermissionDeniedDialog();
//       }
//     } else if (status.isPermanentlyDenied) {
//       // If permission is permanently denied, show settings option
//       _showPermissionPermanentlyDeniedDialog();
//     } else if (status.isRestricted) {
//       // Handle restricted permission case (mostly iOS)
//       _showPermissionRestrictedDialog();
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     setState(() {
//       _initialPosition = LatLng(position.latitude, position.longitude);
//
//       // Add or update the marker for the user's current location
//       _markers.removeWhere((marker) => marker.markerId == MarkerId('userLocation'));
//       _markers.add(
//         Marker(
//           markerId: MarkerId('userLocation'),
//           icon:  currentLocationMarker ?? BitmapDescriptor.defaultMarker,
//           position: _initialPosition,
//           infoWindow: InfoWindow(
//             title: 'Your Location',
//           ),
//         ),
//       );
//
//       // Move the map camera to the user's current location
//       _mapController.animateCamera(
//         CameraUpdate.newLatLng(_initialPosition),
//       );
//     });
//   }
//
//   // Show dialog if location services are disabled
//   void _showLocationServiceDisabledDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Location Services Disabled"),
//           content: Text(
//               "Location services are disabled. Please enable them in settings."),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Open Settings"),
//               onPressed: () {
//                 Geolocator.openLocationSettings();
//               },
//             ),
//             TextButton(
//               child: Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Show dialog if permission is denied
//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Location Permission Denied"),
//           content: Text(
//               "Location access is needed to show your location on the map."),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Ask Again"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _checkAndRequestLocationPermission();
//               },
//             ),
//             TextButton(
//               child: Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Show dialog if permission is permanently denied
//   void _showPermissionPermanentlyDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Location Permission Permanently Denied"),
//           content: Text(
//               "You have permanently denied location access. Please go to settings to allow access."),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Open Settings"),
//               onPressed: () {
//                 openAppSettings();
//               },
//             ),
//             TextButton(
//               child: Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Show dialog if permission is restricted (mostly iOS)
//   void _showPermissionRestrictedDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Location Permission Restricted"),
//           content: Text("Location access is restricted and cannot be granted."),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _initialPosition,
//                 zoom: 14.0,
//               ),
//               markers: _markers,
//               onMapCreated: (GoogleMapController controller) {
//                 _mapController = controller;
//               },
//               onTap: (LatLng tappedLocation)async {
//                 setState(() {
//                   // Remove the marker for the selected location, not the user location
//                   _markers.removeWhere((marker) => marker.markerId == MarkerId('tappedLocation'));
//                   _markers.add(
//                     Marker(
//                       icon:  customMarkerIcon ?? BitmapDescriptor.defaultMarker,
//                       markerId: MarkerId('tappedLocation'),
//                       position: tappedLocation,
//                       infoWindow: InfoWindow(
//                         title: 'Selected Location',
//                       ),
//                     ),
//                   );
//                   // Save the tapped location in variables
//                   selectedLatitude = tappedLocation.latitude.toString();
//                   selectedLongitude = tappedLocation.longitude.toString();
//                 });
//                 // Fetch the address asynchronously and then update the state with the address
//                 _getAddressFromLatLng(tappedLocation.latitude, tappedLocation.longitude).then((address) {
//                   setState(() {
//                     selectedAddress = address;  // Update the address once it's fetched
//                   });
//                 });
//               },
//
//               myLocationButtonEnabled: true,
//               zoomControlsEnabled: false,
//               mapToolbarEnabled: false,
//               compassEnabled: false,
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             right: 15,
//             child: FloatingActionButton(
//               backgroundColor: Colors.white,
//               onPressed: () async {
//                 // Fetch the current location of the user
//                 Position position = await Geolocator.getCurrentPosition(
//                   desiredAccuracy: LocationAccuracy.high,
//                 );
//
//                 // Move the camera to the user's current location
//                 LatLng currentLocation =
//                 LatLng(position.latitude, position.longitude);
//                 _mapController.animateCamera(
//                   CameraUpdate.newLatLngZoom(
//                     currentLocation,
//                     14.0, // Zoom level
//                   ),
//                 );
//               },
//               child: Icon(
//                 Icons.my_location,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 29,
//             left: 100,
//             right: 100,
//             child: GestureDetector(
//               onTap: () {
//                 if (selectedLatitude != null && selectedLongitude != null) {
//                   Navigator.of(context).pop({
//                     'latitude': selectedLatitude.toString(),
//                     'longitude': selectedLongitude.toString(),
//                     'address': selectedAddress.toString(),
//                   });
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                           'Please select a location by tapping on the map.'),
//                     ),
//                   );
//                 }
//               },
//               child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     color: Colors.lightGreen,
//                   ),
//                   height: 50,
//                   child: Center(child: Text('Save Location'))),
//             ),
//           ),
//           Positioned(
//             top: 10,
//             left: 0,
//             right: 0,
//             child: PreferredSize(
//               preferredSize: Size.fromHeight(kToolbarHeight),
//               child: AppBar(
//                 centerTitle: true,
//                 title: widget.isFromFestival
//                     ? Text(
//                   "Add Festival's Location",
//                   style: TextStyle(
//                     fontFamily: "Ubuntu",
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )
//                     : Text(
//                   "Add Activity's Location",
//                   style: TextStyle(
//                     fontFamily: "Ubuntu",
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 leading: IconButton(
//                   icon: SvgPicture.asset(AppConstants.greenBackIcon),
//                   // Replace with your custom icon
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 backgroundColor: Colors.transparent,
//                 elevation: 0, // Remove shadow
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
