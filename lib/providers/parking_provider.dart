import 'package:flutter/foundation.dart';
import '../models/vehicle_entry_model.dart';
import '../models/settings_model.dart';
import '../services/parking_service.dart';

class ParkingProvider extends ChangeNotifier {
  final ParkingService _parkingService = ParkingService();
  List<VehicleEntryModel> _entries = [];
  Map<String, dynamic> _todayStats = {};
  bool _isLoading = false;
  String? _error;

  List<VehicleEntryModel> get entries => _entries;
  List<VehicleEntryModel> get activeEntries =>
      _entries.where((e) => e.status == 'parked').toList();
  Map<String, dynamic> get todayStats => _todayStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _entries = await _parkingService.getAllEntries();
      _todayStats = await _parkingService.getTodayStats();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addEntry({
    required String vehicleNumber,
    required String vehicleType,
    String? locationId,
    String? slotNumber,
    String? passId,
    String? paymentType,
    String? notes,
    String? imagePath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _parkingService.addEntry(
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        locationId: locationId,
        slotNumber: slotNumber,
        passId: passId,
        paymentType: paymentType,
        notes: notes,
        imagePath: imagePath,
      );
      await loadEntries();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> processExit(String ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _parkingService.processExit(ticketId);
      await loadEntries();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<VehicleEntryModel>> searchEntries(String query) async {
    return _parkingService.searchEntries(query);
  }

  Future<VehicleEntryModel?> getEntryByQR(String qrCode) async {
    return _parkingService.getEntryByQR(qrCode);
  }

  Future<SettingsModel> getSettings() async {
    return _parkingService.getSettings();
  }
}
