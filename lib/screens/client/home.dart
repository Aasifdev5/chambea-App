import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chambea/screens/client/bandeja_screen.dart';
import 'package:chambea/screens/client/chats_screen.dart';
import 'package:chambea/screens/client/menu_screen.dart';
import 'package:chambea/screens/client/subcategorias_screen.dart';
import 'package:chambea/screens/client/solicitar_servicio_screen.dart';

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
            // Banner Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/BANNER.jpg',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('ERROR: Failed to load banner image: $error');
                  return Container(
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.black54,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
}