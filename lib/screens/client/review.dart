import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/services/api_service.dart';

class ReviewServiceScreen extends StatefulWidget {
  final int requestId;
  final String workerId;
  final String? workerName;

  const ReviewServiceScreen({
    super.key,
    required this.requestId,
    required this.workerId,
    this.workerName,
  });

  @override
  _ReviewServiceScreenState createState() => _ReviewServiceScreenState();
}

class _ReviewServiceScreenState extends State<ReviewServiceScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  String? _workerName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print(
      'DEBUG: ReviewServiceScreen initState - requestId: ${widget.requestId}, workerId: ${widget.workerId}, workerName: ${widget.workerName}',
    );
    _fetchWorkerName();
  }

  Future<void> _fetchWorkerName() async {
    if (widget.workerName == null || widget.workerName!.isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _workerName = 'Trabajador Desconocido';
          });
          return;
        }
        final response = await ApiService.get('/api/users/${widget.workerId}');
        print('DEBUG: Fetch worker name response: ${response.toString()}');
        if (response['status'] == 'success') {
          setState(() {
            _workerName = response['data']['name'] ?? 'Trabajador Desconocido';
          });
        } else {
          print('DEBUG: Error fetching worker profile: ${response['message']}');
          setState(() {
            _workerName = 'Trabajador Desconocido';
          });
        }
      } catch (e) {
        print('DEBUG: Error fetching worker name: $e');
        setState(() {
          _workerName = 'Trabajador Desconocido';
        });
      }
    } else {
      setState(() {
        _workerName = widget.workerName;
      });
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión')));
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una calificación')),
      );
      return;
    }

    if (widget.requestId == 0 || widget.workerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos del servicio inválidos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        'service_request_id': widget.requestId,
        'worker_id': widget.workerId,
        'client_id': user.uid,
        'rating': _rating,
        'comment': _commentController.text.isEmpty
            ? 'Sin comentario'
            : _commentController.text,
      };
      print('DEBUG: Submitting Review: $payload');
      final response = await ApiService.post('/api/reviews', payload);

      print(
        'DEBUG: Review Response: ${response['statusCode']} - ${response['body']}',
      );
      if (response['statusCode'] == 201 &&
          response['body']['status'] == 'success') {
        context.read<ProposalsBloc>().add(FetchServiceRequests());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reseña enviada con éxito')),
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
            (route) => false,
          );
        }
      } else {
        final error = response['body']['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } catch (e) {
      print('DEBUG: Error submitting review: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.requestId == 0 || widget.workerId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text(
            'Error: Datos del servicio incompletos. Por favor, intenta de nuevo.',
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Servicio Completado',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Califica al trabajador ${_workerName ?? 'Trabajador Desconocido'}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.04,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        _workerName ?? 'Trabajador Desconocido',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow.shade700,
                          size: screenWidth * 0.08,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu comentario aquí...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _rating == 0 || _isLoading
                          ? null
                          : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22c55e),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Enviar Reseña',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
    );
  }
}
