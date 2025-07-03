import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/chambeador/contratado_screen.dart';
import 'package:chambea/blocs/chambeador/job_detail_bloc.dart';
import 'package:chambea/blocs/chambeador/job_detail_event.dart';
import 'package:chambea/blocs/chambeador/job_detail_state.dart';
import 'package:chambea/blocs/chambeador/proposal_bloc.dart';
import 'package:chambea/blocs/chambeador/proposal_event.dart';
import 'package:chambea/blocs/chambeador/proposal_state.dart';

class PropuestaScreen extends StatefulWidget {
  final int requestId;

  const PropuestaScreen({required this.requestId, Key? key}) : super(key: key);

  @override
  _PropuestaScreenState createState() => _PropuestaScreenState();
}

class _PropuestaScreenState extends State<PropuestaScreen> {
  final _availabilityOptions = ['Inmediato', '1 día', '2 días'];
  String _availability = 'Inmediato';
  String _proposalDetails = '';
  String _budget = '';
  String _timeToComplete = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              JobDetailBloc()..add(FetchJobDetail(widget.requestId)),
        ),
        BlocProvider(create: (context) => ProposalBloc()),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: Colors.black87),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Propuesta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '(*) Campo obligatorio',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 16),
              BlocBuilder<JobDetailBloc, JobDetailState>(
                builder: (context, state) {
                  if (state is JobDetailLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is JobDetailError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is JobDetailLoaded) {
                    return _buildJobCard(state.job);
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              _buildDropdownField(
                'Disponibilidad para empezar*',
                _availabilityOptions,
                _availability,
                (value) {
                  setState(() => _availability = value!);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Detalle de la propuesta*',
                hint: 'El precio de 80 BOB es mi servicio por hora',
                maxLength: 50,
                onChanged: (val) => setState(() => _proposalDetails = val),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Presupuesto*',
                hint: 'Introducir el presupuesto',
                keyboardType:
                    TextInputType.text, // Changed to text to match API
                onChanged: (val) => setState(() => _budget = val),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Tiempo para cumplir con el trabajo',
                hint: 'Ejemplo: 2 días o 3 días',
                onChanged: (val) => setState(() => _timeToComplete = val),
              ),
              const SizedBox(height: 24),
              BlocConsumer<ProposalBloc, ProposalState>(
                listener: (context, state) {
                  if (state is ProposalSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ContratadoScreen()),
                    );
                  } else if (state is ProposalError) {
                    setState(() {
                      _errorMessage = state.message;
                    });
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: state is ProposalSubmitting
                        ? null
                        : () {
                            if (_budget.isEmpty ||
                                _proposalDetails.isEmpty ||
                                _timeToComplete.isEmpty) {
                              setState(() {
                                _errorMessage =
                                    'Por favor completa todos los campos obligatorios';
                              });
                              return;
                            }
                            context.read<ProposalBloc>().add(
                              SubmitProposal(
                                serviceRequestId: widget.requestId,
                                proposedBudget: _budget,
                                message: _proposalDetails,
                                availability: _availability,
                                timeToComplete: _timeToComplete,
                              ),
                            );
                          },
                    child: state is ProposalSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Enviar Propuesta',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatTimeAgo(job['created_at']),
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Consultar',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${job['category'] ?? 'Servicio'} - ${job['subcategory'] ?? 'General'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildChip(job['category']?.toUpperCase() ?? 'SERVICIO'),
              _buildChip(job['subcategory']?.toUpperCase() ?? 'GENERAL'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              SizedBox(width: 4),
              Text(
                job['is_time_undefined'] == 1
                    ? '${job['date'] ?? 'Hoy'} · Flexible'
                    : '${job['date'] ?? 'Hoy'} · ${job['start_time'] ?? 'Sin horario'}',
                style: TextStyle(color: Colors.black54),
              ),
              Spacer(),
              Text(
                job['budget'] != null &&
                        double.tryParse(job['budget'].toString()) != null
                    ? 'BOB: ${job['budget']}/Hora'
                    : 'BOB: No especificado',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.black54),
              SizedBox(width: 4),
              Text(
                '${job['location'] ?? 'Sin ubicación'}, ${job['location_details'] ?? ''}',
                style: TextStyle(color: Colors.black54),
              ),
              Spacer(),
              Icon(Icons.payment, size: 16, color: Colors.black54),
              SizedBox(width: 4),
              Text(
                job['payment_method'] ?? 'No especificado',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  'assets/user.png',
                ), // Replace with user API image
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuario ${job['created_by'] ?? 'Desconocido'}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '0.0',
                        style: TextStyle(color: Colors.black54),
                      ), // Replace with user API rating
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          maxLength: maxLength,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Hace un momento';
    final now = DateTime.now();
    final created = DateTime.parse(createdAt);
    final difference = now.difference(created);
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    }
  }
}
