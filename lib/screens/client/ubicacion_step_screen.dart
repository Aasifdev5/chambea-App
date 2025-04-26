import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chambea/screens/client/mas_detalles_step_screen.dart';
import 'package:chambea/models/service_request.dart';

class UbicacionStepScreen extends StatefulWidget {
  final ServiceRequest serviceRequest;

  const UbicacionStepScreen({required this.serviceRequest});

  @override
  _UbicacionStepScreenState createState() => _UbicacionStepScreenState();
}

class _UbicacionStepScreenState extends State<UbicacionStepScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController(
    text: 'La Paz',
  );
  final TextEditingController _locationDetailsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('location'),
        position: const LatLng(-12.0464, -77.0428), // Lima, Peru
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    // Pre-fill fields if data exists
    if (widget.serviceRequest.location != null) {
      _locationController.text = widget.serviceRequest.location!;
    }
    if (widget.serviceRequest.locationDetails != null) {
      _locationDetailsController.text = widget.serviceRequest.locationDetails!;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _locationController.dispose();
    _locationDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black54, size: 16),
            const SizedBox(width: 4),
            Text(
              'Av. Benovides 4887',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Ubicación',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '[*] Campo obligatorio',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(Icons.check, isCompleted: true),
                  _buildStepLine(),
                  _buildStepCircle('02', isCompleted: false),
                  _buildStepLine(),
                  _buildStepCircle('03', isCompleted: false),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Paso 1',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Paso 2',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Paso 3',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Dónde necesitas que realice el servicio?*',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-12.0464, -77.0428), // Lima, Peru
                    zoom: 15,
                  ),
                  markers: _markers,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una ubicación';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Add logic to edit location (e.g., open a location picker)
                    },
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationDetailsController,
                decoration: InputDecoration(
                  labelText: 'Especifique la ubicación con más detalle*',
                  hintText:
                      'Número de la casa u oficina, número del piso (en caso de apartamento o edificio), color del portón o ref. etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor especifique los detalles de la ubicación';
                  }
                  return null;
                },
              ),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.serviceRequest.location = _locationController.text;
                      widget.serviceRequest.locationDetails =
                          _locationDetailsController.text;
                      if (widget.serviceRequest.isStep2Complete()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MasDetallesStepScreen(
                                  serviceRequest: widget.serviceRequest,
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor complete todos los campos requeridos',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text(
                    'Siguiente',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(dynamic content, {required bool isCompleted}) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isCompleted ? Colors.green : Colors.grey.shade300,
      child:
          content is IconData
              ? Icon(content, color: Colors.white)
              : Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
