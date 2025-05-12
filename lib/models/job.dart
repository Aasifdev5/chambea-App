import 'package:flutter/material.dart';

class Job {
  final String id;
  final String title;
  final String timeAgo;
  final String priceRange;
  final List<String> categories;
  final String location;
  final String clientName;
  final double clientRating;
  final String status;
  final String workerName;
  final String? workerImageUrl;

  const Job({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.priceRange,
    required this.categories,
    required this.location,
    required this.clientName,
    required this.clientRating,
    required this.status,
    required this.workerName,
    this.workerImageUrl,
  });

  Job copyWith({
    String? id,
    String? title,
    String? timeAgo,
    String? priceRange,
    List<String>? categories,
    String? location,
    String? clientName,
    double? clientRating,
    String? status,
    String? workerName,
    String? workerImageUrl,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      timeAgo: timeAgo ?? this.timeAgo,
      priceRange: priceRange ?? this.priceRange,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      clientName: clientName ?? this.clientName,
      clientRating: clientRating ?? this.clientRating,
      status: status ?? this.status,
      workerName: workerName ?? this.workerName,
      workerImageUrl: workerImageUrl ?? this.workerImageUrl,
    );
  }
}

final List<Job> mockJobs = [
  const Job(
    id: '1',
    title: 'Instalaciones de luces LED',
    timeAgo: 'Hace 2 horas',
    priceRange: 'BOB 80 - 150/Hora',
    categories: ['ILUMINACIÓN', 'PANELES', 'SEGURIDAD'],
    location: 'Ave Bush - La Paz',
    clientName: 'Mario Urioste',
    clientRating: 4.3,
    status: 'Pendiente',
    workerName: 'Andrés Villamontes',
    workerImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
  ),
  const Job(
    id: '2',
    title: 'Reparar lavabo',
    timeAgo: 'Hace 1 día',
    priceRange: '\$300',
    categories: ['PLOMERÍA'],
    location: 'CDMX, México',
    clientName: 'Mario Urioste',
    clientRating: 4.3,
    status: 'Pendiente',
    workerName: 'Carlos Rivera',
    workerImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
  ),
  const Job(
    id: '3',
    title: 'Pintar departamento',
    timeAgo: 'Hace 3 horas',
    priceRange: 'BOB 100 - 200/Hora',
    categories: ['PINTURA'],
    location: 'Guadalajara, México',
    clientName: 'Rosa Elena Pérez',
    clientRating: 4.1,
    status: 'En curso',
    workerName: 'Luis Gómez',
    workerImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
  ),
  const Job(
    id: '4',
    title: 'Instalación de muebles de cocina',
    timeAgo: 'Hace 1 día',
    priceRange: 'BOB 150 - 250/Hora',
    categories: ['MUEBLES', 'CARPINTERÍA'],
    location: 'Ciudad de México, México',
    clientName: 'Carlos Mendoza',
    clientRating: 4.7,
    status: 'Completado',
    workerName: 'Javier Torres',
    workerImageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
  ),
];
