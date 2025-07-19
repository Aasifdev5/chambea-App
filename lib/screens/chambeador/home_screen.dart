import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';
import 'package:chambea/screens/chambeador/chat_screen.dart';
import 'package:chambea/screens/chambeador/mas_screen.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:chambea/screens/chambeador/job_detail_screen.dart';
import 'package:chambea/screens/chambeador/trabajos.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/blocs/chambeador/jobs_bloc.dart';
import 'package:chambea/blocs/chambeador/jobs_event.dart';
import 'package:chambea/blocs/chambeador/jobs_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    BlocProvider(
      create: (context) => JobsBloc()
        ..add(FetchJobs())
        ..add(FetchWorkerProfile())
        ..add(FetchContractSummary()),
      child: const HomeScreenContent(),
    ),
    const TrabajosContent(),
    BuscarScreen(),
    const ChatScreen(),
    const MasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return _screens[_selectedIndex];
            } catch (e, stackTrace) {
              print(
                'ERROR: Failed to render screen at index $_selectedIndex: $e',
              );
              print(stackTrace);
              return Center(
                child: Text(
                  'Error rendering screen: $e',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF22c55e),
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedFontSize: 10,
        unselectedFontSize: 8,
        iconSize: 22,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Trabajos'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double textScaleFactor = MediaQuery.of(
          context,
        ).textScaler.scale(1.0);
        final double baseFontSize = screenWidth * 0.035;

        return Column(
          children: [
            AppBar(
              title: Text(
                'Inicio',
                style: TextStyle(
                  fontSize:
                      (baseFontSize * 1.4).clamp(16, 20) * textScaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 2,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.swap_horiz,
                    color: Colors.black54,
                    size: (screenWidth * 0.06).clamp(22, 28),
                  ),
                  tooltip: 'Cambiar a modo Cliente',
                  onPressed: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClientHomeScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error navigating to ClientHomeScreen: $e',
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: (screenWidth * 0.06).clamp(22, 28),
                  ),
                  onPressed: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BuscarScreen()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error navigating to BuscarScreen: $e'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF7F7F7), Colors.white],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<JobsBloc, JobsState>(
                          builder: (context, state) {
                            String workerName = 'Usuario';
                            double workerRating = 0.0;
                            double totalBalance = 0.0;
                            int ongoingServices = 0;

                            if (state is JobsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is JobsError) {
                              return Center(
                                child: Text('Error: ${state.message}'),
                              );
                            } else if (state is JobsLoaded) {
                              workerName =
                                  state.workerProfile?['name'] ?? 'Usuario';
                              workerRating =
                                  state.workerProfile?['rating']?.toDouble() ??
                                  0.0;
                              totalBalance =
                                  state.contractSummary?['total_balance']
                                      ?.toDouble() ??
                                  0.0;
                              ongoingServices =
                                  state.contractSummary?['ongoing_services'] ??
                                  0;
                            }

                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: EdgeInsets.all(
                                  screenWidth < 360
                                      ? screenWidth * 0.03
                                      : screenWidth * 0.04,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.04,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '¡Ofrece tu servicio hoy mismo!',
                                            style: TextStyle(
                                              fontSize: screenWidth < 360
                                                  ? (baseFontSize * 1.1).clamp(
                                                          12,
                                                          16,
                                                        ) *
                                                        textScaleFactor
                                                  : (baseFontSize * 1.2).clamp(
                                                          14,
                                                          18,
                                                        ) *
                                                        textScaleFactor,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.015,
                                          ),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: (screenWidth * 0.045)
                                                    .clamp(12, 16),
                                                backgroundColor:
                                                    Colors.grey.shade400,
                                                child: Icon(
                                                  Icons.person,
                                                  size: (screenWidth * 0.035)
                                                      .clamp(10, 14),
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.02,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    workerName,
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 1.0)
                                                              .clamp(10, 14) *
                                                          textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size:
                                                            (screenWidth *
                                                                    0.035)
                                                                .clamp(10, 14),
                                                        color: Colors
                                                            .yellow
                                                            .shade700,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            screenWidth * 0.01,
                                                      ),
                                                      Text(
                                                        workerRating
                                                            .toStringAsFixed(1),
                                                        style: TextStyle(
                                                          fontSize:
                                                              (baseFontSize *
                                                                      0.8)
                                                                  .clamp(
                                                                    10,
                                                                    12,
                                                                  ) *
                                                              textScaleFactor,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.015,
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'BOB: ${totalBalance.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 1.0)
                                                              .clamp(10, 14) *
                                                          textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Saldo Actual',
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 0.7)
                                                              .clamp(8, 10) *
                                                          textScaleFactor,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.04,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$ongoingServices',
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 1.0)
                                                              .clamp(10, 14) *
                                                          textScaleFactor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Servicios en curso',
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 0.7)
                                                              .clamp(8, 10) *
                                                          textScaleFactor,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Ver más'),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Ver más',
                                        style: TextStyle(
                                          color: const Color(0xFF22c55e),
                                          fontSize:
                                              (baseFontSize * 0.8).clamp(
                                                10,
                                                12,
                                              ) *
                                              textScaleFactor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Trabajos recomendados para ti',
                          style: TextStyle(
                            fontSize:
                                (baseFontSize * 1.1).clamp(12, 16) *
                                textScaleFactor,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        BlocBuilder<JobsBloc, JobsState>(
                          builder: (context, state) {
                            if (state is JobsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is JobsError) {
                              return Center(
                                child: Text('Error: ${state.message}'),
                              );
                            } else if (state is JobsLoaded) {
                              if (state.jobs.isEmpty) {
                                return const Center(
                                  child: Text('No hay trabajos disponibles'),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.jobs.length,
                                itemBuilder: (context, index) {
                                  final job = state.jobs[index];
                                  return _buildJobCard(
                                    context: context,
                                    requestId:
                                        job['id'] as int?, // Handle null ID
                                    timeAgo: _formatTimeAgo(
                                      job['created_at'] ??
                                          DateTime.now().toIso8601String(),
                                    ),
                                    title:
                                        '${job['category'] ?? 'Servicio'} - ${job['subcategory'] ?? 'General'}',
                                    budget:
                                        job['budget'] != null &&
                                            double.tryParse(
                                                  job['budget'].toString(),
                                                ) !=
                                                null
                                        ? 'BOB: ${job['budget']}/Hora'
                                        : 'BOB: No especificado',
                                    location:
                                        '${job['location'] ?? 'Sin ubicación'}, ${job['location_details'] ?? ''}',
                                    clientName:
                                        job['client_name'] ??
                                        'Usuario ${job['created_by'] ?? 'Desconocido'}',
                                    clientId:
                                        job['created_by']?.toString() ??
                                        'Desconocido',
                                    clientRating:
                                        job['client_rating']?.toDouble() ?? 0.0,
                                    tags: [
                                      job['category']?.toUpperCase() ??
                                          'SERVICIO',
                                      job['subcategory']?.toUpperCase() ??
                                          'GENERAL',
                                    ],
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    textScaleFactor: textScaleFactor,
                                    baseFontSize: baseFontSize,
                                  );
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Clientes Recomendados',
                              style: TextStyle(
                                fontSize:
                                    (baseFontSize * 1.1).clamp(12, 16) *
                                    textScaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ver más clientes'),
                                  ),
                                );
                              },
                              child: Text(
                                'Ver más',
                                style: TextStyle(
                                  color: const Color(0xFF22c55e),
                                  fontSize:
                                      (baseFontSize * 0.8).clamp(10, 12) *
                                      textScaleFactor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SizedBox(
                          height: screenHeight * 0.18,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildClientCard(
                                  context: context,
                                  name: 'Rosa Elena Pérez',
                                  rating: 4.1,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  textScaleFactor: textScaleFactor,
                                  baseFontSize: baseFontSize,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                _buildClientCard(
                                  context: context,
                                  name: 'Julio César Suarez',
                                  rating: 4.1,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  textScaleFactor: textScaleFactor,
                                  baseFontSize: baseFontSize,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                _buildClientCard(
                                  context: context,
                                  name: 'Pedro Castillo',
                                  rating: 4.1,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  textScaleFactor: textScaleFactor,
                                  baseFontSize: baseFontSize,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Últimos comentarios',
                              style: TextStyle(
                                fontSize:
                                    (baseFontSize * 1.1).clamp(12, 16) *
                                    textScaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ver todos los comentarios'),
                                  ),
                                );
                              },
                              child: Text(
                                'Ver todos',
                                style: TextStyle(
                                  color: const Color(0xFF22c55e),
                                  fontSize:
                                      (baseFontSize * 0.8).clamp(10, 12) *
                                      textScaleFactor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildReviewCard(
                          context: context,
                          client: 'Julio Sequeira',
                          rating: 4,
                          timeAgo: 'Hace 2 horas',
                          comment:
                              'Andrés realizó un excelente trabajo instalando el sistema de iluminación de mi casa. Fue puntual, muy profesional y todo funcionó perfectamente. ¡Muy recomendable!',
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          textScaleFactor: textScaleFactor,
                          baseFontSize: baseFontSize,
                        ),
                        _buildReviewCard(
                          context: context,
                          client: 'Julio Sequeira',
                          rating: 4,
                          timeAgo: 'Hace 2 horas',
                          comment:
                              'Andrés realizó un excelente trabajo instalando el sistema de iluminación de mi casa. Fue puntual, muy profesional y todo funcionó perfectamente. ¡Muy recomendable!',
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          textScaleFactor: textScaleFactor,
                          baseFontSize: baseFontSize,
                        ),
                        _buildReviewCard(
                          context: context,
                          client: 'Julio Sequeira',
                          rating: 4,
                          timeAgo: 'Hace 2 horas',
                          comment:
                              'Andrés realizó un excelente trabajo instalando el sistema de iluminación de mi casa. Fue puntual, muy profesional y todo funcionó perfectamente. ¡Muy recomendable!',
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          textScaleFactor: textScaleFactor,
                          baseFontSize: baseFontSize,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required int? requestId, // Nullable to handle invalid IDs
    required String timeAgo,
    required String title,
    required String budget,
    required String location,
    required String clientName,
    required String clientId,
    required double clientRating,
    required List<String> tags,
    required double screenWidth,
    required double screenHeight,
    required double textScaleFactor,
    required double baseFontSize,
  }) {
    print(
      'DEBUG: Job ID: $requestId, Client Name: $clientName, Client ID: $clientId, Location: $location',
    );
    return GestureDetector(
      onTap: () {
        if (requestId == null) {
          print(
            'ERROR: Attempted to navigate to JobDetailScreen with null requestId',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Invalid job ID')),
          );
          return;
        }
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailScreen(requestId: requestId),
            ),
          );
        } catch (e) {
          print(
            'ERROR: Failed to navigate to JobDetailScreen for requestId: $requestId, Error: $e',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error navigating to job details: $e')),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: (screenHeight * 0.2).clamp(120, 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.03),
                ),
                color: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize:
                              (baseFontSize * 0.7).clamp(8, 10) *
                              textScaleFactor,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        budget,
                        style: TextStyle(
                          fontSize:
                              (baseFontSize * 1.0).clamp(10, 14) *
                              textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          (baseFontSize * 1.2).clamp(12, 16) * textScaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    children: tags
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                fontSize:
                                    (baseFontSize * 0.7).clamp(8, 10) *
                                    textScaleFactor,
                              ),
                            ),
                            backgroundColor: Colors.grey.shade200,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: (screenWidth * 0.035).clamp(10, 14),
                        color: Colors.black54,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Flexible(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize:
                                (baseFontSize * 0.8).clamp(10, 12) *
                                textScaleFactor,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: (screenWidth * 0.045).clamp(12, 16),
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: (screenWidth * 0.035).clamp(10, 14),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              style: TextStyle(
                                fontSize:
                                    (baseFontSize * 1.0).clamp(10, 14) *
                                    textScaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: (screenWidth * 0.035).clamp(10, 14),
                                  color: Colors.yellow,
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  clientRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize:
                                        (baseFontSize * 0.8).clamp(10, 12) *
                                        textScaleFactor,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard({
    required BuildContext context,
    required String name,
    required double rating,
    required double screenWidth,
    required double screenHeight,
    required double textScaleFactor,
    required double baseFontSize,
  }) {
    print(
      'DEBUG: Building client card for name: $name, width: ${(screenWidth * 0.22).clamp(90.0, 110.0)}',
    );
    return SizedBox(
      width: (screenWidth * 0.22).clamp(90.0, 110.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: (screenWidth * 0.07).clamp(22, 32),
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: (screenWidth * 0.05).clamp(18, 26),
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: (baseFontSize * 1.0).clamp(10, 14) * textScaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: (screenWidth * 0.035).clamp(10, 14),
                color: Colors.yellow,
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize:
                      (baseFontSize * 0.8).clamp(10, 12) * textScaleFactor,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String client,
    required double rating,
    required String timeAgo,
    required String comment,
    required double screenWidth,
    required double screenHeight,
    required double textScaleFactor,
    required double baseFontSize,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: (screenWidth * 0.045).clamp(12, 16),
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: (screenWidth * 0.035).clamp(10, 14),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client,
                        style: TextStyle(
                          fontSize:
                              (baseFontSize * 1.0).clamp(10, 14) *
                              textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: (screenWidth * 0.035).clamp(10, 14),
                            color: Colors.yellow,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize:
                                  (baseFontSize * 0.8).clamp(10, 12) *
                                  textScaleFactor,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize:
                        (baseFontSize * 0.7).clamp(8, 10) * textScaleFactor,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              comment,
              style: TextStyle(
                fontSize: (baseFontSize * 0.8).clamp(10, 12) * textScaleFactor,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(String createdAt) {
    try {
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
    } catch (e) {
      print('ERROR: Failed to parse createdAt: $createdAt, Error: $e');
      return 'Hace desconocido';
    }
  }
}
