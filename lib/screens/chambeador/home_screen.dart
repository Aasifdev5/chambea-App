import 'package:flutter/material.dart';
import 'package:chambea/screens/chambeador/buscar_screen.dart';
import 'package:chambea/screens/chambeador/chat_screen.dart';
import 'package:chambea/screens/chambeador/mas_screen.dart';
import 'package:chambea/screens/chambeador/propuesta_screen.dart';
import 'package:chambea/screens/chambeador/job_detail_screen.dart';
import 'package:chambea/screens/chambeador/trabajos.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(), // Inicio (index 0)
    const TrabajosContent(), // Trabajos (index 1)
    BuscarScreen(), // Buscar (index 2)
    ChatScreen(), // Chat (index 3)
    MasScreen(), // Menú (index 4)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF22c55e),
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 10, // Reduced from 12 to 10
        unselectedFontSize: 8, // Reduced from 10 to 8
        iconSize: 22, // Reduced from 24 to 22
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
        final double baseFontSize =
            screenWidth * 0.035; // Reduced from 0.04 to 0.035
        final bool isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        return Column(
          children: [
            AppBar(
              title: Text(
                'Inicio',
                style: TextStyle(
                  fontSize:
                      (baseFontSize * 1.4).clamp(16, 20) *
                      textScaleFactor, // Reduced from 18,22 to 16,20
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 2,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: (screenWidth * 0.06).clamp(
                      22,
                      28,
                    ), // Reduced from 24,30 to 22,28
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
                        // Profile Card with Animation
                        FadeTransition(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          fontSize:
                                              screenWidth < 360
                                                  ? (baseFontSize * 1.1).clamp(
                                                        12,
                                                        16,
                                                      ) *
                                                      textScaleFactor // Reduced from 14,18 to 12,16
                                                  : (baseFontSize * 1.2).clamp(
                                                        14,
                                                        18,
                                                      ) *
                                                      textScaleFactor, // Reduced from 16,20 to 14,18
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: (screenWidth * 0.045).clamp(
                                              12,
                                              16,
                                            ), // Reduced from 14,18 to 12,16
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            child: Icon(
                                              Icons.person,
                                              size: (screenWidth * 0.035).clamp(
                                                10,
                                                14,
                                              ), // Reduced from 12,16 to 10,14
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Andrés Villamontes',
                                                style: TextStyle(
                                                  fontSize:
                                                      (baseFontSize * 1.0)
                                                          .clamp(10, 14) *
                                                      textScaleFactor, // Reduced from 12,16 to 10,14
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: (screenWidth * 0.035)
                                                        .clamp(
                                                          10,
                                                          14,
                                                        ), // Reduced from 12,16 to 10,14
                                                    color:
                                                        Colors.yellow.shade700,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.01,
                                                  ),
                                                  Text(
                                                    '3.9',
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 0.8)
                                                              .clamp(10, 12) *
                                                          textScaleFactor, // Reduced from 12,14 to 10,12
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'BOB: 0.00',
                                                style: TextStyle(
                                                  fontSize:
                                                      (baseFontSize * 1.0)
                                                          .clamp(10, 14) *
                                                      textScaleFactor, // Reduced from 12,16 to 10,14
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'Saldo Actual',
                                                style: TextStyle(
                                                  fontSize:
                                                      (baseFontSize * 0.7)
                                                          .clamp(8, 10) *
                                                      textScaleFactor, // Reduced from 10,12 to 8,10
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: screenWidth * 0.04),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '0',
                                                style: TextStyle(
                                                  fontSize:
                                                      (baseFontSize * 1.0)
                                                          .clamp(10, 14) *
                                                      textScaleFactor, // Reduced from 12,16 to 10,14
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'Servicios en curso',
                                                style: TextStyle(
                                                  fontSize:
                                                      (baseFontSize * 0.7)
                                                          .clamp(8, 10) *
                                                      textScaleFactor, // Reduced from 10,12 to 8,10
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Ver más')),
                                    );
                                  },
                                  child: Text(
                                    'Ver más',
                                    style: TextStyle(
                                      color: const Color(0xFF22c55e),
                                      fontSize:
                                          (baseFontSize * 0.8).clamp(10, 12) *
                                          textScaleFactor, // Reduced from 12,14 to 10,12
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Recommended Jobs
                        Text(
                          'Trabajos recomendados para ti',
                          style: TextStyle(
                            fontSize:
                                (baseFontSize * 1.1).clamp(12, 16) *
                                textScaleFactor, // Reduced from 14,18 to 12,16
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        GestureDetector(
                          onTap: () {
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const JobDetailScreen(),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error navigating to JobDetailScreen: $e',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.03,
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Hace 2 horas',
                                            style: TextStyle(
                                              fontSize:
                                                  (baseFontSize * 0.7).clamp(
                                                    8,
                                                    10,
                                                  ) *
                                                  textScaleFactor, // Reduced from 10,12 to 8,10
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            'BOB 80 - 150/Hora',
                                            style: TextStyle(
                                              fontSize:
                                                  (baseFontSize * 1.0).clamp(
                                                    10,
                                                    14,
                                                  ) *
                                                  textScaleFactor, // Reduced from 12,16 to 10,14
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        'Instalaciones de luces LED',
                                        style: TextStyle(
                                          fontSize:
                                              (baseFontSize * 1.2).clamp(
                                                12,
                                                16,
                                              ) *
                                              textScaleFactor, // Reduced from 14,18 to 12,16
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Wrap(
                                        spacing: screenWidth * 0.02,
                                        children: [
                                          Chip(
                                            label: Text(
                                              'ILUMINACIÓN',
                                              style: TextStyle(
                                                fontSize:
                                                    (baseFontSize * 0.7).clamp(
                                                      8,
                                                      10,
                                                    ) *
                                                    textScaleFactor, // Reduced from 10,12 to 8,10
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.02,
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              'PANELES',
                                              style: TextStyle(
                                                fontSize:
                                                    (baseFontSize * 0.7).clamp(
                                                      8,
                                                      10,
                                                    ) *
                                                    textScaleFactor, // Reduced from 10,12 to 8,10
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.02,
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              'SEGURIDAD',
                                              style: TextStyle(
                                                fontSize:
                                                    (baseFontSize * 0.7).clamp(
                                                      8,
                                                      10,
                                                    ) *
                                                    textScaleFactor, // Reduced from 10,12 to 8,10
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.02,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: (screenWidth * 0.035).clamp(
                                              10,
                                              14,
                                            ), // Reduced from 12,16 to 10,14
                                            color: Colors.black54,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Text(
                                            'Ave Bush - La Paz',
                                            style: TextStyle(
                                              fontSize:
                                                  (baseFontSize * 0.8).clamp(
                                                    10,
                                                    12,
                                                  ) *
                                                  textScaleFactor, // Reduced from 12,14 to 10,12
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: (screenWidth * 0.045).clamp(
                                              12,
                                              16,
                                            ), // Reduced from 14,18 to 12,16
                                            backgroundColor: Colors.grey,
                                            child: Icon(
                                              Icons.person,
                                              size: (screenWidth * 0.035).clamp(
                                                10,
                                                14,
                                              ), // Reduced from 12,16 to 10,14
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Mario Urioste',
                                                style: TextStyle(
                                                  fontSize:
                                                      (baseFontSize * 1.0)
                                                          .clamp(10, 14) *
                                                      textScaleFactor, // Reduced from 12,16 to 10,14
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: (screenWidth * 0.035)
                                                        .clamp(
                                                          10,
                                                          14,
                                                        ), // Reduced from 12,16 to 10,14
                                                    color: Colors.yellow,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.01,
                                                  ),
                                                  Text(
                                                    '4.3',
                                                    style: TextStyle(
                                                      fontSize:
                                                          (baseFontSize * 0.8)
                                                              .clamp(10, 12) *
                                                          textScaleFactor, // Reduced from 12,14 to 10,12
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Recommended Clients
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Clientes Recomendados',
                              style: TextStyle(
                                fontSize:
                                    (baseFontSize * 1.1).clamp(12, 16) *
                                    textScaleFactor, // Reduced from 14,18 to 12,16
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
                                      textScaleFactor, // Reduced from 12,14 to 10,12
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        SingleChildScrollView(
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
                              _buildClientCard(
                                context: context,
                                name: 'Julio César Suarez',
                                rating: 4.1,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                textScaleFactor: textScaleFactor,
                                baseFontSize: baseFontSize,
                              ),
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
                        SizedBox(height: screenHeight * 0.02),
                        // Recent Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Últimos comentarios',
                              style: TextStyle(
                                fontSize:
                                    (baseFontSize * 1.1).clamp(12, 16) *
                                    textScaleFactor, // Reduced from 14,18 to 12,16
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
                                      textScaleFactor, // Reduced from 12,14 to 10,12
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

  Widget _buildClientCard({
    required BuildContext context,
    required String name,
    required double rating,
    required double screenWidth,
    required double screenHeight,
    required double textScaleFactor,
    required double baseFontSize,
  }) {
    return Container(
      margin: EdgeInsets.only(right: screenWidth * 0.04),
      child: Column(
        children: [
          CircleAvatar(
            radius: (screenWidth * 0.07).clamp(
              22,
              32,
            ), // Reduced from 24,36 to 22,32
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.person,
              size: (screenWidth * 0.05).clamp(
                18,
                26,
              ), // Reduced from 20,30 to 18,26
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            name,
            style: TextStyle(
              fontSize:
                  (baseFontSize * 1.0).clamp(10, 14) *
                  textScaleFactor, // Reduced from 12,16 to 10,14
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: (screenWidth * 0.035).clamp(
                  10,
                  14,
                ), // Reduced from 12,16 to 10,14
                color: Colors.yellow,
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                rating.toString(),
                style: TextStyle(
                  fontSize:
                      (baseFontSize * 0.8).clamp(10, 12) *
                      textScaleFactor, // Reduced from 12,14 to 10,12
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
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: (screenWidth * 0.045).clamp(
                    12,
                    16,
                  ), // Reduced from 14,18 to 12,16
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: (screenWidth * 0.035).clamp(
                      10,
                      14,
                    ), // Reduced from 12,16 to 10,14
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client,
                      style: TextStyle(
                        fontSize:
                            (baseFontSize * 1.0).clamp(10, 14) *
                            textScaleFactor, // Reduced from 12,16 to 10,14
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: (screenWidth * 0.035).clamp(
                            10,
                            14,
                          ), // Reduced from 12,16 to 10,14
                          color: Colors.yellow,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize:
                                (baseFontSize * 0.8).clamp(10, 12) *
                                textScaleFactor, // Reduced from 12,14 to 10,12
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize:
                        (baseFontSize * 0.7).clamp(8, 10) *
                        textScaleFactor, // Reduced from 10,12 to 8,10
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              comment,
              style: TextStyle(
                fontSize:
                    (baseFontSize * 0.8).clamp(10, 12) *
                    textScaleFactor, // Reduced from 12,14 to 10,12
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
