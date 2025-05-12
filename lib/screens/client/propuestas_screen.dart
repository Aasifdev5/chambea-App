import 'package:flutter/material.dart';
import 'package:chambea/screens/client/contratado_screen.dart';
import 'package:chambea/screens/client/agenda.dart';

// Simple model for a proposal
class Proposal {
  final String status;
  final String workerName;
  final double rating;
  final String serviceTitle;
  final String location;
  final String duration;
  final String timeRange;
  final String price;
  final String comment;

  Proposal({
    required this.status,
    required this.workerName,
    required this.rating,
    required this.serviceTitle,
    required this.location,
    required this.duration,
    required this.timeRange,
    required this.price,
    required this.comment,
  });
}

class PropuestasScreen extends StatefulWidget {
  final String subcategoryName; // Added subcategoryName

  const PropuestasScreen({super.key, required this.subcategoryName});

  @override
  State<PropuestasScreen> createState() => _PropuestasScreenState();
}

class _PropuestasScreenState extends State<PropuestasScreen> {
  // Sample list of proposals
  final List<Proposal> _proposals = [
    Proposal(
      status: 'Pendiente',
      workerName: 'Andrés Villamontes',
      rating: 4.1,
      serviceTitle: 'Instalaciones de luces LED',
      location: 'Ave Bush - La Paz',
      duration: '3 días',
      timeRange: '8:00 AM - 12:00 PM',
      price: 'BOB: 80',
      comment: 'El precio de 80 BOB es mi servicio por hora',
    ),
    Proposal(
      status: 'Pendiente',
      workerName: 'María Gómez',
      rating: 4.5,
      serviceTitle: 'Reparación de enchufes',
      location: 'Calle 21 - La Paz',
      duration: '2 días',
      timeRange: '9:00 AM - 1:00 PM',
      price: 'BOB: 90',
      comment: 'Incluye materiales básicos',
    ),
    Proposal(
      status: 'En revisión',
      workerName: 'Carlos Pérez',
      rating: 4.3,
      serviceTitle: 'Mantenimiento eléctrico general',
      location: 'Av. Arce - La Paz',
      duration: '4 días',
      timeRange: '10:00 AM - 2:00 PM',
      price: 'BOB: 120',
      comment: 'Disponible para ajustes adicionales',
    ),
    Proposal(
      status: 'Pendiente',
      workerName: 'Lucía Rodríguez',
      rating: 4.8,
      serviceTitle: 'Instalación de sistema de iluminación',
      location: 'Zona Sur - La Paz',
      duration: '5 días',
      timeRange: '7:00 AM - 11:00 AM',
      price: 'BOB: 150',
      comment: 'Garantía de 30 días incluida',
    ),
    Proposal(
      status: 'Pendiente',
      workerName: 'Juan Morales',
      rating: 4.0,
      serviceTitle: 'Revisión de cableado',
      location: 'Miraflores - La Paz',
      duration: '1 día',
      timeRange: '2:00 PM - 5:00 PM',
      price: 'BOB: 60',
      comment: 'Revisión rápida y eficiente',
    ),
  ];

  void _rejectProposal(int index) {
    setState(() {
      _proposals.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Propuesta rechazada')));
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
        title: Text(
          'Propuestas - ${widget.subcategoryName}', // Use subcategoryName in title
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
      body:
          _proposals.isEmpty
              ? const Center(
                child: Text(
                  'No hay propuestas disponibles',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _proposals.length,
                itemBuilder: (context, index) {
                  final proposal = _proposals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      proposal.status == 'Pendiente'
                                          ? Colors.yellow.shade100
                                          : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  proposal.status,
                                  style: TextStyle(
                                    color:
                                        proposal.status == 'Pendiente'
                                            ? Colors.yellow.shade800
                                            : Colors.green.shade800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                proposal.price,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            proposal.serviceTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                proposal.location,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${proposal.timeRange} (${proposal.duration})',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proposal.workerName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.yellow.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        proposal.rating.toString(),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            proposal.comment,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.green),
                                    foregroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    _rejectProposal(index);
                                  },
                                  child: const Text(
                                    'Rechazar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AgendaScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Agendar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
