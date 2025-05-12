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
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-12.0464, -77.0428), // Lima, Peru
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('current'),
            position: const LatLng(-12.0464, -77.0428),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
          Marker(
            markerId: const MarkerId('rosa'),
            position: const LatLng(-12.0450, -77.0410),
            icon: BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('julio'),
            position: const LatLng(-12.0470, -77.0430),
            icon: BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('pedro'),
            position: const LatLng(-12.0480, -77.0400),
            icon: BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('andres'),
            position: const LatLng(-12.0440, -77.0420),
            icon: BitmapDescriptor.defaultMarker,
          ),
        },
      ),
    );
  }
}
