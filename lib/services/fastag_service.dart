import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/storage_keys.dart';
import '../models/fastag_entry_model.dart';
import '../models/settings_model.dart';
import 'local_storage_service.dart';

class FastagService {
  final LocalStorageService _storage = LocalStorageService();
  static const _uuid = Uuid();

  Future<FastagEntryModel> addEntry({
    required String fastagId,
    required String vehicleNumber,
  }) async {
    final entries = await _storage.getList(
      StorageKeys.fastagEntries,
      FastagEntryModel.fromJson,
    );
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final entry = FastagEntryModel(
      fastagId: fastagId,
      vehicleNumber: vehicleNumber.toUpperCase(),
      entryTime: now,
      status: 'active',
      transactionLog: ['Entry at $now'],
    );

    entries.add(entry);
    await _storage.setList(
      StorageKeys.fastagEntries,
      entries,
      (e) => e.toJson(),
    );
    return entry;
  }

  Future<FastagEntryModel> processExit(String fastagId) async {
    final entries = await _storage.getList(
      StorageKeys.fastagEntries,
      FastagEntryModel.fromJson,
    );
    final settings = await _getSettings();

    final index = entries.indexWhere(
      (e) => e.fastagId == fastagId && e.status == 'active',
    );
    if (index == -1) throw Exception('No active FASTag record found');

    final entry = entries[index];
    final now = DateTime.now();
    final entryTime = DateTime.parse(entry.entryTime);
    final durationMinutes = now.difference(entryTime).inMinutes;

    double fee = _calculateFee(durationMinutes, settings);

    final updatedEntry = FastagEntryModel(
      fastagId: entry.fastagId,
      vehicleNumber: entry.vehicleNumber,
      entryTime: entry.entryTime,
      exitTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
      amount: fee,
      status: 'exited',
      transactionLog: [
        ...?entry.transactionLog,
        'Exit at ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)} - Fee: ₹$fee',
      ],
    );

    entries[index] = updatedEntry;
    await _storage.setList(
      StorageKeys.fastagEntries,
      entries,
      (e) => e.toJson(),
    );
    return updatedEntry;
  }

  Future<List<FastagEntryModel>> getAllEntries() async {
    return _storage.getList(
      StorageKeys.fastagEntries,
      FastagEntryModel.fromJson,
    );
  }

  Future<List<FastagEntryModel>> getActiveEntries() async {
    final entries = await getAllEntries();
    return entries.where((e) => e.status == 'active').toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final entries = await getAllEntries();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayEntries = entries
        .where((e) => e.entryTime.startsWith(today))
        .toList();
    final todayExits = entries
        .where((e) => e.exitTime != null && e.exitTime!.startsWith(today))
        .toList();
    final totalRevenue = todayExits.fold<double>(
      0,
      (sum, e) => sum + (e.amount ?? 0),
    );

    return {
      'totalEntries': todayEntries.length,
      'totalExits': todayExits.length,
      'active': entries.where((e) => e.status == 'active').length,
      'revenue': totalRevenue,
    };
  }

  Future<void> resetEntries() async {
    await _storage.setList(
      StorageKeys.fastagEntries,
      <FastagEntryModel>[],
      (e) => e.toJson(),
    );
  }

  double _calculateFee(int durationMinutes, SettingsModel settings) {
    final hours = durationMinutes / 60;
    if (hours <= 1) return settings.firstHourCharge;
    if (hours <= 24)
      return settings.firstHourCharge +
          ((hours - 1).ceil() * settings.additionalHourCharge);
    return settings.fullDayCharge * (hours / 24).ceil();
  }

  Future<SettingsModel> _getSettings() async {
    final data = _storage.getString(StorageKeys.settingsData);
    if (data == null) return SettingsModel();
    return SettingsModel.fromJson(jsonDecode(data));
  }
}
