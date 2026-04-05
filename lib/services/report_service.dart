import 'dart:convert';
import 'package:intl/intl.dart';
import '../constants/storage_keys.dart';
import '../models/vehicle_entry_model.dart';
import '../models/fastag_entry_model.dart';
import '../models/valet_task_model.dart';
import 'local_storage_service.dart';

class ReportService {
  final LocalStorageService _storage = LocalStorageService();

  Future<Map<String, dynamic>> getRevenueReport({
    String period = 'daily',
  }) async {
    final entries = await _storage.getList(
      StorageKeys.vehicleEntries,
      VehicleEntryModel.fromJson,
    );
    final fastagEntries = await _storage.getList(
      StorageKeys.fastagEntries,
      FastagEntryModel.fromJson,
    );
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'weekly':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'monthly':
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    double normalRevenue = 0;
    double fastagRevenue = 0;
    int totalEntries = 0;
    int totalExits = 0;

    for (final entry in entries) {
      final entryDate = DateTime.parse(entry.entryTime);
      if (entryDate.isAfter(startDate)) {
        totalEntries++;
        if (entry.exitTime != null) {
          totalExits++;
          normalRevenue += entry.amount ?? 0;
        }
      }
    }

    for (final entry in fastagEntries) {
      final entryDate = DateTime.parse(entry.entryTime);
      if (entryDate.isAfter(startDate)) {
        totalEntries++;
        if (entry.exitTime != null) {
          totalExits++;
          fastagRevenue += entry.amount ?? 0;
        }
      }
    }

    return {
      'normalRevenue': normalRevenue,
      'fastagRevenue': fastagRevenue,
      'totalRevenue': normalRevenue + fastagRevenue,
      'totalEntries': totalEntries,
      'totalExits': totalExits,
      'period': period,
    };
  }

  Future<Map<String, dynamic>> getEntryExitReport() async {
    final entries = await _storage.getList(
      StorageKeys.vehicleEntries,
      VehicleEntryModel.fromJson,
    );
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayEntries = entries
        .where((e) => e.entryTime.startsWith(today))
        .toList();
    final todayExits = entries
        .where((e) => e.exitTime != null && e.exitTime!.startsWith(today))
        .toList();
    final activeParked = entries.where((e) => e.status == 'parked').toList();

    final vehicleTypeBreakdown = <String, int>{};
    for (final entry in entries) {
      vehicleTypeBreakdown[entry.vehicleType] =
          (vehicleTypeBreakdown[entry.vehicleType] ?? 0) + 1;
    }

    return {
      'todayEntries': todayEntries.length,
      'todayExits': todayExits.length,
      'activeParked': activeParked.length,
      'totalEntries': entries.length,
      'totalExits': entries.where((e) => e.status == 'exited').length,
      'vehicleTypeBreakdown': vehicleTypeBreakdown,
    };
  }

  Future<Map<String, dynamic>> getValetReport() async {
    final tasks = await _storage.getList(
      StorageKeys.valetTasks,
      ValetTaskModel.fromJson,
    );
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayTasks = tasks
        .where((t) => t.createdAt.startsWith(today))
        .toList();
    final delivered = tasks.where((t) => t.status == 'delivered').length;

    final driverStats = <String, int>{};
    for (final task in tasks) {
      if (task.driverId != null) {
        driverStats[task.driverId!] = (driverStats[task.driverId!] ?? 0) + 1;
      }
    }

    return {
      'totalTasks': tasks.length,
      'todayTasks': todayTasks.length,
      'delivered': delivered,
      'pending': tasks.where((t) => t.status != 'delivered').length,
      'driverStats': driverStats,
    };
  }

  Future<Map<String, dynamic>> getFastagReport() async {
    final entries = await _storage.getList(
      StorageKeys.fastagEntries,
      FastagEntryModel.fromJson,
    );
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayEntries = entries
        .where((e) => e.entryTime.startsWith(today))
        .toList();
    final totalRevenue = entries.fold<double>(
      0,
      (sum, e) => sum + (e.amount ?? 0),
    );

    return {
      'totalTransactions': entries.length,
      'todayTransactions': todayEntries.length,
      'active': entries.where((e) => e.status == 'active').length,
      'totalRevenue': totalRevenue,
    };
  }

  Future<Map<String, dynamic>> getFullDashboardStats() async {
    final revenue = await getRevenueReport(period: 'daily');
    final entryExit = await getEntryExitReport();
    final valet = await getValetReport();
    final fastag = await getFastagReport();

    return {...revenue, ...entryExit, 'valet': valet, 'fastag': fastag};
  }
}
