class SettingsModel {
  final String companyName;
  final String companyCode;
  final String selectedLocation;
  final double bikeFee;
  final double carFee;
  final double taxiFee;
  final double busTruckFee;
  final double miniBusFee;
  final double suvFee;
  final int twoWheelerCapacity;
  final int fourWheelerCapacity;
  final int otherCapacity;
  final String ticketPrefix;
  final bool qrEnabled;
  final bool valetEnabled;
  final bool fastagEnabled;
  final double firstHourCharge;
  final double additionalHourCharge;
  final double fullDayCharge;
  final double nightCharge;
  final double lostTicketCharge;
  final double valetCharge;
  final String version;

  SettingsModel({
    this.companyName = '',
    this.companyCode = '',
    this.selectedLocation = '',
    this.bikeFee = 20.0,
    this.carFee = 40.0,
    this.taxiFee = 50.0,
    this.busTruckFee = 100.0,
    this.miniBusFee = 80.0,
    this.suvFee = 60.0,
    this.twoWheelerCapacity = 50,
    this.fourWheelerCapacity = 100,
    this.otherCapacity = 20,
    this.ticketPrefix = 'SP',
    this.qrEnabled = true,
    this.valetEnabled = true,
    this.fastagEnabled = true,
    this.firstHourCharge = 40.0,
    this.additionalHourCharge = 20.0,
    this.fullDayCharge = 200.0,
    this.nightCharge = 100.0,
    this.lostTicketCharge = 200.0,
    this.valetCharge = 50.0,
    this.version = '1.0.0',
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'companyCode': companyCode,
    'selectedLocation': selectedLocation,
    'bikeFee': bikeFee,
    'carFee': carFee,
    'taxiFee': taxiFee,
    'busTruckFee': busTruckFee,
    'miniBusFee': miniBusFee,
    'suvFee': suvFee,
    'twoWheelerCapacity': twoWheelerCapacity,
    'fourWheelerCapacity': fourWheelerCapacity,
    'otherCapacity': otherCapacity,
    'ticketPrefix': ticketPrefix,
    'qrEnabled': qrEnabled,
    'valetEnabled': valetEnabled,
    'fastagEnabled': fastagEnabled,
    'firstHourCharge': firstHourCharge,
    'additionalHourCharge': additionalHourCharge,
    'fullDayCharge': fullDayCharge,
    'nightCharge': nightCharge,
    'lostTicketCharge': lostTicketCharge,
    'valetCharge': valetCharge,
    'version': version,
  };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    companyName: json['companyName'] as String? ?? '',
    companyCode: json['companyCode'] as String? ?? '',
    selectedLocation: json['selectedLocation'] as String? ?? '',
    bikeFee: (json['bikeFee'] as num?)?.toDouble() ?? 20.0,
    carFee: (json['carFee'] as num?)?.toDouble() ?? 40.0,
    taxiFee: (json['taxiFee'] as num?)?.toDouble() ?? 50.0,
    busTruckFee: (json['busTruckFee'] as num?)?.toDouble() ?? 100.0,
    miniBusFee: (json['miniBusFee'] as num?)?.toDouble() ?? 80.0,
    suvFee: (json['suvFee'] as num?)?.toDouble() ?? 60.0,
    twoWheelerCapacity: json['twoWheelerCapacity'] as int? ?? 50,
    fourWheelerCapacity: json['fourWheelerCapacity'] as int? ?? 100,
    otherCapacity: json['otherCapacity'] as int? ?? 20,
    ticketPrefix: json['ticketPrefix'] as String? ?? 'SP',
    qrEnabled: json['qrEnabled'] as bool? ?? true,
    valetEnabled: json['valetEnabled'] as bool? ?? true,
    fastagEnabled: json['fastagEnabled'] as bool? ?? true,
    firstHourCharge: (json['firstHourCharge'] as num?)?.toDouble() ?? 40.0,
    additionalHourCharge:
        (json['additionalHourCharge'] as num?)?.toDouble() ?? 20.0,
    fullDayCharge: (json['fullDayCharge'] as num?)?.toDouble() ?? 200.0,
    nightCharge: (json['nightCharge'] as num?)?.toDouble() ?? 100.0,
    lostTicketCharge: (json['lostTicketCharge'] as num?)?.toDouble() ?? 200.0,
    valetCharge: (json['valetCharge'] as num?)?.toDouble() ?? 50.0,
    version: json['version'] as String? ?? '1.0.0',
  );
}
