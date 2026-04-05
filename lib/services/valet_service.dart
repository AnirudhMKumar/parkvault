import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/storage_keys.dart';
import '../models/valet_task_model.dart';
import '../models/driver_model.dart';
import 'local_storage_service.dart';

class ValetService {
  final LocalStorageService _storage = LocalStorageService();
  static const _uuid = Uuid();

  Future<ValetTaskModel> createTask({
    required String vehicleNumber,
    String? ticketId,
    String? customerName,
    String? mobile,
    String? vehicleModel,
    String? belongingsNotes,
    String? kmReading,
    String? keyNumber,
    String? bayNumber,
    String? driverId,
    String requestType = 'park',
  }) async {
    final tasks = await _storage.getList(
      StorageKeys.valetTasks,
      ValetTaskModel.fromJson,
    );
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final otp = _generateOTP();

    final task = ValetTaskModel(
      taskId: 'VT${_uuid.v4().substring(0, 6).toUpperCase()}',
      vehicleNumber: vehicleNumber.toUpperCase(),
      ticketId: ticketId,
      keyNumber: keyNumber,
      bayNumber: bayNumber,
      driverId: driverId,
      customerName: customerName,
      mobile: mobile,
      vehicleModel: vehicleModel,
      belongingsNotes: belongingsNotes,
      kmReading: kmReading,
      otp: otp,
      requestType: requestType,
      status: 'vehicle_in',
      createdAt: now,
    );

    tasks.add(task);
    await _storage.setList(StorageKeys.valetTasks, tasks, (t) => t.toJson());
    return task;
  }

  Future<ValetTaskModel> updateStatus(String taskId, String newStatus) async {
    final tasks = await _storage.getList(
      StorageKeys.valetTasks,
      ValetTaskModel.fromJson,
    );
    final index = tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) throw Exception('Task not found');

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    tasks[index] = ValetTaskModel(
      taskId: tasks[index].taskId,
      vehicleNumber: tasks[index].vehicleNumber,
      ticketId: tasks[index].ticketId,
      keyNumber: tasks[index].keyNumber,
      bayNumber: tasks[index].bayNumber,
      driverId: tasks[index].driverId,
      customerName: tasks[index].customerName,
      mobile: tasks[index].mobile,
      vehicleModel: tasks[index].vehicleModel,
      belongingsNotes: tasks[index].belongingsNotes,
      kmReading: tasks[index].kmReading,
      otp: tasks[index].otp,
      requestType: tasks[index].requestType,
      status: newStatus,
      createdAt: tasks[index].createdAt,
      updatedAt: now,
    );

    await _storage.setList(StorageKeys.valetTasks, tasks, (t) => t.toJson());
    return tasks[index];
  }

  Future<ValetTaskModel> assignDriver(String taskId, String driverId) async {
    final tasks = await _storage.getList(
      StorageKeys.valetTasks,
      ValetTaskModel.fromJson,
    );
    final index = tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) throw Exception('Task not found');

    tasks[index] = ValetTaskModel(
      taskId: tasks[index].taskId,
      vehicleNumber: tasks[index].vehicleNumber,
      ticketId: tasks[index].ticketId,
      keyNumber: tasks[index].keyNumber,
      bayNumber: tasks[index].bayNumber,
      driverId: driverId,
      customerName: tasks[index].customerName,
      mobile: tasks[index].mobile,
      vehicleModel: tasks[index].vehicleModel,
      belongingsNotes: tasks[index].belongingsNotes,
      kmReading: tasks[index].kmReading,
      otp: tasks[index].otp,
      requestType: tasks[index].requestType,
      status: tasks[index].status,
      createdAt: tasks[index].createdAt,
      updatedAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    await _storage.setList(StorageKeys.valetTasks, tasks, (t) => t.toJson());
    return tasks[index];
  }

  Future<List<ValetTaskModel>> getAllTasks() async {
    return _storage.getList(StorageKeys.valetTasks, ValetTaskModel.fromJson);
  }

  Future<List<ValetTaskModel>> getTasksByStatus(String status) async {
    final tasks = await getAllTasks();
    return tasks.where((t) => t.status == status).toList();
  }

  Future<List<ValetTaskModel>> getTasksByDriver(String driverId) async {
    final tasks = await getAllTasks();
    return tasks.where((t) => t.driverId == driverId).toList();
  }

  Future<ValetTaskModel?> findTaskByOTP(String otp) async {
    final tasks = await getAllTasks();
    try {
      return tasks.firstWhere((t) => t.otp == otp && t.status != 'delivered');
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, int>> getValetStats() async {
    final tasks = await getAllTasks();
    return {
      'vehicle_in': tasks.where((t) => t.status == 'vehicle_in').length,
      'parked': tasks.where((t) => t.status == 'parked').length,
      'out_request': tasks.where((t) => t.status == 'out_request').length,
      'ready_to_out': tasks.where((t) => t.status == 'ready_to_out').length,
      'delivered': tasks.where((t) => t.status == 'delivered').length,
    };
  }

  Future<void> resetTasks() async {
    await _storage.setList(
      StorageKeys.valetTasks,
      <ValetTaskModel>[],
      (t) => t.toJson(),
    );
  }

  Future<bool> addDriver(DriverModel driver) async {
    final drivers = await _storage.getList(
      StorageKeys.driversList,
      DriverModel.fromJson,
    );
    if (drivers.any((d) => d.employeeId == driver.employeeId)) return false;
    drivers.add(driver);
    return _storage.setList(
      StorageKeys.driversList,
      drivers,
      (d) => d.toJson(),
    );
  }

  Future<List<DriverModel>> getAllDrivers() async {
    return _storage.getList(StorageKeys.driversList, DriverModel.fromJson);
  }

  Future<bool> updateDriver(DriverModel driver) async {
    final drivers = await _storage.getList(
      StorageKeys.driversList,
      DriverModel.fromJson,
    );
    final index = drivers.indexWhere((d) => d.driverId == driver.driverId);
    if (index == -1) return false;
    drivers[index] = driver;
    return _storage.setList(
      StorageKeys.driversList,
      drivers,
      (d) => d.toJson(),
    );
  }

  Future<bool> toggleDriverDuty(String driverId) async {
    final drivers = await getAllDrivers();
    final index = drivers.indexWhere((d) => d.driverId == driverId);
    if (index == -1) return false;
    drivers[index] = DriverModel(
      driverId: drivers[index].driverId,
      name: drivers[index].name,
      contactNumber: drivers[index].contactNumber,
      employeeId: drivers[index].employeeId,
      rating: drivers[index].rating,
      carsHandled: drivers[index].carsHandled,
      isOnDuty: !drivers[index].isOnDuty,
    );
    return _storage.setList(
      StorageKeys.driversList,
      drivers,
      (d) => d.toJson(),
    );
  }

  Future<bool> deleteDriver(String driverId) async {
    final drivers = await getAllDrivers();
    drivers.removeWhere((d) => d.driverId == driverId);
    return _storage.setList(
      StorageKeys.driversList,
      drivers,
      (d) => d.toJson(),
    );
  }

  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
