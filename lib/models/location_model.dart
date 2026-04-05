class LocationModel {
  final String locationId;
  final String name;
  final int totalSlots;
  final int occupiedSlots;
  final int twoWheelerCapacity;
  final int fourWheelerCapacity;
  final int otherCapacity;

  LocationModel({
    required this.locationId,
    required this.name,
    required this.totalSlots,
    this.occupiedSlots = 0,
    this.twoWheelerCapacity = 50,
    this.fourWheelerCapacity = 100,
    this.otherCapacity = 20,
  });

  Map<String, dynamic> toJson() => {
    'locationId': locationId,
    'name': name,
    'totalSlots': totalSlots,
    'occupiedSlots': occupiedSlots,
    'twoWheelerCapacity': twoWheelerCapacity,
    'fourWheelerCapacity': fourWheelerCapacity,
    'otherCapacity': otherCapacity,
  };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    locationId: json['locationId'] as String,
    name: json['name'] as String,
    totalSlots: json['totalSlots'] as int,
    occupiedSlots: json['occupiedSlots'] as int? ?? 0,
    twoWheelerCapacity: json['twoWheelerCapacity'] as int? ?? 50,
    fourWheelerCapacity: json['fourWheelerCapacity'] as int? ?? 100,
    otherCapacity: json['otherCapacity'] as int? ?? 20,
  );

  int get availableSlots => totalSlots - occupiedSlots;
}
