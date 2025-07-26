import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chambea/services/api_service.dart';
import 'package:retry/retry.dart';
import 'package:flutter/foundation.dart';

class CercaDeMiScreen extends StatefulWidget {
  @override
  _CercaDeMiScreenState createState() => _CercaDeMiScreenState();
}

class _CercaDeMiScreenState extends State<CercaDeMiScreen> {
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;

  // Bolivia default
  static const LatLng boliviaCenter = LatLng(-16.2902, -63.5887);

  @override
  void initState() {
    super.initState();
    _loadChambeadores();
  }

  Future<void> _loadChambeadores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await retry(
        () => ApiService.get('/api/chambeadores/nearby'),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
      );

      if (response['status'] != 'success' || response['data'] == null) {
        throw Exception(response['message'] ?? 'Failed to load chambeadores');
      }

      final List<dynamic> profiles = response['data'];
      final markers = <Marker>{};

      for (final profile in profiles) {
        if (profile['lat'] == null || profile['lng'] == null) {
          continue;
        }

        final uid = profile['uid'] as String;
        final lat = double.parse(profile['lat'].toString());
        final lng = double.parse(profile['lng'].toString());
        final name = (profile['name'] ?? 'Anon') as String;

        final markerIcon = await generateMarkerIconWithName(name);

        markers.add(
          Marker(
            markerId: MarkerId(uid),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow.noText,
          ),
        );
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading chambeadores: $e';
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _CercaDeMiScreenState.boliviaCenter, // Bolivia default
                zoom: 6.5, // Suitable for country view
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
    );
  }
}

Future<Uint8List> generateMarkerIconWithName(String name) async {
  const double markerWidth = 200;
  const double markerHeight = 80;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final Paint paint = Paint()..color = Colors.transparent;
  final RRect rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, markerWidth, markerHeight),
    Radius.circular(12),
  );
  canvas.drawRRect(rrect, paint);

  final icon = Icons.location_on;
  final textPainterIcon = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: icon.fontFamily,
        color: Colors.red,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainterIcon.layout();
  textPainterIcon.paint(canvas, Offset(16, (markerHeight - 48) / 2));

  final textPainter = TextPainter(
    text: TextSpan(
      text: name.length > 14 ? '${name.substring(0, 12)}…' : name,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: markerWidth - 64);
  textPainter.paint(
    canvas,
    Offset(64, (markerHeight - textPainter.height) / 2),
  );

  final ui.Image image = await recorder.endRecording().toImage(
    markerWidth.toInt(),
    markerHeight.toInt(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
