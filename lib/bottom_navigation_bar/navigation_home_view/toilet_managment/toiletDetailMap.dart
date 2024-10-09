import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../constants/AppConstants.dart';

class What3WodsMapDetailView extends StatefulWidget {
  final LatLng initialPosition; // Accept initial position

  What3WodsMapDetailView({required this.initialPosition});

  @override
  State<What3WodsMapDetailView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<What3WodsMapDetailView>
    with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? currentLocationMarker;
  Set<Polyline> _gridLines = {};
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
  void _generateGrid(LatLngBounds bounds) {
    final double step = 0.0001; // This represents the approximate size of a what3words square
    _gridLines.clear();

    int latLines =
    ((bounds.northeast.latitude - bounds.southwest.latitude) / step)
        .ceil();
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
  void _onCameraMove(CameraPosition position) async {
    if (_mapController != null) {
      double zoomLevel = position.zoom;
      if (zoomLevel >18 && zoomLevel <= 20) {
        LatLngBounds bounds = await _mapController.getVisibleRegion();
        _generateGrid(bounds);
      } else {
        setState(() {
          _gridLines.clear();
        });
      }
    }
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
          infoWindow: InfoWindow(title: 'Initial Location'),
        ),
      );
    });
  }









  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 19.0,
              ),
              onCameraMove: _onCameraMove,
              markers: _markers,
              polylines: _gridLines, // Add this line to display the grid lines
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
