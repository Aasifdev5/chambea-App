import 'package:flutter/material.dart';
import 'package:chambea/screens/client/chat_detail_screen.dart';
import 'package:chambea/services/api_service.dart';

class ContractConfirmationScreen extends StatefulWidget {
  final int requestId;
  final String? workerId;
  final String? workerName;
  final String? workerRole;
  final double? workerRating;
  final String? date;
  final String? location;
  final String? paymentMethod;
  final String? budget;

  const ContractConfirmationScreen({
    required this.requestId,
    this.workerId,
    this.workerName,
    this.workerRole,
    this.workerRating,
    this.date,
    this.location,
    this.paymentMethod,
    this.budget,
    super.key,
  });

  @override
  _ContractConfirmationScreenState createState() =>
      _ContractConfirmationScreenState();
}

class _ContractConfirmationScreenState
    extends State<ContractConfirmationScreen> {
  Map<String, dynamic>? _serviceRequest;
  String? _workerName;
  String? _workerRole;
  double? _workerRating;
  String? _workerFirebaseUid;
  String? _date;
  String? _location;
  String? _paymentMethod;
  String? _budget;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServiceRequest();
  }

  Future<void> _fetchServiceRequest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print(
        'DEBUG: Fetching service request for requestId: ${widget.requestId}',
      );
      final response = await ApiService.get(
        '/api/service-requests/${widget.requestId}',
      );
      print('DEBUG: Service request response: $response');
      final data = Map<String, dynamic>.from(response['data'] ?? {});
      String workerName = widget.workerName ?? 'Usuario Desconocido';
      String workerRole =
          widget.workerRole ?? data['subcategory'] ?? 'Trabajador';
      double workerRating = widget.workerRating ?? 0.0;
      String? workerFirebaseUid = widget.workerId;
      String date = widget.date ?? data['date'] ?? 'No especificada';
      String location =
          widget.location ??
          '${data['location'] ?? 'Sin ubicación'}, ${data['location_details'] ?? ''}';
      String paymentMethod =
          widget.paymentMethod ??
          (data['payment_method'] == 'Código QR'
              ? 'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.'
              : 'El pago puede realizar con efectivo después de finalizar el servicio.');
      String budget =
          widget.budget ??
          (data['budget'] != null &&
                  double.tryParse(data['budget'].toString()) != null
              ? 'BOB ${data['budget']}'
              : 'BOB No especificado');

      // Attempt to resolve workerFirebaseUid if not provided
      if (workerFirebaseUid == null && data['worker_id'] != null) {
        try {
          print(
            'DEBUG: Attempting to map worker_id: ${data['worker_id']} to Firebase UID',
          );
          final uidResponse = await ApiService.get(
            '/api/users/map-id-to-uid/${data['worker_id']}',
          );
          workerFirebaseUid = uidResponse['data']['uid'];
          print(
            'DEBUG: Mapped worker_id ${data['worker_id']} to UID: $workerFirebaseUid',
          );
        } catch (e) {
          print('DEBUG: Error mapping worker_id to UID: $e');
        }
      }

      // Fetch worker details if workerFirebaseUid is available
      if (workerFirebaseUid != null) {
        try {
          print('DEBUG: Fetching user profile for UID: $workerFirebaseUid');
          final userResponse = await ApiService.get(
            '/api/users/$workerFirebaseUid',
          );
          print('DEBUG: User profile response: $userResponse');
          if (userResponse['status'] == 'success') {
            final userData = userResponse['data'] ?? {};
            workerName = userData['name'] ?? 'Usuario $workerFirebaseUid';
            workerRole = userData['account_type'] == 'Chambeador'
                ? data['subcategory'] ?? 'Trabajador'
                : 'Trabajador';
            workerRating = userData['rating']?.toDouble() ?? 0.0;
          } else {
            print('DEBUG: User API returned error: ${userResponse['message']}');
          }
        } catch (e) {
          print('DEBUG: Error fetching worker profile: $e');
        }
      }

      setState(() {
        _serviceRequest = data;
        _workerName = workerName;
        _workerRole = workerRole;
        _workerRating = workerRating;
        _workerFirebaseUid = workerFirebaseUid;
        _date = date;
        _location = location;
        _paymentMethod = paymentMethod;
        _budget = budget;
        _isLoading = false;
      });

      print(
        'DEBUG: Updated state - workerFirebaseUid: $_workerFirebaseUid, status: ${_serviceRequest?['status']}',
      );
    } catch (e) {
      print('DEBUG: Error fetching service request: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Agendar",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(
                color: Colors.green,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    // Success Icon
                    CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.check,
                        size: screenWidth * 0.12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Title
                    Text(
                      "Contratado",
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    // Subtitle
                    Text(
                      "Gracias por elegir nuestro servicio y confiar en nuestro trabajador para ayudarte a realizar su trabajo.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth * 0.035,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Worker Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: screenWidth * 0.06,
                                backgroundColor: Colors.grey.shade300,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: screenWidth * 0.06,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _workerName ?? 'Cargando...',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: screenWidth * 0.04,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          (_workerRating ?? 0.0)
                                              .toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Date
                          Text(
                            "Fecha",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: screenWidth * 0.032,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            _date ?? 'No especificada',
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Location
                          Text(
                            "Ubicación",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: screenWidth * 0.032,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            _location ?? 'Sin ubicación',
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Payment Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _paymentMethod ??
                            'El pago puede realizar con efectivo después de finalizar el servicio.',
                        style: TextStyle(fontSize: screenWidth * 0.035),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Chat Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _workerFirebaseUid != null &&
                                  [
                                    'accepted',
                                    'En curso',
                                    'Completado',
                                  ].contains(_serviceRequest?['status'])
                              ? Colors.green
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: Size(
                            double.infinity,
                            screenHeight * 0.07,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.03,
                            ),
                          ),
                          elevation: 8,
                        ),
                        onPressed:
                            _workerFirebaseUid != null &&
                                [
                                  'accepted',
                                  'En curso',
                                  'Completado',
                                ].contains(_serviceRequest?['status'])
                            ? () {
                                print(
                                  'DEBUG: Chat button pressed, navigating to ChatDetailScreen with workerId: $_workerFirebaseUid, requestId: ${widget.requestId}',
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailScreen(
                                      workerId: _workerFirebaseUid!,
                                      requestId: widget.requestId,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                          _workerFirebaseUid != null &&
                                  [
                                    'accepted',
                                    'En curso',
                                    'Completado',
                                  ].contains(_serviceRequest?['status'])
                              ? 'Chatea con el chambeador'
                              : 'Seleccione un trabajador para chatear',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
    );
  }
}
