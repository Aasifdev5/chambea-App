class ServiceRequest {
  String? startTime;
  String? endTime;
  bool isTimeUndefined;
  String? location;
  String? locationDetails;
  String? category;
  String? subcategory;
  String? description;
  String? budget;
  String? paymentMethod;

  ServiceRequest({
    this.startTime,
    this.endTime,
    this.isTimeUndefined = false,
    this.location,
    this.locationDetails,
    this.category,
    this.subcategory,
    this.description,
    this.budget,
    this.paymentMethod,
  });

  // Method to check if Step 1 is complete
  bool isStep1Complete() {
    if (isTimeUndefined) return true;
    return startTime != null &&
        startTime!.isNotEmpty &&
        endTime != null &&
        endTime!.isNotEmpty;
  }

  // Method to check if Step 2 is complete
  bool isStep2Complete() {
    return location != null &&
        location!.isNotEmpty &&
        locationDetails != null &&
        locationDetails!.isNotEmpty;
  }

  // Method to check if Step 3 is complete
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
