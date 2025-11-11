import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class FlutterMap extends StatefulWidget {
  const FlutterMap({super.key});

  @override
  State<FlutterMap> createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMap> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _placesLoaded = false;
  late GoogleMapsPlaces _places;

  @override
  void initState() {
    super.initState();
    _initializePlaces();
    _getCurrentLocation();
  }

  void _initializePlaces() {
    final apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        print("Maps API Key not found in env file");
      }
    }
    _places = GoogleMapsPlaces(apiKey: apiKey);
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print("Location permission denied");
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Fetch nearby educational institutions
      await _fetchNearbyEducationalInstitutions();

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(
              title: 'Your Current Location',
              snippet: 'You are here',
            ),
          ),
        );
      });
    }
  }

  Future<void> _fetchNearbyEducationalInstitutions() async {
    if (_currentPosition == null) return;

    try {
      final location = Location(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );

      final response = await _places.searchNearbyWithRadius(
        location,
        5000, // 5km radius
        type: 'school',
        keyword: 'school university college education',
      );

      if (response.status == "OK") {
        if (kDebugMode) {
          print("Found ${response.results.length} educational institutions");
        }

        for (final place in response.results) {
          _addEducationalMarker(place);
        }

        setState(() {
          _placesLoaded = true;
        });
      } else {
        if (kDebugMode) {
          print("Places API error: ${response.errorMessage}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching places: $e");
      }
    }
  }

  void _addEducationalMarker(PlacesSearchResult place) {
    // Skip if no geometry or location
    if (place.geometry?.location == null) return;

    final marker = Marker(
      markerId: MarkerId(place.placeId),
      position: LatLng(
        place.geometry!.location.lat,
        place.geometry!.location.lng,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.vicinity ?? 'Educational Institution',
      ),
      onTap: () {
        _showPlaceDetails(place);
      },
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
              const Icon(Icons.school, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.vicinity != null) ...[
                  Text('Address: ${place.vicinity!}'),
                  const SizedBox(height: 8),
                ],
                Text('Latitude: ${place.geometry!.location.lat.toStringAsFixed(6)}'),
                Text('Longitude: ${place.geometry!.location.lng.toStringAsFixed(6)}'),
                const SizedBox(height: 8),
                if (place.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('Rating: ${place.rating!.toStringAsFixed(1)}'),
                    ],
                  ),
                if (place.types != null && place.types!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${place.types!.join(', ').replaceAll('_', ' ')}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _navigateToPlace(place);
                Navigator.of(context).pop();
              },
              child: const Text('View on Map'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPlace(PlacesSearchResult place) {
    if (place.geometry?.location == null) return;

    final position = LatLng(
      place.geometry!.location.lat,
      place.geometry!.location.lng,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16,
        ),
      ),
    );
  }

  void _moveCameraToCurrentPosition() {
    if (mapController != null && _currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 14,
          ),
        ),
      );
    }
  }

  Future<void> _refreshPlaces() async {
    setState(() {
      _isLoading = true;
      _placesLoaded = false;
      // Remove only educational institution markers, keep current location
      _markers.removeWhere((marker) => marker.markerId.value != 'current_location');
    });

    await _fetchNearbyEducationalInstitutions();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading map and educational institutions...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition ?? const LatLng(-33.865143, 151.209900),
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            if (kDebugMode) {
              print("Map controller set");
            }
            mapController = controller;
            _moveCameraToCurrentPosition();
          },
        ),

        // Refresh button
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton(
            onPressed: _refreshPlaces,
            mini: true,
            tooltip: 'Refresh educational institutions',
            child: const Icon(Icons.refresh),
          ),
        ),

        // Info panel
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_pin, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Educational Institutions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (!_placesLoaded) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Loading institutions...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Results count
        if (_placesLoaded && _markers.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_markers.length - 1} institutions found',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}