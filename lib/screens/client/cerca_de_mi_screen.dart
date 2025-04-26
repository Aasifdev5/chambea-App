import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CercaDeMiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cerca de mí'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-12.0464, -77.0428), // Lima, Peru
          zoom: 12,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('current'),
            position: LatLng(-12.0464, -77.0428),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
          const Marker(
            markerId: MarkerId('rosa'),
            position: LatLng(-12.0450, -77.0410),
            icon: BitmapDescriptor.defaultMarker,
          ),
          const Marker(
            markerId: MarkerId('julio'),
            position: LatLng(-12.0470, -77.0430),
            icon: BitmapDescriptor.defaultMarker,
          ),
          const Marker(
            markerId: MarkerId('pedro'),
            position: LatLng(-12.0480, -77.0400),
            icon: BitmapDescriptor.defaultMarker,
          ),
          const Marker(
            markerId: MarkerId('andres'),
            position: LatLng(-12.0440, -77.0420),
            icon: BitmapDescriptor.defaultMarker,
          ),
        },
      ),
    );
  }
}