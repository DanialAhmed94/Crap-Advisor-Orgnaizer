import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../constants/AppConstants.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package

class MapDetailView extends StatefulWidget {
  final LatLng initialPosition;
final bool isFromFestival;
  MapDetailView({required this.initialPosition,required this.isFromFestival});

  @override
  State<MapDetailView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<MapDetailView>
    with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? currentLocationMarker;
  String? address;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCustomMarkerIcon();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  // Method to load the custom marker icons
  Future<void> _loadCustomMarkerIcon() async {
    // Load marker for current location


    // Load marker for initial location
    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppConstants.customMarker, // Path to your custom marker for initial location
    );

    // Add marker at the initial position
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('initialLocation'),
          position: widget.initialPosition,
          icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: widget.isFromFestival ? 'Festival Location' : 'Activity Location',
          ),),
      );
    });
  }









  @override
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: padding.top + 10, // Adjust as needed
            left: 10, // Adjust as needed
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // Semi-transparent background
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: SvgPicture.asset(
                  AppConstants.backIcon,
                  // Optionally, set the color or other properties
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 19.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          Positioned(
            top: padding.top + 10, // Adjust as needed
            left: 10, // Adjust as needed
            child: IconButton(
              icon: SvgPicture.asset(
                AppConstants.backIcon,
                // Optionally, set the color or other properties
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          Positioned(
            bottom: 20,
            right: 15,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                // Reset the camera position to the initial location
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    widget.initialPosition, // Reset to initial position
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
        ],
      ),
    );
  }

}
