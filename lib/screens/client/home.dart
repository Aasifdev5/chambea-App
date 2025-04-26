import 'package:flutter/material.dart';

// Placeholder imports for navigation (adjust paths as needed)
import 'package:chambea/screens/client/bandeja_screen.dart';
import 'package:chambea/screens/client/solicitudes_screen.dart';
import 'package:chambea/screens/client/chats_screen.dart';
import 'package:chambea/screens/client/menu_screen.dart';
import 'package:chambea/screens/client/subcategorias_screen.dart'; // Re-added import for SubcategoriasScreen
import 'package:chambea/screens/client/servicios_screen.dart';
import 'package:chambea/screens/client/busqueda_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  // List of screens for BottomNavigationBar navigation
  final List<Widget> _screens = [
    ClientHomeContent(), // Inicio (index 0)
    BandejaScreen(), // Bondeo (index 1)
    SolicitudesScreen(), // Solicitud (index 2)
    ChatsScreen(), // Chat (index 3)
    MenuScreen(), // Menú (index 4)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Bondeo'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Solicitud'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }
}

class ClientHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: "¿Qué servicio necesitas?"
            const Text(
              '¿Qué servicio necesitas?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Categories Section
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
              childAspectRatio: 1,
              children: [
                _buildCategoryCard(
                  context: context,
                  icon: Icons.construction,
                  title: 'Construcción',
                  users: '12k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.home,
                  title: 'Hogar',
                  users: '12k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.kitchen,
                  title: 'Gastronomía',
                  users: '970 usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.local_hospital,
                  title: 'Cuidado/Bienestar',
                  users: '1k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.security,
                  title: 'Seguridad',
                  users: '12k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.school,
                  title: 'Educación',
                  users: '970 usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.pets,
                  title: 'Mascotas',
                  users: '1k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.spa,
                  title: 'Belleza',
                  users: '12k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.event,
                  title: 'Eventos',
                  users: '970 usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.network_wifi,
                  title: 'Redes Sociales',
                  users: '1k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.build,
                  title: 'Mantenimiento',
                  users: '12k usuarios',
                ),
                _buildCategoryCard(
                  context: context,
                  icon: Icons.add,
                  title: 'Otros',
                  users: '970 usuarios',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Recommended Chambeadores Section
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BusquedaScreen()),
                    );
                  },
                  child: const Text(
                    'Ver más',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChambeadorCard(name: 'Rosa Elena Pérez', rating: 4.1),
                  _buildChambeadorCard(name: 'Julio Sequeira', rating: 4.1),
                  _buildChambeadorCard(name: 'Julio César Suárez', rating: 4.1),
                  _buildChambeadorCard(name: 'Pedro Castillo', rating: 4.1),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Popular Services Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Servicios populares',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiciosScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Ver más',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ayuda eléctrica',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Andrés Villamontes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
                                      const Text(
                                        '4.1',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Electricista',
                                        style: TextStyle(
                                          fontSize: 12,
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
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      color: Colors.grey.shade300,
                    ),
                    child: const Icon(
                      Icons.electrical_services,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String users,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubcategoriasScreen(category: title),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                users,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChambeadorCard({required String name, required double rating}) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.yellow.shade700),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
