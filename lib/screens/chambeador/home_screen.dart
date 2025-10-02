import 'package:cached_network_image/cached_network_image.dart';
import 'package:chambea/blocs/chambeador/jobs_bloc.dart';
import 'package:chambea/blocs/chambeador/jobs_event.dart';
import 'package:chambea/blocs/chambeador/jobs_state.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';
import 'package:chambea/screens/chambeador/chat_screen.dart';
import 'package:chambea/screens/chambeador/job_detail_screen.dart';
import 'package:chambea/screens/chambeador/mas_screen.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:chambea/screens/chambeador/trabajos.dart';
import 'package:chambea/screens/chambeador/billetera_screen.dart';
import 'package:chambea/screens/client/home.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    BlocProvider(
      create: (context) => JobsBloc()..add(FetchHomeData()),
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
  final UserService _userService = UserService();
  List<dynamic> _reviews = [];
  List<dynamic> _clients = [];
  bool _isLoadingReviews = false;
  bool _isLoadingClients = false;
  String? _reviewError;
  String? _clientError;
  double? _totalBalance;
  bool _isLoadingBalance = false;
  String? _balanceError;
  DateTime? _lastBalanceFetchTime;

  // Cache keys for shared_preferences
  static const String _balanceKey = 'total_balance';
  static const String _balanceTimestampKey = 'balance_timestamp';

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
    _fetchReviews();
    _fetchClients();
    _loadCachedBalance();
  }

  Future<void> _loadCachedBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getDouble(_balanceKey);
    final timestamp = prefs.getString(_balanceTimestampKey);

    if (balance != null && timestamp != null) {
      final lastFetch = DateTime.parse(timestamp);
      final now = DateTime.now();
      // Check if cached balance is less than 5 minutes old
      if (now.difference(lastFetch).inMinutes < 5) {
        setState(() {
          _totalBalance = balance;
          _lastBalanceFetchTime = lastFetch;
          _isLoadingBalance = false;
          if (balance <= 0) {
            _balanceError = 'Tu saldo es insuficiente';
          }
        });
        print('DEBUG: Loaded cached balance: $_totalBalance at $lastFetch');
        return;
      }
    }

    // Fetch fresh balance if no valid cache or cache is stale
    await _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() {
      _isLoadingBalance = true;
      _balanceError = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      print('DEBUG: Fetching balance for user UID: ${user.uid}');

      // Use ApiService for consistency and retry logic
      final response = await ApiService.post('/api/chambeador/check-balance', {
        'uid': user.uid,
      });

      print('DEBUG: Balance response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        final balanceStr = response['data']['balance']?.toString();
        if (balanceStr == null) {
          throw Exception('Balance field is missing or null');
        }

        final balance = double.tryParse(balanceStr);
        if (balance == null) {
          throw Exception('Failed to parse balance: $balanceStr');
        }

        // Cache the balance and timestamp
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_balanceKey, balance);
        await prefs.setString(
          _balanceTimestampKey,
          DateTime.now().toIso8601String(),
        );

        setState(() {
          _totalBalance = balance;
          _lastBalanceFetchTime = DateTime.now();
          _isLoadingBalance = false;
          if (balance <= 0) {
            _balanceError = 'Tu saldo es insuficiente';
          }
        });
        print('DEBUG: Balance fetched and cached: $_totalBalance');
      } else {
        throw Exception(
          'Invalid response: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to fetch balance: $e');
      print('Stack Trace: $stackTrace');
      String errorMessage =
          'No se pudo cargar el saldo. Por favor, intenta de nuevo.';
      if (e.toString().contains('404')) {
        errorMessage =
            'Servicio de saldo no disponible. Verifica la conexión o intenta de nuevo más tarde.';
      } else if (e.toString().contains('Server returned HTML')) {
        errorMessage =
            'Error del servidor. Por favor, intenta de nuevo más tarde.';
      }
      setState(() {
        _balanceError = errorMessage;
        _isLoadingBalance = false;
      });
    }
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewError = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      print('DEBUG: Current User UID: ${user.uid}');
      print('DEBUG: Fetching reviews for workerId: ${user.uid}');
      final response = await ApiService.get(
        '/api/reviews/worker/${user.uid}/reviews-only',
      );
      print('DEBUG: Reviews response for workerId ${user.uid}: $response');
      if (response['status'] == 'success' && response['data'] != null) {
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(response['data']);
          _isLoadingReviews = false;
        });
        print('DEBUG: Received ${_reviews.length} reviews');
        print('DEBUG: Reviews Data: $_reviews');
        if (_reviews.isEmpty) {
          print('DEBUG: No reviews returned for workerId: ${user.uid}');
        }
      } else {
        throw Exception(
          'Failed to load reviews: ${response['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e, stackTrace) {
      print('ERROR: Failed to fetch reviews: $e');
      print('Stack Trace: $stackTrace');
      setState(() {
        _reviewError = 'No se pudieron cargar los comentarios: $e';
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoadingClients = true;
      _clientError = null;
    });
    try {
      final clients = await _userService.fetchClients();
      print('DEBUG: Received ${clients.length} clients: $clients');
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e, stackTrace) {
      print('ERROR: Failed to fetch clients: $e');
      print(stackTrace);
      setState(() {
        _clientError = 'No se pudieron cargar los clientes: $e';
        _isLoadingClients = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalizeImagePath(String? imagePath, {bool isProfilePhoto = false}) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      print('DEBUG: Image path is null or empty');
      return '';
    }

    String normalized = imagePath.trim();

    normalized = normalized.replaceAll(
      RegExp(r'^https://chambea\.lat/https://chambea\.lat/'),
      'https://chambea.lat/',
    );

    normalized = normalized.replaceFirst(RegExp(r'^storage/'), '');

    String lowerCasePath = normalized.toLowerCase();

    const profilePrefix = 'uploads/profile_photos/';
    const jobPrefix = 'uploads/service_requests/';

    if (isProfilePhoto && lowerCasePath.contains(profilePrefix.toLowerCase())) {
      normalized = normalized.substring(
        normalized.toLowerCase().indexOf(profilePrefix.toLowerCase()) +
            profilePrefix.length,
      );
    } else if (!isProfilePhoto &&
        lowerCasePath.contains(jobPrefix.toLowerCase())) {
      normalized = normalized.substring(
        normalized.toLowerCase().indexOf(jobPrefix.toLowerCase()) +
            jobPrefix.length,
      );
    } else if (isProfilePhoto &&
        (lowerCasePath.contains('uploads/user_profiles/') ||
            lowerCasePath.contains('uploads/chambeador_profiles/'))) {
      print('WARNING: Unexpected profile photo path: $normalized');
      normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
    } else if (!isProfilePhoto && lowerCasePath.contains('service_requests/')) {
      print('WARNING: Unexpected job image path: $normalized');
      normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
    }

    normalized = isProfilePhoto
        ? 'uploads/profile_photos/$normalized'
        : 'uploads/service_requests/$normalized';

    if (!normalized.startsWith('http')) {
      normalized = 'https://chambea.lat/$normalized';
    }

    normalized = normalized.replaceAll('Uploads/', 'uploads/');

    try {
      final uri = Uri.parse(normalized);
      if (!uri.isAbsolute || uri.host.isEmpty) {
        print('ERROR: Invalid URL format: $normalized');
        return '';
      }
      print('DEBUG: Normalized image path: $normalized');
      return normalized;
    } catch (e, stackTrace) {
      print(
        'ERROR: Failed to parse URL $normalized: $e\nStack Trace: $stackTrace',
      );
      return '';
    }
  }

  String _formatServiceDate(String? serviceDate) {
    if (serviceDate == null) return 'Unknown date';
    try {
      final date = DateFormat('dd/MM/yyyy').parse(serviceDate);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      print('ERROR: Failed to parse service_date: $serviceDate, Error: $e');
      return serviceDate;
    }
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
                            String? workerProfilePhoto;
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
                              workerProfilePhoto = _normalizeImagePath(
                                state.workerProfile?['profile_photo'],
                                isProfilePhoto: true,
                              );
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
                                            '!Ofrece tu servicio hoy mismo!',
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
                                                child:
                                                    workerProfilePhoto !=
                                                            null &&
                                                        workerProfilePhoto
                                                            .isNotEmpty
                                                    ? ClipOval(
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              workerProfilePhoto,
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (context, url) =>
                                                                  const CircularProgressIndicator(),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) {
                                                                print(
                                                                  'ERROR: Worker profile image load failed for URL $workerProfilePhoto: $error',
                                                                );
                                                                return Icon(
                                                                  Icons.person,
                                                                  size:
                                                                      (screenWidth *
                                                                              0.035)
                                                                          .clamp(
                                                                            10,
                                                                            14,
                                                                          ),
                                                                  color: Colors
                                                                      .white,
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        size:
                                                            (screenWidth *
                                                                    0.035)
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
                                                  Row(
                                                    children: [
                                                      _isLoadingBalance
                                                          ? const CircularProgressIndicator()
                                                          : Text(
                                                              _totalBalance !=
                                                                      null
                                                                  ? 'BOB ${_totalBalance!.toStringAsFixed(2)}'
                                                                  : 'BOB 0.00',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    (baseFontSize *
                                                                            1.0)
                                                                        .clamp(
                                                                          10,
                                                                          14,
                                                                        ) *
                                                                    textScaleFactor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    _totalBalance !=
                                                                            null &&
                                                                        _totalBalance! >
                                                                            0
                                                                    ? Colors
                                                                          .black87
                                                                    : Colors
                                                                          .red,
                                                              ),
                                                            ),
                                                      SizedBox(
                                                        width:
                                                            screenWidth * 0.02,
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.refresh,
                                                          size:
                                                              (screenWidth *
                                                                      0.035)
                                                                  .clamp(
                                                                    10,
                                                                    14,
                                                                  ),
                                                          color: Colors.black54,
                                                        ),
                                                        onPressed: () {
                                                          _fetchBalance();
                                                        },
                                                      ),
                                                    ],
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
                                                  if (_balanceError != null)
                                                    Text(
                                                      _balanceError!,
                                                      style: TextStyle(
                                                        fontSize:
                                                            (baseFontSize * 0.8)
                                                                .clamp(8, 10) *
                                                            textScaleFactor,
                                                        color: Colors.red,
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
                                        try {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BilleteraScreen(),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error navigating to BilleteraScreen: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Recarga',
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
                        if (_isLoadingClients)
                          const Center(child: CircularProgressIndicator())
                        else if (_clientError != null)
                          Center(child: Text('Error: $_clientError'))
                        else if (_clients.isEmpty)
                          const Center(
                            child: Text('No hay clientes disponibles'),
                          )
                        else
                          SizedBox(
                            height: screenHeight * 0.18,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _clients.map((client) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: screenWidth * 0.02,
                                    ),
                                    child: _buildClientCard(
                                      context: context,
                                      name:
                                          client['name'] ??
                                          client['client_name'] ??
                                          'Usuario Desconocido',
                                      rating:
                                          client['rating']?.toDouble() ??
                                          client['rate']?.toDouble() ??
                                          0.0,
                                      profilePhoto: _normalizeImagePath(
                                        client['profile_photo'],
                                        isProfilePhoto: true,
                                      ),
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      textScaleFactor: textScaleFactor,
                                      baseFontSize: baseFontSize,
                                    ),
                                  );
                                }).toList(),
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
                        if (_isLoadingReviews)
                          const Center(child: CircularProgressIndicator())
                        else if (_reviewError != null)
                          Center(child: Text('Error: $_reviewError'))
                        else if (_reviews.isEmpty)
                          const Center(
                            child: Text(
                              'Aún no tienes comentarios. ¡Empieza a trabajar para recibirlos!',
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              print('DEBUG: Rendering review $index: $review');
                              return _buildReviewCard(
                                context: context,
                                client:
                                    review['client_name'] ??
                                    'Usuario Desconocido',
                                rating:
                                    (review['rating'] is String
                                        ? double.tryParse(review['rating']) ??
                                              0.0
                                        : review['rating']?.toDouble()) ??
                                    0.0,
                                timeAgo: _formatTimeAgo(
                                  review['created_at'] ??
                                      DateTime.now().toIso8601String(),
                                ),
                                comment: review['comment'] ?? 'Sin comentario',
                                serviceCategory:
                                    review['service_category'] ?? 'Unknown',
                                serviceSubcategory:
                                    review['service_subcategory'] ?? 'Unknown',
                                serviceDate: _formatServiceDate(
                                  review['service_date'],
                                ),
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                textScaleFactor: textScaleFactor,
                                baseFontSize: baseFontSize,
                              );
                            },
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

  Widget _buildClientCard({
    required BuildContext context,
    required String name,
    required double rating,
    String? profilePhoto,
    required double screenWidth,
    required double screenHeight,
    required double textScaleFactor,
    required double baseFontSize,
  }) {
    final normalizedProfilePhoto = _normalizeImagePath(
      profilePhoto,
      isProfilePhoto: true,
    );
    print(
      'DEBUG: Building client card for name: $name, profilePhoto: $normalizedProfilePhoto',
    );

    return SizedBox(
      width: (screenWidth * 0.22).clamp(90.0, 110.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: (screenWidth * 0.07).clamp(22, 32),
            backgroundColor: Colors.grey,
            child: normalizedProfilePhoto.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: normalizedProfilePhoto,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) {
                        print(
                          'ERROR: Client profile image load failed for URL $normalizedProfilePhoto: $error',
                        );
                        return Icon(
                          Icons.person,
                          size: (screenWidth * 0.05).clamp(18, 26),
                          color: Colors.white,
                        );
                      },
                    ),
                  )
                : Icon(
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
    required String serviceCategory,
    required String serviceSubcategory,
    required String serviceDate,
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
                          for (int i = 0; i < 5; i++)
                            Icon(
                              i < rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: (screenWidth * 0.035).clamp(10, 14),
                              color: Colors.yellow.shade700,
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
              '$serviceCategory - $serviceSubcategory',
              style: TextStyle(
                fontSize: (baseFontSize * 1.0).clamp(10, 14) * textScaleFactor,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              'Date: $serviceDate',
              style: TextStyle(
                fontSize: (baseFontSize * 0.8).clamp(10, 12) * textScaleFactor,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              comment,
              style: TextStyle(
                fontSize: (baseFontSize * 0.8).clamp(10, 12) * textScaleFactor,
                color: Colors.black54,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
