class DriverModel {
  final String driverId;
  final String name;
  final String contactNumber;
  final String employeeId;
  final double rating;
  final int carsHandled;
  final bool isOnDuty;

  DriverModel({
    required this.driverId,
    required this.name,
    required this.contactNumber,
    required this.employeeId,
    this.rating = 0.0,
    this.carsHandled = 0,
    this.isOnDuty = false,
  });

  Map<String, dynamic> toJson() => {
    'driverId': driverId,
    'name': name,
    'contactNumber': contactNumber,
    'employeeId': employeeId,
    'rating': rating,
    'carsHandled': carsHandled,
    'isOnDuty': isOnDuty,
  };

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
    driverId: json['driverId'] as String,
    name: json['name'] as String,
    contactNumber: json['contactNumber'] as String,
    employeeId: json['employeeId'] as String,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    carsHandled: json['carsHandled'] as int? ?? 0,
    isOnDuty: json['isOnDuty'] as bool? ?? false,
  );
}
