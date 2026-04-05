import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/storage_keys.dart';
import '../models/pass_model.dart';
import '../models/settings_model.dart';
import '../models/vehicle_entry_model.dart';
import 'local_storage_service.dart';

class ParkingService {
  final LocalStorageService _storage = LocalStorageService();
  static const _uuid = Uuid();

  Future<VehicleEntryModel> addEntry({
    required String vehicleNumber,
    required String vehicleType,
    String? locationId,
    String? slotNumber,
    String? passId,
    String? paymentType,
    String? notes,
    String? imagePath,
  }) async {
    final entries = await _storage.getList(
      StorageKeys.vehicleEntries,
      VehicleEntryModel.fromJson,
    );

    final alreadyParked = entries.any(
      (e) =>
          e.vehicleNumber.toUpperCase() == vehicleNumber.toUpperCase() &&
          e.status == 'parked',
    );
    if (alreadyParked) {
      throw Exception('Vehicle already parked');
    }

    final settings = await getSettings();
    final ticketId =
        '${settings.ticketPrefix}${_generateSequence(entries.length + 1)}';
    final qrCode = _uuid.v4();
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final entry = VehicleEntryModel(
      ticketId: ticketId,
      vehicleNumber: vehicleNumber.toUpperCase(),
      vehicleType: vehicleType,
      entryTime: now,
      status: 'parked',
      qrCode: qrCode,
      passId: passId,
      locationId: locationId,
      slotNumber: slotNumber,
      paymentType: paymentType,
      notes: notes,
      imagePath: imagePath,
    );

    entries.add(entry);
    await _storage.setList(
      StorageKeys.vehicleEntries,
      entries,
      (e) => e.toJson(),
    );
    return entry;
  }

  Future<VehicleEntryModel> processExit(String ticketId) async {
    final entries = await _storage.getList(
      StorageKeys.vehicleEntries,
      VehicleEntryModel.fromJson,
    );
    final settings = await getSettings();

    final index = entries.indexWhere(
      (e) => e.ticketId == ticketId && e.status == 'parked',
    );
    if (index == -1) throw Exception('No active record found');

    final entry = entries[index];
    final now = DateTime.now();
    final entryTime = DateTime.parse(entry.entryTime);
    final durationMinutes = now.difference(entryTime).inMinutes;

    double fee = 0;
    if (entry.passId != null && entry.passId!.isNotEmpty) {
      final allPasses = await _storage.getList(
        StorageKeys.passesList,
        PassModel.fromJson,
      );
      final validPass = allPasses.where(
        (p) =>
            p.vehicleNumber.toUpperCase() == entry.vehicleNumber.toUpperCase() &&
            p.status == 'active' &&
            DateTime.parse(p.startDate).isBefore(now) &&
            DateTime.parse(p.endDate).isAfter(now),
      );
      if (validPass.isEmpty) {
        fee = _calculateFee(entry.vehicleType, durationMinutes, settings);
      }
    } else {
      fee = _calculateFee(entry.vehicleType, durationMinutes, settings);
    }

    final updatedEntry = entry.copyWith(
      exitTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      status: 'exited',
      amount: fee,
      durationMinutes: durationMinutes,
    );

    entries[index] = updatedEntry;
    await _storage.setList(
      StorageKeys.vehicleEntries,
      entries,
      (e) => e.toJson(),
    );
    return updatedEntry;
  }

  Future<List<VehicleEntryModel>> getAllEntries() async {
    return _storage.getList(
      StorageKeys.vehicleEntries,
      VehicleEntryModel.fromJson,
    );
  }

  Future<List<VehicleEntryModel>> getActiveEntries() async {
    final entries = await getAllEntries();
    return entries.where((e) => e.status == 'parked').toList();
  }

  Future<List<VehicleEntryModel>> searchEntries(String query) async {
    final entries = await getAllEntries();
    final q = query.toUpperCase();
    return entries
        .where(
          (e) =>
              e.vehicleNumber.contains(q) ||
              e.ticketId.toUpperCase().contains(q),
        )
        .toList();
  }

  Future<VehicleEntryModel?> getEntryByTicket(String ticketId) async {
    final entries = await getAllEntries();
    try {
      return entries.firstWhere((e) => e.ticketId == ticketId);
    } catch (e) {
      return null;
    }
  }

  Future<VehicleEntryModel?> getEntryByQR(String qrCode) async {
    final entries = await getAllEntries();
    try {
      return entries.firstWhere(
        (e) => e.qrCode == qrCode && e.status == 'parked',
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    final entries = await getAllEntries();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayEntries = entries
        .where((e) => e.entryTime.startsWith(today))
        .toList();
    final todayExits = entries
        .where((e) => e.exitTime != null && e.exitTime!.startsWith(today))
        .toList();
    final activeEntries = entries.where((e) => e.status == 'parked').toList();
    final totalRevenue = todayExits.fold<double>(
      0,
      (sum, e) => sum + (e.amount ?? 0),
    );

    final twoWheelers = activeEntries
        .where((e) => e.vehicleType == 'Bike')
        .length;
    final fourWheelers = activeEntries
        .where(
          (e) =>
              e.vehicleType == 'Car' ||
              e.vehicleType == 'SUV' ||
              e.vehicleType == 'Taxi',
        )
        .length;

    return {
      'totalEntries': todayEntries.length,
      'totalExits': todayExits.length,
      'activeParked': activeEntries.length,
      'revenue': totalRevenue,
      'twoWheelers': twoWheelers,
      'fourWheelers': fourWheelers,
    };
  }

  Future<void> resetEntries() async {
    await _storage.setList(
      StorageKeys.vehicleEntries,
      <VehicleEntryModel>[],
      (e) => e.toJson(),
    );
  }

  double _calculateFee(
    String vehicleType,
    int durationMinutes,
    SettingsModel settings,
  ) {
    final hours = durationMinutes / 60;
    double baseFee;

    switch (vehicleType) {
      case 'Bike':
        baseFee = settings.bikeFee;
        break;
      case 'Car':
        baseFee = settings.carFee;
        break;
      case 'Taxi':
        baseFee = settings.taxiFee;
        break;
      case 'SUV':
        baseFee = settings.suvFee;
        break;
      case 'Bus':
      case 'Truck':
        baseFee = settings.busTruckFee;
        break;
      case 'Mini Bus':
        baseFee = settings.miniBusFee;
        break;
      default:
        baseFee = settings.carFee;
    }

    if (hours <= 1) {
      return baseFee > 0 ? baseFee : settings.firstHourCharge;
    } else if (hours <= 24) {
      final firstHour = baseFee > 0 ? baseFee : settings.firstHourCharge;
      return firstHour +
          ((hours - 1).ceil() * settings.additionalHourCharge);
    } else {
      return settings.fullDayCharge * (hours / 24).ceil();
    }
  }

  Future<SettingsModel> getSettings() async {
    final data = _storage.getString(StorageKeys.settingsData);
    if (data == null) return SettingsModel();
    return SettingsModel.fromJson(jsonDecode(data));
  }

  String _generateSequence(int number) {
    return number.toString().padLeft(6, '0');
  }
}
