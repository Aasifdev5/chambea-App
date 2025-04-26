import 'package:flutter/material.dart';

class SubcategoriasScreen extends StatelessWidget {
  final String category;

  const SubcategoriasScreen({required this.category, super.key});

  // Mapping of categories to their subcategories
  Map<String, List<Map<String, dynamic>>> get _categoriesWithSubcategories => {
    'Construcción': [
      {'name': 'Albañil', 'icon': Icons.construction},
      {'name': 'Plomero', 'icon': Icons.plumbing},
      {'name': 'Pintor', 'icon': Icons.format_paint},
      {'name': 'Electricista', 'icon': Icons.electrical_services},
      {'name': 'Carpintero', 'icon': Icons.handyman},
      {'name': 'Cerrajero', 'icon': Icons.lock},
      {'name': 'Vidriero', 'icon': Icons.window},
    ],
    'Cuidado/Bienestar': [
      {'name': 'Cuidado de niños', 'icon': Icons.child_friendly},
      {'name': 'Cuidado de ancianos', 'icon': Icons.emoji_people},
      {'name': 'Fisioterapia', 'icon': Icons.healing},
    ],
    'Tecnología': [
      {'name': 'Desarrollador Web', 'icon': Icons.web},
      {'name': 'Desarrollador App', 'icon': Icons.phone_android},
      {'name': 'Soporte Técnico', 'icon': Icons.support_agent},
    ],
    'Educación': [
      {'name': 'Tutoría Escolar', 'icon': Icons.menu_book},
      {'name': 'Clases de Música', 'icon': Icons.music_note},
      {'name': 'Clases de Idiomas', 'icon': Icons.language},
    ],
    // 🔥 Add more categories and subcategories here
  };

  @override
  Widget build(BuildContext context) {
    final subcategories = _categoriesWithSubcategories[category] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
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
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subcategories.length,
        separatorBuilder:
            (_, __) => const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final subcategory = subcategories[index];
          final name = subcategory['name'] as String;
          final icon = subcategory['icon'] as IconData;

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
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Handle subcategory tap
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Seleccionado: $name')));
            },
          );
        },
      ),
    );
  }
}
