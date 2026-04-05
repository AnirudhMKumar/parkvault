class ValetTaskModel {
  final String taskId;
  final String vehicleNumber;
  final String? ticketId;
  final String? keyNumber;
  final String? bayNumber;
  final String? driverId;
  final String? customerName;
  final String? mobile;
  final String? vehicleModel;
  final String? belongingsNotes;
  final String? kmReading;
  final String? otp;
  final String requestType;
  final String status;
  final String createdAt;
  final String? updatedAt;

  ValetTaskModel({
    required this.taskId,
    required this.vehicleNumber,
    this.ticketId,
    this.keyNumber,
    this.bayNumber,
    this.driverId,
    this.customerName,
    this.mobile,
    this.vehicleModel,
    this.belongingsNotes,
    this.kmReading,
    this.otp,
    this.requestType = 'park',
    this.status = 'vehicle_in',
    this.createdAt = '',
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'vehicleNumber': vehicleNumber,
    'ticketId': ticketId,
    'keyNumber': keyNumber,
    'bayNumber': bayNumber,
    'driverId': driverId,
    'customerName': customerName,
    'mobile': mobile,
    'vehicleModel': vehicleModel,
    'belongingsNotes': belongingsNotes,
    'kmReading': kmReading,
    'otp': otp,
    'requestType': requestType,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ValetTaskModel.fromJson(Map<String, dynamic> json) => ValetTaskModel(
    taskId: json['taskId'] as String,
    vehicleNumber: json['vehicleNumber'] as String,
    ticketId: json['ticketId'] as String?,
    keyNumber: json['keyNumber'] as String?,
    bayNumber: json['bayNumber'] as String?,
    driverId: json['driverId'] as String?,
    customerName: json['customerName'] as String?,
    mobile: json['mobile'] as String?,
    vehicleModel: json['vehicleModel'] as String?,
    belongingsNotes: json['belongingsNotes'] as String?,
    kmReading: json['kmReading'] as String?,
    otp: json['otp'] as String?,
    requestType: json['requestType'] as String? ?? 'park',
    status: json['status'] as String? ?? 'vehicle_in',
    createdAt: json['createdAt'] as String? ?? '',
    updatedAt: json['updatedAt'] as String?,
  );
}
