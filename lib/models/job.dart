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
  final String? workerName;
  final double? workerRating;
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
    this.workerName,
    this.workerRating,
    required this.proposals,
    required this.status,
    required this.title,
    required this.categories,
    required this.priceRange,
    required this.timeAgo,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,
      category: json['category'] ?? 'Servicio',
      subcategory: json['subcategory'] ?? 'General',
      location: json['location'] ?? 'Sin ubicación',
      locationDetails: json['location_details'],
      budget: json['budget'] != null
          ? double.tryParse(json['budget'].toString())
          : null,
      startTime: json['start_time'],
      endTime: json['end_time'],
      isTimeUndefined: json['is_time_undefined'] == true,
      date: json['date'],
      paymentMethod: json['payment_method'],
      description: json['description'],
      image: json['image'],
      clientName: json['client_name'] ?? 'Usuario Desconocido',
      clientRating: json['client_rating'] != null
          ? double.tryParse(json['client_rating'].toString())
          : 0.0,
      workerName: json['proposals'] != null && json['proposals'].isNotEmpty
          ? json['proposals'][0]['worker_name']
          : null,
      workerRating: json['proposals'] != null && json['proposals'].isNotEmpty
          ? double.tryParse(json['proposals'][0]['worker_rating'].toString())
          : null,
      proposals: List<Map<String, dynamic>>.from(json['proposals'] ?? []),
      status: json['status'] ?? 'Pendiente',
      title:
          json['title'] ??
          '${json['category'] ?? 'Servicio'} - ${json['subcategory'] ?? 'General'}',
      categories: List<String>.from(
        json['categories'] ??
            [json['category'] ?? 'Servicio', json['subcategory'] ?? 'General'],
      ),
      priceRange:
          json['price_range'] ?? 'BOB ${json['budget'] ?? 'No especificado'}',
      timeAgo: json['time_ago'] ?? 'Hace desconocido',
    );
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
    String? workerName,
    double? workerRating,
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
      workerName: workerName ?? this.workerName,
      workerRating: workerRating ?? this.workerRating,
      proposals: proposals ?? this.proposals,
      status: status ?? this.status,
      title: title ?? this.title,
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}
