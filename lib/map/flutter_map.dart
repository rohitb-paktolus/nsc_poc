import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart' hide Polyline;

class FlutterMap extends StatefulWidget {
  const FlutterMap({super.key});

  @override
  State<FlutterMap> createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMap> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _isLoading = true;
  bool _isSearching = false;
  String _statusMessage = 'Initializing...';

  late GoogleMapsPlaces _places;
  late GoogleMapsDirections _directions;

  String? _routeDistance;
  String? _routeDuration;
  bool _isRouteActive = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _getCurrentLocation();
  }

  void _initializeServices() {
    final apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      if (kDebugMode) print("Maps API Key not found in env file");
      setState(() => _statusMessage = 'Error: API Key Missing');
    }
    _places = GoogleMapsPlaces(apiKey: apiKey);
    _directions = GoogleMapsDirections(apiKey: apiKey);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _statusMessage = 'Getting your location...';
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location permission denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _addCurrentLocationMarker();

      if (mounted) {
        _moveCameraToCurrentPosition();
      }

      await _fetchNearbyEducationalInstitutions();
    } catch (e) {
      if (kDebugMode) print("Error fetching location: $e");
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error finding location';
      });
    }
  }

  Future<void> _getDirections(LatLng destination, String placeName) async {
    if (_currentPosition == null) return;

    setState(() {
      _isSearching = true;
      _statusMessage = 'Calculating route...';
    });

    try {
      final response = await _directions.directionsWithLocation(
        Location(
            lat: _currentPosition!.latitude, lng: _currentPosition!.longitude),
        Location(lat: destination.latitude, lng: destination.longitude),
        travelMode: TravelMode.driving,
      );

      if (response.status == "OK") {
        final route = response.routes.first;
        final leg = route.legs.first;
        final polylinePoints = _decodePolyline(route.overviewPolyline.points);

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route_to_$placeName'),
              points: polylinePoints,
              color: Colors.blueAccent,
              width: 5,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

          _routeDistance = leg.distance.text;
          _routeDuration = leg.duration.text;
          _isRouteActive = true;
          _isSearching = false;
          _statusMessage = 'Route to $placeName';
        });

        _fitBounds(_currentPosition!, destination);
      } else {
        if (kDebugMode) {
          print("Directions API Detailed Error: ${response.errorMessage}");
        }
        setState(() {
          _isSearching = false;
          _statusMessage = response.status == 'REQUEST_DENIED'
              ? 'Error: Enable Directions API'
              : 'Directions: ${response.status}';
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _statusMessage = 'Error getting directions';
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _fitBounds(LatLng origin, LatLng dest) {
    if (!mounted) return;

    double minLat =
        origin.latitude < dest.latitude ? origin.latitude : dest.latitude;
    double minLng =
        origin.longitude < dest.longitude ? origin.longitude : dest.longitude;
    double maxLat =
        origin.latitude > dest.latitude ? origin.latitude : dest.latitude;
    double maxLng =
        origin.longitude > dest.longitude ? origin.longitude : dest.longitude;

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _isRouteActive = false;
      _routeDistance = null;
      _routeDuration = null;
    });
    _moveCameraToCurrentPosition();
    _fetchNearbyEducationalInstitutions();
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'You are here'),
            zIndex: 2,
          ),
        );
      });
    }
  }

  Future<void> _fetchNearbyEducationalInstitutions() async {
    if (_currentPosition == null) return;

    setState(() {
      _isSearching = true;
      _statusMessage = 'Searching for schools...';
    });

    try {
      final location = Location(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );

      final response = await _places.searchNearbyWithRadius(
        location,
        5000,
        type: 'college',
        keyword: 'school university college',
      );

      if (response.status == "OK") {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value != 'current_location');
        });

        for (final place in response.results) {
          _addEducationalMarker(place);
        }

        setState(() {
          _isSearching = false;
          _statusMessage = 'Found ${_markers.length - 1} institutions';
        });
      } else if (response.status == "ZERO_RESULTS") {
        setState(() {
          _isSearching = false;
          _statusMessage = 'No schools found nearby';
        });
      } else {
        // Detailed logging for debugging
        if (kDebugMode) {
          print("===== PLACES API ERROR =====");
          print("Status: ${response.status}");
          print("Error Message: ${response.errorMessage}");
          print("============================");
        }
        setState(() {
          _isSearching = false;
          if (response.status == 'REQUEST_DENIED') {
            // Check console for "Billing not enabled" or "API not activated"
            _statusMessage = 'Error: Check Console logs';
          } else {
            _statusMessage = 'Places: ${response.status}';
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching places: $e");
      setState(() {
        _isSearching = false;
        _statusMessage = 'Connection Error';
      });
    }
  }

  void _addEducationalMarker(PlacesSearchResult place) {
    if (place.geometry?.location == null) return;

    final marker = Marker(
      markerId: MarkerId(place.placeId),
      position: LatLng(
        place.geometry!.location.lat,
        place.geometry!.location.lng,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: 'Tap for details',
      ),
      onTap: () => _showPlaceDetails(place),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _showPlaceDetails(PlacesSearchResult place) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.school, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      Text(place.name, style: const TextStyle(fontSize: 16))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.vicinity ?? 'Address not available'),
              const SizedBox(height: 10),
              if (place.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${place.rating}'),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              onPressed: () {
                Navigator.pop(context);
                _navigateToPlace(place);

                if (place.geometry?.location != null) {
                  _getDirections(
                    LatLng(place.geometry!.location.lat,
                        place.geometry!.location.lng),
                    place.name,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToPlace(PlacesSearchResult place) {
    if (place.geometry?.location == null) return;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
              place.geometry!.location.lat, place.geometry!.location.lng),
          zoom: 15,
        ),
      ),
    );
  }

  void _moveCameraToCurrentPosition() {
    if (_currentPosition != null) {
      try {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 14),
          ),
        );
      } catch (e) {
        if (kDebugMode) print("Controller not ready yet: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Locating you..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(-33.86, 151.20),
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              mapController = controller;
              if (_currentPosition != null) {
                _moveCameraToCurrentPosition();
              }
            },
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.school, color: Colors.red[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          ),
          if (!_isRouteActive)
            Positioned(
              bottom: 30,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "location_btn",
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: "refresh_btn",
                    onPressed: _fetchNearbyEducationalInstitutions,
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          if (_isRouteActive)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.directions_car,
                                color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _routeDuration ?? '...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _routeDistance ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearRoute,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
