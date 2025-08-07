import 'package:firebase_auth/firebase_auth.dart';

class Job {
  final int id;
  final String category;
  final String subcategory;
  final String location;
  final String? locationDetails;
  final double? budget;
  final String? startTime;
  final String? endTime;
  final bool isTimeUndefined;
  final String? date;
  final String? paymentMethod;
  final String? description;
  final String? image;
  final String? clientName;
  final double? clientRating;
  final int? workerId;
  final String? workerName;
  final double? workerRating;
  final int? clientId;
  final List<Map<String, dynamic>> proposals;
  final String status;
  final String title;
  final List<String> categories;
  final String priceRange;
  final String timeAgo;

  Job({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.location,
    this.locationDetails,
    this.budget,
    this.startTime,
    this.endTime,
    required this.isTimeUndefined,
    this.date,
    this.paymentMethod,
    this.description,
    this.image,
    this.clientName,
    this.clientRating,
    this.workerId,
    this.workerName,
    this.workerRating,
    this.clientId,
    required this.proposals,
    required this.status,
    required this.title,
    required this.categories,
    required this.priceRange,
    required this.timeAgo,
  });

  // Getter to check if the current user has applied
  bool get hasApplied {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;
    return proposals.any((proposal) =>
        proposal['worker_id']?.toString() == currentUserId);
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    final proposals = json['proposals'] != null
        ? List<Map<String, dynamic>>.from(json['proposals'])
        : <Map<String, dynamic>>[];

    Map<String, dynamic>? selectedProposal;
    if (json['proposal_id'] != null) {
      selectedProposal = proposals.firstWhere(
        (proposal) => proposal['id'] == json['proposal_id'],
        orElse: () => {},
      );
    }

    return Job(
      id: json['id'] is int ? json['id'] : 0,
      category: json['category']?.toString() ?? 'Servicio',
      subcategory: json['subcategory']?.toString() ?? 'General',
      location: json['location']?.toString() ?? 'Sin ubicación',
      locationDetails: json['location_details']?.toString(),
      budget: json['budget'] != null
          ? double.tryParse(json['budget'].toString()) ?? 0.0
          : null,
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      isTimeUndefined: json['is_time_undefined'] == true,
      date: json['date']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      clientName: json['client_name']?.toString() ?? 'Usuario Desconocido',
      clientRating: json['client_rating'] != null
          ? double.tryParse(json['client_rating'].toString()) ?? 0.0
          : 0.0,
      workerId: json['worker_id'] is int
          ? json['worker_id']
          : selectedProposal != null && selectedProposal.isNotEmpty
              ? selectedProposal['worker_id'] is int
                  ? selectedProposal['worker_id']
                  : null
              : null,
      workerName: json['worker_name']?.toString() ??
          (selectedProposal != null && selectedProposal.isNotEmpty
              ? selectedProposal['worker_name']?.toString()
              : null),
      workerRating: json['worker_rating'] != null
          ? double.tryParse(json['worker_rating'].toString()) ?? 0.0
          : (selectedProposal != null &&
                  selectedProposal.isNotEmpty &&
                  selectedProposal['worker_rating'] != null
              ? double.tryParse(selectedProposal['worker_rating'].toString()) ??
                  0.0
              : null),
      clientId: json['created_by'] is int
          ? json['created_by']
          : json['client_id'] is int
              ? json['client_id']
              : null,
      proposals: proposals,
      status: json['status']?.toString() ?? 'Pendiente',
      title: json['title']?.toString() ??
          '${json['category']?.toString() ?? 'Servicio'} - ${json['subcategory']?.toString() ?? 'General'}',
      categories: json['categories'] != null &&
              json['categories'] is List &&
              (json['categories'] as List).isNotEmpty
          ? List<String>.from(json['categories'].map((e) => e.toString()))
          : [
              json['category']?.toString() ?? 'Servicio',
              json['subcategory']?.toString() ?? 'General',
            ],
      priceRange: json['price_range']?.toString() ??
          (json['budget'] != null
              ? 'BOB ${json['budget'].toString()}'
              : 'BOB No especificado'),
      timeAgo: json['time_ago']?.toString() ?? 'Hace desconocido',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'location': location,
      'location_details': locationDetails,
      'budget': budget,
      'start_time': startTime,
      'end_time': endTime,
      'is_time_undefined': isTimeUndefined,
      'date': date,
      'payment_method': paymentMethod,
      'description': description,
      'image': image,
      'client_name': clientName,
      'client_rating': clientRating,
      'worker_id': workerId,
      'worker_name': workerName,
      'worker_rating': workerRating,
      'client_id': clientId,
      'proposals': proposals,
      'status': status,
      'title': title,
      'categories': categories,
      'price_range': priceRange,
      'time_ago': timeAgo,
    };
  }

  Job copyWith({
    int? id,
    String? category,
    String? subcategory,
    String? location,
    String? locationDetails,
    double? budget,
    String? startTime,
    String? endTime,
    bool? isTimeUndefined,
    String? date,
    String? paymentMethod,
    String? description,
    String? image,
    String? clientName,
    double? clientRating,
    int? workerId,
    String? workerName,
    double? workerRating,
    int? clientId,
    List<Map<String, dynamic>>? proposals,
    String? status,
    String? title,
    List<String>? categories,
    String? priceRange,
    String? timeAgo,
  }) {
    return Job(
      id: id ?? this.id,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      budget: budget ?? this.budget,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isTimeUndefined: isTimeUndefined ?? this.isTimeUndefined,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      image: image ?? this.image,
      clientName: clientName ?? this.clientName,
      clientRating: clientRating ?? this.clientRating,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerRating: workerRating ?? this.workerRating,
      clientId: clientId ?? this.clientId,
      proposals: proposals ?? this.proposals,
      status: status ?? this.status,
      title: title ?? this.title,
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}