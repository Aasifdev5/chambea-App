import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/chambeador/contratado_screen.dart';
import 'package:chambea/blocs/chambeador/job_detail_bloc.dart';
import 'package:chambea/blocs/chambeador/job_detail_event.dart';
import 'package:chambea/blocs/chambeador/job_detail_state.dart';
import 'package:chambea/blocs/chambeador/proposal_bloc.dart';
import 'package:chambea/blocs/chambeador/proposal_event.dart';
import 'package:chambea/blocs/chambeador/proposal_state.dart';
import 'package:chambea/models/job.dart';

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
          leading: const BackButton(color: Colors.black87),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    style: const TextStyle(color: Colors.red, fontSize: 12),
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
                keyboardType: TextInputType.text,
                onChanged: (val) => setState(() => _budget = val),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Tiempo para cumplir con el trabajo*',
                hint: 'Ejemplo: 2 días o 3 días',
                onChanged: (val) => setState(() => _timeToComplete = val),
              ),
              const SizedBox(height: 24),
              BlocConsumer<ProposalBloc, ProposalState>(
                listener: (context, state) {
                  if (state is ProposalSuccess) {
                    final jobState = context.read<JobDetailBloc>().state;
                    if (jobState is JobDetailLoaded) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContratadoScreen(
                            job: jobState.job,
                            proposedBudget: _budget,
                            availability: _availability,
                            timeToComplete: _timeToComplete,
                            proposalMessage: _proposalDetails,
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        _errorMessage =
                            'No se pudo cargar la información del trabajo';
                      });
                    }
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

  Widget _buildJobCard(Job job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatTimeAgo(job.timeAgo),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job.status,
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: job.categories
                .map((category) => _buildChip(category.toUpperCase()))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                job.isTimeUndefined
                    ? '${job.date ?? 'Hoy'} · Flexible'
                    : '${job.date ?? 'Hoy'} · ${job.startTime ?? 'Sin horario'}',
                style: const TextStyle(color: Colors.black54),
              ),
              const Spacer(),
              Text(
                job.budget != null
                    ? 'BOB ${job.budget!.toStringAsFixed(2)}/Hora'
                    : 'BOB No especificado',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                '${job.location}${job.locationDetails != null ? ', ${job.locationDetails}' : ''}',
                style: const TextStyle(color: Colors.black54),
              ),
              const Spacer(),
              const Icon(Icons.payment, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                job.paymentMethod ?? 'No especificado',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/user.png'),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.clientName ?? 'Usuario Desconocido',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        job.clientRating?.toStringAsFixed(1) ?? '0.0',
                        style: const TextStyle(color: Colors.black54),
                      ),
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
      label: Text(label, style: const TextStyle(fontSize: 12)),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
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

  String _formatTimeAgo(String? timeAgo) {
    if (timeAgo != null && timeAgo.isNotEmpty) {
      return timeAgo;
    }
    return 'Hace un momento';
  }
}
