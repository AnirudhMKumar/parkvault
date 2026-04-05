import 'package:flutter/foundation.dart';
import '../models/valet_task_model.dart';
import '../models/driver_model.dart';
import '../services/valet_service.dart';

class ValetProvider extends ChangeNotifier {
  final ValetService _valetService = ValetService();
  List<ValetTaskModel> _tasks = [];
  List<DriverModel> _drivers = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;
  String? _error;

  List<ValetTaskModel> get tasks => _tasks;
  List<DriverModel> get drivers => _drivers;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ValetTaskModel> get vehicleInTasks =>
      _tasks.where((t) => t.status == 'vehicle_in').toList();
  List<ValetTaskModel> get parkedTasks =>
      _tasks.where((t) => t.status == 'parked').toList();
  List<ValetTaskModel> get outRequestTasks =>
      _tasks.where((t) => t.status == 'out_request').toList();
  List<ValetTaskModel> get readyToOutTasks =>
      _tasks.where((t) => t.status == 'ready_to_out').toList();
  List<ValetTaskModel> get deliveredTasks =>
      _tasks.where((t) => t.status == 'delivered').toList();

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _valetService.getAllTasks();
      _stats = await _valetService.getValetStats();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDrivers() async {
    _drivers = await _valetService.getAllDrivers();
    notifyListeners();
  }

  Future<bool> createTask({
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
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _valetService.createTask(
        vehicleNumber: vehicleNumber,
        ticketId: ticketId,
        customerName: customerName,
        mobile: mobile,
        vehicleModel: vehicleModel,
        belongingsNotes: belongingsNotes,
        kmReading: kmReading,
        keyNumber: keyNumber,
        bayNumber: bayNumber,
        driverId: driverId,
        requestType: requestType,
      );
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String taskId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _valetService.updateStatus(taskId, newStatus);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignDriver(String taskId, String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _valetService.assignDriver(taskId, driverId);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<ValetTaskModel?> findTaskByOTP(String otp) async {
    return _valetService.findTaskByOTP(otp);
  }

  Future<bool> addDriver(DriverModel driver) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _valetService.addDriver(driver);
      if (result) await loadDrivers();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleDriverDuty(String driverId) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _valetService.toggleDriverDuty(driverId);
      if (result) await loadDrivers();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDriver(String driverId) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _valetService.deleteDriver(driverId);
      if (result) await loadDrivers();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
