import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/client/propuestas_screen.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/blocs/client/proposals_bloc.dart';
import 'package:chambea/blocs/client/proposals_event.dart';
import 'package:chambea/blocs/client/proposals_state.dart';
import 'package:chambea/services/fcm_service.dart';
import 'package:chambea/main.dart'; // Import main.dart for AuthUtils

class BandejaScreen extends StatefulWidget {
  const BandejaScreen({super.key});

  @override
  _BandejaScreenState createState() => _BandejaScreenState();
}

class _BandejaScreenState extends State<BandejaScreen> {
  @override
  void initState() {
    super.initState();
    FcmService.initialize(context);
  }

  Future<bool> _onWillPop() async {
    // Use AuthUtils to handle back navigation, ensuring redirection to ClientHomeScreen
    final shouldExit = await AuthUtils.handleBackNavigation(context);
    if (!shouldExit && context.mounted) {
      // Explicitly navigate to ClientHomeScreen if not exiting
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
        (route) => false,
      );
    }
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocProvider(
        create: (context) => ProposalsBloc()..add(FetchServiceRequests()),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Bandeja',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () async {
                  await _onWillPop();
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: const Color(0xFF22c55e),
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  'Lista de propuestas',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<ProposalsBloc, ProposalsState>(
                  builder: (context, state) {
                    if (state is ProposalsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProposalsError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.red,
                          ),
                        ),
                      );
                    } else if (state is ProposalsLoaded) {
                      final requests = List<Map<String, dynamic>>.from(
                        state.serviceRequest['requests'] ?? [],
                      );
                      if (requests.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay propuestas disponibles',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          final proposals = List<Map<String, dynamic>>.from(
                            request['proposals'] ?? [],
                          );
                          final contract =
                              request['contract'] as Map<String, dynamic>?;
                          final workerId = contract != null
                              ? contract['worker_id'] as int?
                              : (proposals.isNotEmpty
                                  ? proposals[0]['worker_id'] as int?
                                  : null);
                          final workerFirebaseUid = contract != null
                              ? contract['worker_firebase_uid'] as String?
                              : (proposals.isNotEmpty
                                  ? proposals[0]['worker_firebase_uid']
                                      as String?
                                  : null);
                          final workerName = contract != null
                              ? contract['worker_name'] as String?
                              : (proposals.isNotEmpty
                                  ? proposals[0]['worker_name'] as String?
                                  : null);
                          return _buildJobCard(
                            context,
                            request['status'] ?? 'Pendiente',
                            '${request['category'] ?? 'Servicio'} - ${request['subcategory'] ?? 'General'}',
                            request['location'] ?? 'Sin ubicación',
                            request['budget'] != null &&
                                    double.tryParse(
                                      request['budget'].toString(),
                                    ) !=
                                        null
                                ? 'BOB: ${request['budget']}'
                                : 'BOB: No especificado',
                            request['is_time_undefined'] == true
                                ? 'Horario flexible'
                                : (request['start_time'] ?? 'Sin horario'),
                            'No especificado',
                            'Usuario ${request['client_name'] ?? request['created_by'] ?? 'Desconocido'}',
                            request['client_rating']?.toDouble() ?? 0.0,
                            request['id'],
                            request['subcategory'] ?? 'General',
                            proposals,
                            workerId,
                            workerFirebaseUid,
                            workerName,
                            state, // Pass the state to check refreshingRequestId
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    String status,
    String title,
    String location,
    String price,
    String time,
    String duration,
    String client,
    double rating,
    int requestId,
    String subcategory,
    List<Map<String, dynamic>> proposals,
    int? workerId,
    String? workerFirebaseUid,
    String? workerName,
    ProposalsState state, // Added to check refreshingRequestId
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isRefreshing = state is ProposalsLoaded && state.refreshingRequestId == requestId;

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Pendiente'
                        ? Colors.yellow.shade100
                        : status == 'En curso'
                        ? Colors.blue.shade100
                        : status == 'Completado'
                        ? Colors.purple.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    border: status == 'accepted' || status == 'Completado'
                        ? Border.all(
                            color: status == 'Completado'
                                ? Colors.purple.shade700
                                : Colors.green.shade700,
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (status == 'accepted' || status == 'Completado')
                        Icon(
                          status == 'Completado'
                              ? Icons.done_all
                              : Icons.check_circle,
                          size: screenWidth * 0.04,
                          color: status == 'Completado'
                              ? Colors.purple.shade800
                              : Colors.green.shade800,
                        ),
                      if (status == 'accepted' || status == 'Completado')
                        SizedBox(width: screenWidth * 0.01),
                      Text(
                        status == 'Pendiente'
                            ? 'Pendiente'
                            : status == 'En curso'
                            ? 'En curso'
                            : status == 'Completado'
                            ? 'Completado'
                            : 'Contratado',
                        style: TextStyle(
                          color: status == 'Pendiente'
                              ? Colors.yellow.shade800
                              : status == 'En curso'
                              ? Colors.blue.shade800
                              : status == 'Completado'
                              ? Colors.purple.shade800
                              : Colors.green.shade800,
                          fontSize: screenWidth * 0.03,
                          fontWeight:
                              status == 'accepted' || status == 'Completado'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    price,
                    style: TextStyle(fontSize: screenWidth * 0.035),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: screenWidth * 0.04, color: Colors.black54),
                SizedBox(width: screenWidth * 0.01),
                Flexible(
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                Icon(Icons.access_time, size: screenWidth * 0.04, color: Colors.black54),
                SizedBox(width: screenWidth * 0.01),
                Flexible(
                  child: Text(
                    '$time ($duration)',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.04,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.white, size: screenWidth * 0.04),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client,
                        style: TextStyle(fontSize: screenWidth * 0.035),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: screenWidth * 0.04,
                            color: Colors.yellow.shade700,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'El precio de $price es mi servicio por hora',
              style: TextStyle(fontSize: screenWidth * 0.035),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22c55e),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.01),
                      ),
                      elevation: 4,
                    ),
                    onPressed: proposals.isEmpty
                        ? null
                        : () {
                            print(
                              'DEBUG: Navigating to PropuestasScreen for requestId: $requestId',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropuestasScreen(
                                  requestId: requestId,
                                  subcategory: subcategory,
                                ),
                              ),
                            );
                          },
                    child: Text(
                      'Propuestas (${proposals.length})',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                isRefreshing
                    ? SizedBox(
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(Icons.refresh,
                            size: screenWidth * 0.06, color: Colors.black54),
                        onPressed: () {
                          print('DEBUG: Refreshing service request ID: $requestId');
                          context.read<ProposalsBloc>().add(RefreshServiceRequest(requestId));
                        },
                        tooltip: 'Refresh Service Request',
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}