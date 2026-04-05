class FastagEntryModel {
  final String fastagId;
  final String vehicleNumber;
  final String entryTime;
  final String? exitTime;
  final double? amount;
  final String status;
  final List<String>? transactionLog;

  FastagEntryModel({
    required this.fastagId,
    required this.vehicleNumber,
    required this.entryTime,
    this.exitTime,
    this.amount,
    this.status = 'active',
    this.transactionLog,
  });

  Map<String, dynamic> toJson() => {
    'fastagId': fastagId,
    'vehicleNumber': vehicleNumber,
    'entryTime': entryTime,
    'exitTime': exitTime,
    'amount': amount,
    'status': status,
    'transactionLog': transactionLog,
  };

  factory FastagEntryModel.fromJson(Map<String, dynamic> json) =>
      FastagEntryModel(
        fastagId: json['fastagId'] as String,
        vehicleNumber: json['vehicleNumber'] as String,
        entryTime: json['entryTime'] as String,
        exitTime: json['exitTime'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'active',
        transactionLog: json['transactionLog'] != null
            ? List<String>.from(json['transactionLog'] as List)
            : null,
      );
}
