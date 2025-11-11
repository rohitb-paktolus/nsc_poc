import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FlutterMap extends StatefulWidget {
  const FlutterMap({super.key});

  @override
  State<FlutterMap> createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMap> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location: $e");
      }
    }
  }

  void _moveCameraToCurrentPosition() {
    if (mapController != null && _currentPosition != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition ?? const LatLng(-33.865143, 151.209900),
          zoom: 14,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("current pos: $_currentPosition");
    }
    if (_currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition ?? const LatLng(-33.865143, 151.209900),
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        if (kDebugMode) {
          print("Map controller set");
        }
        mapController = controller;
        _moveCameraToCurrentPosition();
      },
    );
  }
}