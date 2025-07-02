class ServiceRequest {
  int? id;
  int? createdBy;
  String? date;
  String? startTime;
  String? endTime;
  bool isTimeUndefined;
  String? location;
  String? locationDetails;
  double? latitude;
  double? longitude;
  String? category;
  String? subcategory;
  String? description;
  String? budget;
  String? paymentMethod;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;

  ServiceRequest({
    this.id,
    this.createdBy,
    this.date,
    this.startTime,
    this.endTime,
    this.isTimeUndefined = false,
    this.location,
    this.locationDetails,
    this.latitude,
    this.longitude,
    this.category,
    this.subcategory,
    this.description,
    this.budget,
    this.paymentMethod,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'is_time_undefined': isTimeUndefined,
      'location': location,
      'location_details': locationDetails,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'budget': budget,
      'payment_method': paymentMethod,
      'image': image,
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      createdBy: json['created_by'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isTimeUndefined: json['is_time_undefined'] ?? false,
      location: json['location'],
      locationDetails: json['location_details'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      category: json['category'],
      subcategory: json['subcategory'],
      description: json['description'],
      budget: json['budget'],
      paymentMethod: json['payment_method'],
      image: json['image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  bool isStep1Complete() {
    if (isTimeUndefined) {
      return date != null && date!.isNotEmpty;
    }
    return date != null &&
        date!.isNotEmpty &&
        startTime != null &&
        startTime!.isNotEmpty &&
        endTime != null &&
        endTime!.isNotEmpty;
  }

  bool isStep2Complete() {
    return location != null &&
        location!.isNotEmpty &&
        locationDetails != null &&
        locationDetails!.isNotEmpty;
  }

  bool isStep3Complete() {
    return category != null &&
        category!.isNotEmpty &&
        subcategory != null &&
        subcategory!.isNotEmpty &&
        budget != null &&
        budget!.isNotEmpty &&
        paymentMethod != null &&
        paymentMethod!.isNotEmpty;
  }
}
