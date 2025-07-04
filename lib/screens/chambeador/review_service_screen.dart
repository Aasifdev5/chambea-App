import 'package:flutter/material.dart';
import 'package:chambea/models/job.dart';
import 'package:chambea/screens/chambeador/trabajos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewServiceScreen extends StatefulWidget {
  final Job job;

  const ReviewServiceScreen({super.key, required this.job});

  @override
  _ReviewServiceScreenState createState() => _ReviewServiceScreenState();
}

class _ReviewServiceScreenState extends State<ReviewServiceScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  String? _clientName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Debug job data
    print(
      'Job Data: ID=${widget.job.id}, WorkerID=${widget.job.workerId}, ClientID=${widget.job.clientId}',
    );
    _fetchClientName();
  }

  Future<void> _fetchClientName() async {
    if (widget.job.clientName == null ||
        widget.job.clientName == 'Usuario Desconocido') {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _clientName = 'Usuario Desconocido';
          });
          return;
        }
        final token = await user.getIdToken();
        final response = await http.get(
          Uri.parse('https://chambea.lat/api/users/${widget.job.clientId}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          setState(() {
            _clientName = data['name'] ?? 'Usuario Desconocido';
          });
        } else {
          print('Error fetching client profile: ${response.body}');
          setState(() {
            _clientName = 'Usuario Desconocido';
          });
        }
      } catch (e) {
        print('Error fetching client name: $e');
        setState(() {
          _clientName = 'Usuario Desconocido';
        });
      }
    } else {
      setState(() {
        _clientName = widget.job.clientName;
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

    if (widget.job.id == 0 || widget.job.workerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos del trabajo inválidos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await user.getIdToken();
      final payload = {
        'service_request_id': widget.job.id,
        'worker_id': widget.job.workerId,
        'rating': _rating,
        'comment': _commentController.text.isEmpty
            ? 'No comment provided'
            : _commentController.text,
      };
      print('Submitting Review: $payload');
      final response = await http.post(
        Uri.parse('https://chambea.lat/api/reviews'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      print('Review Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reseña enviada con éxito')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrabajosContent()),
        );
      } else {
        final error =
            json.decode(response.body)['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Califica al cliente ${_clientName ?? 'Usuario Desconocido'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _clientName ?? 'Usuario Desconocido',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
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
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _rating == 0 || _isLoading
                          ? null
                          : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Enviar Reseña',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
