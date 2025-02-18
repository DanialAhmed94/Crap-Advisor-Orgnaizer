import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/AppConstants.dart';
import 'package:http/http.dart' as http;

class What3WodsMapView extends StatefulWidget {
  final bool isEditMode;
  final double? initialLat;
  final double? initialLng;

  What3WodsMapView({
    this.isEditMode = false,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<What3WodsMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<What3WodsMapView>
    with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(0.0, 0.0);
  Set<Marker> _markers = {};
  String? selectedLatitude;
  String? selectedLongitude;
  Set<Polyline> _gridLines = {};
  String _what3WordsAddress = "";
  bool _isMapLoading = true;
  Marker? _userLocationMarker;
  Marker? _originalLocationMarker;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? currentLocationMarker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadCustomMarkerIcon();

    // If we are in edit mode and have initial coords, use them as starting point
    if (widget.isEditMode &&
        widget.initialLat != null &&
        widget.initialLng != null) {
      _initialPosition = LatLng(widget.initialLat!, widget.initialLng!);
      _isMapLoading = false;

      // Place a marker at the original location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addOriginalLocationMarker(_initialPosition);
      });
    } else {
      // Normal mode or no initial coords: request permission and get current location
      _checkAndRequestLocationPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRequestLocationPermission();
    }
  }

  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      if (!(widget.isEditMode &&
          widget.initialLat != null &&
          widget.initialLng != null)) {
        // Get current location only if not in edit mode or we don't have initial coords
        _getCurrentLocation();
      }
    } else if (status.isDenied) {
      var newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        if (!(widget.isEditMode &&
            widget.initialLat != null &&
            widget.initialLng != null)) {
          _getCurrentLocation();
        }
      } else if (newStatus.isDenied) {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedDialog();
    } else if (status.isRestricted) {
      _showPermissionRestrictedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      // If not in edit mode or no initial coords, set initial position to current location
      if (!(widget.isEditMode &&
          widget.initialLat != null &&
          widget.initialLng != null)) {
        _initialPosition = LatLng(position.latitude, position.longitude);
      }

      _userLocationMarker = Marker(
        icon: currentLocationMarker ?? BitmapDescriptor.defaultMarker,
        markerId: MarkerId('userLocation'),
        position: _initialPosition,
        infoWindow: InfoWindow(
          title: 'Your Location',
        ),
      );

      _markers.add(_userLocationMarker!);
      _isMapLoading = false;

      if (_mapController != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_initialPosition),
        );
      }
    });
  }

  void _addOriginalLocationMarker(LatLng position) {
    // Add a marker for the original location in edit mode
    _originalLocationMarker = Marker(
      icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
      markerId: MarkerId('originalLocation'),
      position: position,
      infoWindow: InfoWindow(
        title: 'Original Location',
      ),
    );

    setState(() {
      // If we have a user location marker, keep it
      if (_userLocationMarker != null) {
        _markers = {_userLocationMarker!, _originalLocationMarker!};
      } else {
        _markers = {_originalLocationMarker!};
      }

      _mapController.animateCamera(
        CameraUpdate.newLatLng(position),
      );
    });
  }

  void _onMapTap(LatLng latLng) async {
    selectedLatitude = latLng.latitude.toString();
    selectedLongitude = latLng.longitude.toString();

    String? what3Words =
        await convertToWhat3Words(latLng.latitude, latLng.longitude);

    setState(() {
      _what3WordsAddress = what3Words ?? 'Unable to fetch What3Words address';

      Marker tappedLocationMarker = Marker(
        markerId: MarkerId('selectedLocation'),
        icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
        position: latLng,
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: _what3WordsAddress,
        ),
      );

      // Remove the original location marker if we are in edit mode and a new location is selected
      if (widget.isEditMode && _originalLocationMarker != null) {
        _markers.remove(_originalLocationMarker);
        _originalLocationMarker = null;
      }

      // Keep user location marker if it exists
      if (_userLocationMarker != null) {
        _markers = {_userLocationMarker!, tappedLocationMarker};
      } else {
        _markers = {tappedLocationMarker};
      }
    });
  }

  void _generateGrid(LatLngBounds bounds) {
    final double step = 0.0001;
    _gridLines.clear();

    int latLines =
        ((bounds.northeast.latitude - bounds.southwest.latitude) / step).ceil();
    int lngLines =
        ((bounds.northeast.longitude - bounds.southwest.longitude) / step)
            .ceil();

    for (int i = 0; i <= latLines; i++) {
      double lat = bounds.southwest.latitude + (step * i);
      _gridLines.add(
        Polyline(
          polylineId: PolylineId('lat_$i'),
          points: [
            LatLng(lat, bounds.southwest.longitude),
            LatLng(lat, bounds.northeast.longitude),
          ],
          color: Colors.blue,
          width: 1,
        ),
      );
    }

    for (int i = 0; i <= lngLines; i++) {
      double lng = bounds.southwest.longitude + (step * i);
      _gridLines.add(
        Polyline(
          polylineId: PolylineId('lng_$i'),
          points: [
            LatLng(bounds.southwest.latitude, lng),
            LatLng(bounds.northeast.latitude, lng),
          ],
          color: Colors.blue,
          width: 1,
        ),
      );
    }

    setState(() {});
  }

  Future<String?> convertToWhat3Words(double lat, double lng) async {
    const apiKey = 'J78IRDS5';
    final url =
        "https://api.what3words.com/v3/convert-to-3wa?coordinates=$lat%2C$lng&key=$apiKey";

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('words')) {
          return jsonResponse['words'];
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception(
            'Failed to get What3Words address: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      _showSnackBar('Request timed out. Please try again.');
      return null;
    } on SocketException catch (_) {
      _showSnackBar('No Internet connection. Please check your network.');
      return null;
    } catch (e) {
      _showSnackBar('An error occurred: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _onCameraMove(CameraPosition position) async {
    if (_mapController != null) {
      double zoomLevel = position.zoom;
      if (zoomLevel > 18 && zoomLevel <= 20) {
        LatLngBounds bounds = await _mapController.getVisibleRegion();
        _generateGrid(bounds);
      } else {
        setState(() {
          _gridLines.clear();
        });
      }
    }
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Disabled"),
          content: Text("Location services are disabled. Please enable them."),
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
    final titleText =
        widget.isEditMode ? "Edit Toilet's Location" : "Add Toilet's Location";

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 20.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                setState(() {
                  _isMapLoading = false;
                });
              },
              onCameraMove: _onCameraMove,
              polylines: _gridLines,
              onTap: _onMapTap,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          if (_isMapLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 20,
            right: 15,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                LatLng currentLocation =
                    LatLng(position.latitude, position.longitude);
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    currentLocation,
                    20.0,
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
                if (selectedLatitude != null &&
                    selectedLongitude != null &&
                    _what3WordsAddress != null) {
                  Navigator.of(context).pop({
                    'latitude': selectedLatitude,
                    'longitude': selectedLongitude,
                    'what3Words': _what3WordsAddress
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
                title: Text(
                  titleText,
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
        ],
      ),
    );
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../constants/AppConstants.dart';
// import 'package:http/http.dart' as http;
//
// class What3WodsMapView extends StatefulWidget {
//   @override
//   State<What3WodsMapView> createState() => _GoogleMapViewState();
// }
//
// class _GoogleMapViewState extends State<What3WodsMapView>
//     with WidgetsBindingObserver {
//   late GoogleMapController _mapController;
//   LatLng _initialPosition = LatLng(0.0, 0.0); // Default location while loading
//   Set<Marker> _markers = {};
//   String? selectedLatitude;
//   String? selectedLongitude;
//   Set<Polyline> _gridLines = {};
//   String _what3WordsAddress = "";
//   bool _isMapLoading = true; // Track map loading state
//   Marker? _userLocationMarker; // Marker for the user's location
//   BitmapDescriptor? customMarkerIcon;
//   BitmapDescriptor? currentLocationMarker;
//
//
//   @override
//   void initState() {
//     super.initState();
//     // Register the observer
//     WidgetsBinding.instance.addObserver(this);
//     _checkAndRequestLocationPermission();
//     _loadCustomMarkerIcon();
//   }
//
//   @override
//   void dispose() {
//     // Unregister the observer
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//   // Method to load the custom marker icon
//   Future<void> _loadCustomMarkerIcon() async {
//
//     currentLocationMarker = await BitmapDescriptor.fromAssetImage(
//       ImageConfiguration(devicePixelRatio: 2.5),
//       AppConstants.currentLocationMarker, // Path to your custom marker
//     );
//
//
//     customMarkerIcon = await BitmapDescriptor.fromAssetImage(
//       ImageConfiguration(devicePixelRatio: 2.5),
//       AppConstants.customMarker, // Path to your custom marker
//     );
//
//
//   }
//   // App lifecycle changes handling
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkAndRequestLocationPermission();
//     }
//   }
//
//   // Method to check and request permission
//   Future<void> _checkAndRequestLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showLocationServiceDisabledDialog();
//       return;
//     }
//
//     PermissionStatus status = await Permission.location.status;
//
//     if (status.isGranted) {
//       _getCurrentLocation();
//     } else if (status.isDenied) {
//       var newStatus = await Permission.location.request();
//       if (newStatus.isGranted) {
//         _getCurrentLocation();
//       } else if (newStatus.isDenied) {
//         _showPermissionDeniedDialog();
//       }
//     } else if (status.isPermanentlyDenied) {
//       _showPermissionPermanentlyDeniedDialog();
//     } else if (status.isRestricted) {
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
//       // Update or add the user's location marker
//       _userLocationMarker = Marker(
//         icon:  currentLocationMarker ?? BitmapDescriptor.defaultMarker,
//         markerId: MarkerId('userLocation'),
//         position: _initialPosition,
//         infoWindow: InfoWindow(
//           title: 'Your Location',
//         ),
//       );
//
//       // Keep both markers: user's location and selected location (if any)
//       _markers.add(_userLocationMarker!);
//
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
//   // Method to handle map taps and place a marker
//   void _onMapTap(LatLng latLng) async {
//     selectedLatitude = latLng.latitude.toString();
//     selectedLongitude = latLng.longitude.toString();
//
//     String? what3Words =
//     await convertToWhat3Words(latLng.latitude, latLng.longitude);
//
//     setState(() {
//       _what3WordsAddress =
//           what3Words ?? 'Unable to fetch What3Words address';
//
//       // Add or update marker at the tapped location
//       Marker tappedLocationMarker = Marker(
//         markerId: MarkerId('selectedLocation'),
//         icon:  customMarkerIcon ?? BitmapDescriptor.defaultMarker,
//         position: latLng,
//         infoWindow: InfoWindow(
//           title: 'Selected Location',
//           snippet: _what3WordsAddress,
//         ),
//       );
//
//       // Ensure the user's location marker remains on the map along with the selected location marker
//       _markers = {_userLocationMarker!, tappedLocationMarker};
//     });
//   }
//
//   void _generateGrid(LatLngBounds bounds) {
//     final double step = 0.0001; // This represents the approximate size of a what3words square
//     _gridLines.clear();
//
//     int latLines =
//     ((bounds.northeast.latitude - bounds.southwest.latitude) / step)
//         .ceil();
//     int lngLines =
//     ((bounds.northeast.longitude - bounds.southwest.longitude) / step)
//         .ceil();
//
//     for (int i = 0; i <= latLines; i++) {
//       double lat = bounds.southwest.latitude + (step * i);
//       _gridLines.add(
//         Polyline(
//           polylineId: PolylineId('lat_$i'),
//           points: [
//             LatLng(lat, bounds.southwest.longitude),
//             LatLng(lat, bounds.northeast.longitude),
//           ],
//           color: Colors.blue,
//           width: 1,
//         ),
//       );
//     }
//
//     for (int i = 0; i <= lngLines; i++) {
//       double lng = bounds.southwest.longitude + (step * i);
//       _gridLines.add(
//         Polyline(
//           polylineId: PolylineId('lng_$i'),
//           points: [
//             LatLng(bounds.southwest.latitude, lng),
//             LatLng(bounds.northeast.latitude, lng),
//           ],
//           color: Colors.blue,
//           width: 1,
//         ),
//       );
//     }
//
//     setState(() {});
//   }
//
//   Future<String?> convertToWhat3Words(double lat, double lng) async {
//     const apiKey = 'FO6J2VWD';
//     final url =
//         "https://api.what3words.com/v3/convert-to-3wa?coordinates=$lat%2C$lng&key=$apiKey";
//
//     try {
//       final response =
//       await http.get(Uri.parse(url)).timeout(Duration(seconds: 30));
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         if (jsonResponse.containsKey('words')) {
//           return jsonResponse['words'];
//         } else {
//           throw Exception("Invalid response format");
//         }
//       } else {
//         throw Exception(
//             'Failed to get What3Words address: ${response.statusCode}');
//       }
//     } on TimeoutException catch (_) {
//       _showSnackBar('Request timed out. Please try again.');
//       return null;
//     } on SocketException catch (_) {
//       _showSnackBar('No Internet connection. Please check your network.');
//       return null;
//     } catch (e) {
//       _showSnackBar('An error occurred: $e');
//       return null;
//     }
//   }
//
//   // Method to show SnackBar
//   void _showSnackBar(String message) {
//     final snackBar = SnackBar(content: Text(message));
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
//
//   void _onCameraMove(CameraPosition position) async {
//     if (_mapController != null) {
//       double zoomLevel = position.zoom;
//       if (zoomLevel > 18 && zoomLevel <= 20) {
//         LatLngBounds bounds = await _mapController.getVisibleRegion();
//         _generateGrid(bounds);
//       } else {
//         setState(() {
//           _gridLines.clear();
//         });
//       }
//     }
//   }
//
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
//                 zoom: 20.0,
//               ),
//               markers: _markers,
//               onMapCreated: (GoogleMapController controller) {
//                 _mapController = controller;
//                 setState(() {
//                   _isMapLoading = false;
//                 });
//               },
//               onCameraMove: _onCameraMove,
//               polylines: _gridLines,
//               onTap: _onMapTap,
//               myLocationButtonEnabled: true,
//               zoomControlsEnabled: false,
//               mapToolbarEnabled: false,
//               compassEnabled: false,
//             ),
//           ),
//           if (_isMapLoading)
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//           Positioned(
//             bottom: 20,
//             right: 15,
//             child: FloatingActionButton(
//               backgroundColor: Colors.white,
//               onPressed: () async {
//                 Position position = await Geolocator.getCurrentPosition(
//                   desiredAccuracy: LocationAccuracy.high,
//                 );
//
//                 LatLng currentLocation =
//                 LatLng(position.latitude, position.longitude);
//                 _mapController.animateCamera(
//                   CameraUpdate.newLatLngZoom(
//                     currentLocation,
//                     20.0,
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
//                 if (selectedLatitude != null &&
//                     selectedLongitude != null &&
//                     _what3WordsAddress != null) {
//                   Navigator.of(context).pop({
//                     'latitude': selectedLatitude,
//                     'longitude': selectedLongitude,
//                     'what3Words': _what3WordsAddress
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
//                 title: Text(
//                   "Add Toilet's Location",
//                   style: TextStyle(
//                     fontFamily: "Ubuntu",
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 leading: IconButton(
//                   icon: SvgPicture.asset(AppConstants.greenBackIcon),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
