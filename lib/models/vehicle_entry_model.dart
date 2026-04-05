class VehicleEntryModel {
  final String ticketId;
  final String vehicleNumber;
  final String vehicleType;
  final String entryTime;
  final String? exitTime;
  final String status;
  final double? amount;
  final int? durationMinutes;
  final String? imagePath;
  final String? qrCode;
  final String? passId;
  final String? locationId;
  final String? slotNumber;
  final String? paymentType;
  final String? notes;

  VehicleEntryModel({
    required this.ticketId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.entryTime,
    this.exitTime,
    this.status = 'parked',
    this.amount,
    this.durationMinutes,
    this.imagePath,
    this.qrCode,
    this.passId,
    this.locationId,
    this.slotNumber,
    this.paymentType,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'ticketId': ticketId,
    'vehicleNumber': vehicleNumber,
    'vehicleType': vehicleType,
    'entryTime': entryTime,
    'exitTime': exitTime,
    'status': status,
    'amount': amount,
    'durationMinutes': durationMinutes,
    'imagePath': imagePath,
    'qrCode': qrCode,
    'passId': passId,
    'locationId': locationId,
    'slotNumber': slotNumber,
    'paymentType': paymentType,
    'notes': notes,
  };

  factory VehicleEntryModel.fromJson(Map<String, dynamic> json) =>
      VehicleEntryModel(
        ticketId: json['ticketId'] as String,
        vehicleNumber: json['vehicleNumber'] as String,
        vehicleType: json['vehicleType'] as String,
        entryTime: json['entryTime'] as String,
        exitTime: json['exitTime'] as String?,
        status: json['status'] as String? ?? 'parked',
        amount: (json['amount'] as num?)?.toDouble(),
        durationMinutes: json['durationMinutes'] as int?,
        imagePath: json['imagePath'] as String?,
        qrCode: json['qrCode'] as String?,
        passId: json['passId'] as String?,
        locationId: json['locationId'] as String?,
        slotNumber: json['slotNumber'] as String?,
        paymentType: json['paymentType'] as String?,
        notes: json['notes'] as String?,
      );

  VehicleEntryModel copyWith({
    String? ticketId,
    String? vehicleNumber,
    String? vehicleType,
    String? entryTime,
    String? exitTime,
    String? status,
    double? amount,
    int? durationMinutes,
    String? imagePath,
    String? qrCode,
    String? passId,
    String? locationId,
    String? slotNumber,
    String? paymentType,
    String? notes,
  }) {
    return VehicleEntryModel(
      ticketId: ticketId ?? this.ticketId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imagePath: imagePath ?? this.imagePath,
      qrCode: qrCode ?? this.qrCode,
      passId: passId ?? this.passId,
      locationId: locationId ?? this.locationId,
      slotNumber: slotNumber ?? this.slotNumber,
      paymentType: paymentType ?? this.paymentType,
      notes: notes ?? this.notes,
    );
  }
}
