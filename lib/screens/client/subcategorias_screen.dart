import 'package:flutter/material.dart';
import 'package:chambea/screens/client/solicitar_servicio_screen.dart';

class SubcategoriasScreen extends StatelessWidget {
  final String category;
  final List<String> subcategories;

  const SubcategoriasScreen({
    required this.category,
    required this.subcategories,
    super.key,
  });

  // Mapping of subcategories to icons
  static const Map<String, IconData> _subcategoryIcons = {
    'Albañil': Icons.construction,
    'Plomero': Icons.plumbing,
    'Pintor': Icons.format_paint,
    'Electricista': Icons.electrical_services,
    'Carpintero': Icons.handyman,
    'Cerrajero': Icons.lock,
    'Vidriero': Icons.window,
    'Personal de Limpieza': Icons.cleaning_services,
    'Lavandería': Icons.local_laundry_service,
    'Jardinería': Icons.grass,
    'Fumigación': Icons.bug_report,
    'Churrasquero': Icons.outdoor_grill,
    'Chef': Icons.restaurant_menu,
    'Cocinero/a': Icons.kitchen,
    'Ayudante de Cocina': Icons.kitchen,
    'Repostera/o': Icons.cake,
    'Niñera': Icons.child_friendly,
    'Enfermería': Icons.medical_services,
    'Fisioterapia': Icons.healing,
    'Psicólogo': Icons.psychology,
    'Personal Trainer': Icons.fitness_center,
    'Nutricionista': Icons.food_bank,
    'Cuidado de Adulto mayor': Icons.elderly,
    'Sereno': Icons.nightlight,
    'Guardaespaldas': Icons.security,
    'Detective Privado': Icons.search,
    'Personal de seguridad': Icons.security,
    'Nivelación Escolar': Icons.school,
    'Trabajos Escolares': Icons.assignment,
    'Profesor de idiomas': Icons.language,
    'Psicopedagogos': Icons.support,
    'Ayudantías Universitarias': Icons.school,
    'Tutor de Tesis': Icons.book,
    'Veterinario': Icons.pets,
    'Cuidado de mascotas': Icons.pets,
    'Paseo de Mascotas': Icons.directions_walk,
    'Peluquería/spa': Icons.spa,
    'Barberia/corte': Icons.cut,
    'Manicura/pedicura': Icons.brush,
    'Maquillaje facial': Icons.face,
    'Depilación': Icons.spa,
    'Peinados': Icons.style,
    'Meseros': Icons.room_service,
    'Barman': Icons.local_bar,
    'Filmación': Icons.videocam,
    'Fotógrafo': Icons.camera_alt,
    'Animación/Entretenimiento': Icons.theater_comedy,
    'Payasos': Icons.mood,
    'Amplificación y Sonido': Icons.speaker,
    'Decoración/escenario': Icons.event_seat,
    'Servicio de DJ': Icons.music_note,
    'Grupo musical/solista': Icons.mic,
    'Influencer': Icons.star,
    'Editor de Videos': Icons.video_file,
    'Editor de Imágenes': Icons.image,
    'Manejo de Redes Sociales': Icons.share,
    'Mecánica General': Icons.car_repair,
    'Aires Acondicionados': Icons.ac_unit,
    'Cámaras de Seguridad': Icons.security,
    'Calefones': Icons.hot_tub,
    'Sistemas Eléctricos': Icons.electrical_services,
  };

  @override
  Widget build(BuildContext context) {
    final TextEditingController customSubcategoryController =
        TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
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
      body: subcategories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No hay subcategorías disponibles. Ingresa un servicio personalizado:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: customSubcategoryController,
                      decoration: InputDecoration(
                        labelText: 'Servicio personalizado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Ejemplo: Reparación de electrodomésticos',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final customSubcategory = customSubcategoryController
                            .text
                            .trim();
                        if (customSubcategory.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, ingresa un servicio personalizado',
                              ),
                            ),
                          );
                          return;
                        }
                        print(
                          'DEBUG: Navigating to SolicitarServicioScreen with category: $category, subcategory: $customSubcategory',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SolicitarServicioScreen(
                              categoryName: category,
                              subcategoryName: customSubcategory,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Solicitar servicio personalizado',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subcategories.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final subcategory = subcategories[index];
                final icon = _subcategoryIcons[subcategory] ?? Icons.category;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.green, size: 24),
                  ),
                  title: Text(
                    subcategory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    print(
                      'DEBUG: Navigating to SolicitarServicioScreen with category: $category, subcategory: $subcategory',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SolicitarServicioScreen(
                          categoryName: category,
                          subcategoryName: subcategory,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
