class PassModel {
  final String passId;
  final String customerName;
  final String mobileNumber;
  final String vehicleNumber;
  final String vehicleType;
  final String startDate;
  final String endDate;
  final double amount;
  final String status;
  final String? notes;
  final String passType;

  PassModel({
    required this.passId,
    required this.customerName,
    required this.mobileNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.status = 'active',
    this.notes,
    this.passType = 'Monthly',
  });

  Map<String, dynamic> toJson() => {
    'passId': passId,
    'customerName': customerName,
    'mobileNumber': mobileNumber,
    'vehicleNumber': vehicleNumber,
    'vehicleType': vehicleType,
    'startDate': startDate,
    'endDate': endDate,
    'amount': amount,
    'status': status,
    'notes': notes,
    'passType': passType,
  };

  factory PassModel.fromJson(Map<String, dynamic> json) => PassModel(
    passId: json['passId'] as String,
    customerName: json['customerName'] as String,
    mobileNumber: json['mobileNumber'] as String,
    vehicleNumber: json['vehicleNumber'] as String,
    vehicleType: json['vehicleType'] as String,
    startDate: json['startDate'] as String,
    endDate: json['endDate'] as String,
    amount: (json['amount'] as num).toDouble(),
    status: json['status'] as String? ?? 'active',
    notes: json['notes'] as String?,
    passType: json['passType'] as String? ?? 'Monthly',
  );
}
