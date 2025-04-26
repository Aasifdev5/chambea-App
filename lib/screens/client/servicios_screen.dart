import 'package:flutter/material.dart';
import 'package:chambea/screens/client/service_detail_screen.dart'; // Import the new screen

class ServiciosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Servicios'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ServiceDetailScreen(
                            title: 'Ayuda eléctrica',
                            worker: 'Andrés Villamontes',
                            rating: 4.1,
                            categories: ['Corriente', 'Enchufe', 'Luz'],
                            location: 'Ave Bush - La Paz',
                            price: 'BOB: 80 - 150/Hora',
                            paymentMethod:
                                'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.',
                            description:
                                'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry\'s standard dummy text.',
                          ),
                    ),
                  );
                },
                child: _buildServiceCard(
                  title: 'Ayuda eléctrica',
                  worker: 'Andrés Villamontes',
                  role: 'Electricista',
                  rating: 4.1,
                  location: 'Ave Bush - La Paz',
                  price: 'BOB: 80 - 150/Hora',
                  categories: ['Corriente', 'Enchufe', 'Luz'],
                  paymentMethod:
                      'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ServiceDetailScreen(
                            title: 'Ayuda eléctrica',
                            worker: 'Andrés Villamontes',
                            rating: 4.1,
                            categories: ['Corriente', 'Enchufe', 'Luz'],
                            location: 'Ave Bush - La Paz',
                            price: 'BOB: 80 - 150/Hora',
                            paymentMethod:
                                'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.',
                            description:
                                'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry\'s standard dummy text.',
                          ),
                    ),
                  );
                },
                child: _buildServiceCard(
                  title: 'Ayuda eléctrica',
                  worker: 'Andrés Villamontes',
                  role: 'Electricista',
                  rating: 4.1,
                  location: 'Ave Bush - La Paz',
                  price: 'BOB: 80 - 150/Hora',
                  categories: ['Corriente', 'Enchufe', 'Luz'],
                  paymentMethod:
                      'El pago puede realizar mediante Código QR o con efectivo después de finalizar el servicio.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String worker,
    required String role,
    required double rating,
    required String location,
    required String price,
    required List<String> categories,
    required String paymentMethod,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/placeholder_image.jpg',
                    ), // Replace with actual image asset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.yellow.shade700,
                            ),
                            Text(
                              rating.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              ' $role',
                              style: const TextStyle(
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      categories
                          .map(
                            (category) => Chip(
                              label: Text(
                                category,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          )
                          .toList(),
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
                      location,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Forma de pago',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  paymentMethod,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
