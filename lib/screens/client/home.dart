import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retry/retry.dart';
import 'package:chambea/services/api_service.dart';
import 'package:chambea/screens/client/bandeja_screen.dart';
import 'package:chambea/screens/client/chats_screen.dart';
import 'package:chambea/screens/client/menu_screen.dart';
import 'package:chambea/screens/client/subcategorias_screen.dart';
import 'package:chambea/screens/client/solicitar_servicio_screen.dart';
import 'package:chambea/screens/client/cerca_de_mi_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('DEBUG: BottomNavigationBar index changed to: $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building ClientHomeScreen, selectedIndex: $_selectedIndex');
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            ClientHomeContent(key: const ValueKey('home_content')),
            BandejaScreen(),
            const SolicitarServicioScreen(),
            ChatsScreen(),
            MenuScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Bandeja'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Solicitud'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }
}

class ClientHomeContent extends StatefulWidget {
  const ClientHomeContent({super.key});

  @override
  _ClientHomeContentState createState() => _ClientHomeContentState();
}

class _ClientHomeContentState extends State<ClientHomeContent> {
  Future<List<dynamic>> _fetchChambeadores() async {
    try {
      print('DEBUG: Starting chambeadores fetch');
      final response = await retry(
        () => ApiService.get('/api/chambeadores/ratings').timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('API request timed out'),
        ),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        randomizationFactor: 0.5,
      );

      print('DEBUG: API response: $response');

      if (response['status'] != 'success' || response['data'] == null) {
        throw Exception(response['message'] ?? 'Failed to load chambeadores');
      }

      print('DEBUG: Loaded ${response['data'].length} chambeadores');
      return response['data'];
    } catch (e) {
      print('ERROR: Failed to load chambeadores: $e');
      rethrow;
    }
  }

  final List<Map<String, dynamic>> _categories = const [
    {
      'title': 'Construcción',
      'icon': Icons.construction,
      'users': '12k usuarios',
      'subcategories': <String>[
        'Albañil',
        'Plomero',
        'Pintor',
        'Electricista',
        'Carpintero',
        'Cerrajero',
        'Vidriero',
      ],
    },
    {
      'title': 'Hogar',
      'icon': Icons.home,
      'users': '12k usuarios',
      'subcategories': <String>[
        'Personal de Limpieza',
        'Lavandería',
        'Jardinería',
        'Fumigación',
      ],
    },
    {
      'title': 'Gastronomía',
      'icon': Icons.kitchen,
      'users': '970 usuarios',
      'subcategories': <String>[
        'Churrasquero',
        'Chef',
        'Cocinero/a',
        'Ayudante de Cocina',
        'Repostera/o',
      ],
    },
    {
      'title': 'Cuidado/Bienestar',
      'icon': Icons.local_hospital,
      'users': '1k usuarios',
      'subcategories': <String>[
        'Niñera',
        'Enfermería',
        'Fisioterapia',
        'Psicólogo',
        'Personal Trainer',
        'Nutricionista',
        'Cuidado de Adulto mayor',
      ],
    },
    {
      'title': 'Seguridad',
      'icon': Icons.security,
      'users': '12k usuarios',
      'subcategories': <String>[
        'Sereno',
        'Guardaespaldas',
        'Detective Privado',
        'Personal de seguridad',
      ],
    },
    {
      'title': 'Educación',
      'icon': Icons.school,
      'users': '970 usuarios',
      'subcategories': <String>[
        'Nivelación Escolar',
        'Trabajos Escolares',
        'Profesor de idiomas',
        'Psicopedagogos',
        'Ayudantías Universitarias',
        'Tutor de Tesis',
      ],
    },
    {
      'title': 'Mascotas',
      'icon': Icons.pets,
      'users': '1k usuarios',
      'subcategories': <String>[
        'Veterinario',
        'Cuidado de mascotas',
        'Paseo de Mascotas',
        'Peluquería/spa',
      ],
    },
    {
      'title': 'Belleza',
      'icon': Icons.spa,
      'users': '12k usuarios',
      'subcategories': <String>[
        'Barberia/corte',
        'Manicura/pedicura',
        'Maquillaje facial',
        'Depilación',
        'Peinados',
      ],
    },
    {
      'title': 'Eventos',
      'icon': Icons.event,
      'users': '970 usuarios',
      'subcategories': <String>[
        'Meseros',
        'Barman',
        'Filmación',
        'Fotógrafo',
        'Animación/Entretenimiento',
        'Payasos',
        'Amplificación y Sonido',
        'Decoración/escenario',
        'Servicio de DJ',
        'Grupo musical/solista',
      ],
    },
    {
      'title': 'Redes Sociales',
      'icon': Icons.network_wifi,
      'users': '1k usuarios',
      'subcategories': <String>[
        'Influencer',
        'Editor de Videos',
        'Editor de Imágenes',
        'Manejo de Redes Sociales',
      ],
    },
    {
      'title': 'Mantenimiento y Reparación',
      'icon': Icons.build,
      'users': '12k usuarios',
      'subcategories': <String>[
        'Mecánica General',
        'Aires Acondicionados',
        'Cámaras de Seguridad',
        'Calefones',
        'Sistemas Eléctricos',
      ],
    },
    {
      'title': 'Otros',
      'icon': Icons.add,
      'users': '970 usuarios',
      'subcategories': <String>[],
    },
  ];

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building ClientHomeContent');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué servicio necesitas?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
              children: _categories.map((category) {
                return _buildCategoryCard(
                  context: context,
                  icon: category['icon'] as IconData,
                  title: category['title'] as String,
                  users: category['users'] as String,
                  subcategories: category['subcategories'] as List<String>,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chambeadores Recomendados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateTo(context, CercaDeMiScreen()),
                  child: const Text(
                    'Ver más',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<dynamic>>(
              future: _fetchChambeadores(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No chambeadores found'));
                }

                final chambeadores = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: chambeadores.map((profile) {
                      final name = profile['name'] as String? ?? 'Unknown';
                      final lastName = profile['last_name'] as String? ?? '';
                      final fullName =
                          '$name${lastName.isNotEmpty ? ' $lastName' : ''}';
                      final profession =
                          profile['profession'] as String? ?? 'No profession';
                      final rating = profile['rating'] != null
                          ? double.tryParse(profile['rating'].toString()) ?? 0.0
                          : 0.0;
                      final uid = profile['uid'] as String? ?? '';
                      final profilePhotoPath = profile['profile_photo_path'] as String?;
                      print(
                        'DEBUG: Rendering chambeador card: $fullName, uid: $uid, profile_photo_path: $profilePhotoPath',
                      );
                      return GestureDetector(
                        onTap: () => _navigateToProfile(context, uid, fullName),
                        child: _buildChambeadorCard(
                          context: context,
                          name: fullName,
                          profession: profession,
                          rating: rating,
                          profilePhotoPath: profilePhotoPath,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    print('DEBUG: Navigating to ${screen.runtimeType}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).catchError((e) {
      print('ERROR: Navigation to ${screen.runtimeType} failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
    });
  }

  void _navigateToProfile(BuildContext context, String uid, String fullName) {
    if (uid.isEmpty) {
      print('ERROR: Invalid UID for chambeador: $fullName');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid chambeador profile')),
      );
      return;
    }
    print('DEBUG: Navigating to chambeador_profile with uid: $uid');
    Navigator.pushNamed(
      context,
      '/chambeador_profile',
      arguments: {'uid': uid},
    ).catchError((e) {
      print('ERROR: Navigation to chambeador_profile failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
    });
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String users,
    required List<String> subcategories,
  }) {
    return GestureDetector(
      onTap: () {
        print('DEBUG: Navigating to SubcategoriasScreen with category: $title');
        _navigateTo(
          context,
          SubcategoriasScreen(category: title, subcategories: subcategories),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.green),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                users,
                style: const TextStyle(fontSize: 8, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChambeadorCard({
    required BuildContext context,
    required String name,
    required String profession,
    required double rating,
    required String? profilePhotoPath,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profilePhotoPath != null
                ? NetworkImage('https://chambea.lat/$profilePhotoPath')
                : null,
            onBackgroundImageError: profilePhotoPath != null
                ? (exception, stackTrace) {
                    print('ERROR: Failed to load profile image for $name: $exception');
                  }
                : null,
            child: profilePhotoPath == null
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 14, color: Colors.yellow.shade700),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          Text(
            profession,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}