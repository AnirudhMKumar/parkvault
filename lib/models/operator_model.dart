class OperatorModel {
  final String operatorId;
  final String name;
  final String mobile;
  final String role;
  final String shiftTiming;

  OperatorModel({
    required this.operatorId,
    required this.name,
    required this.mobile,
    required this.role,
    required this.shiftTiming,
  });

  Map<String, dynamic> toJson() => {
    'operatorId': operatorId,
    'name': name,
    'mobile': mobile,
    'role': role,
    'shiftTiming': shiftTiming,
  };

  factory OperatorModel.fromJson(Map<String, dynamic> json) => OperatorModel(
    operatorId: json['operatorId'] as String,
    name: json['name'] as String,
    mobile: json['mobile'] as String,
    role: json['role'] as String,
    shiftTiming: json['shiftTiming'] as String,
  );
}
