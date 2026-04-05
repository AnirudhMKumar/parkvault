import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../models/location_model.dart';
import '../models/operator_model.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  SettingsModel _settings = SettingsModel();
  List<LocationModel> _locations = [];
  List<OperatorModel> _operators = [];
  bool _isLoading = false;
  String? _error;

  SettingsModel get settings => _settings;
  List<LocationModel> get locations => _locations;
  List<OperatorModel> get operators => _operators;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _settings = await _settingsService.getSettings();
      _locations = await _settingsService.getAllLocations();
      _operators = await _settingsService.getAllOperators();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveSettings(SettingsModel settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.saveSettings(settings);
      if (result) _settings = settings;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addLocation(LocationModel location) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.addLocation(location);
      if (result) await loadSettings();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLocation(LocationModel location) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.updateLocation(location);
      if (result) await loadSettings();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLocation(String locationId) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.deleteLocation(locationId);
      if (result) await loadSettings();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addOperator(OperatorModel operator) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.addOperator(operator);
      if (result) await loadSettings();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOperator(OperatorModel operator) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.updateOperator(operator);
      if (result) await loadSettings();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOperator(String operatorId) async {
    _error = null;
    notifyListeners();
    try {
      final result = await _settingsService.deleteOperator(operatorId);
      if (result) await loadSettings();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> resetAllData() async {
    await _settingsService.resetAllData();
    _settings = SettingsModel();
    _locations = [];
    _operators = [];
    notifyListeners();
  }
}
