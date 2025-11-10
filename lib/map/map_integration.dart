import 'package:flutter/material.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';

class MapSampleScreen extends StatefulWidget {
  const MapSampleScreen({super.key});

  @override
  State<MapSampleScreen> createState() => _MapSampleScreenState();
}

class _MapSampleScreenState extends State<MapSampleScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FlutterMap(),
    );
  }
}
