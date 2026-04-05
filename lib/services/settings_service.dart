import 'dart:convert';
import '../constants/storage_keys.dart';
import '../models/location_model.dart';
import '../models/operator_model.dart';
import '../models/settings_model.dart';
import 'local_storage_service.dart';

class SettingsService {
  final LocalStorageService _storage = LocalStorageService();

  Future<SettingsModel> getSettings() async {
    final data = _storage.getString(StorageKeys.settingsData);
    if (data == null) return SettingsModel();
    return SettingsModel.fromJson(jsonDecode(data));
  }

  Future<bool> saveSettings(SettingsModel settings) async {
    return _storage.setString(
      StorageKeys.settingsData,
      jsonEncode(settings.toJson()),
    );
  }

  Future<bool> addLocation(LocationModel location) async {
    final locations = await _storage.getList(
      StorageKeys.locationsList,
      LocationModel.fromJson,
    );
    if (locations.any(
      (l) => l.name.toLowerCase() == location.name.toLowerCase(),
    ))
      return false;
    locations.add(location);
    return _storage.setList(
      StorageKeys.locationsList,
      locations,
      (l) => l.toJson(),
    );
  }

  Future<List<LocationModel>> getAllLocations() async {
    return _storage.getList(StorageKeys.locationsList, LocationModel.fromJson);
  }

  Future<bool> updateLocation(LocationModel location) async {
    final locations = await _storage.getList(
      StorageKeys.locationsList,
      LocationModel.fromJson,
    );
    final index = locations.indexWhere(
      (l) => l.locationId == location.locationId,
    );
    if (index == -1) return false;
    locations[index] = location;
    return _storage.setList(
      StorageKeys.locationsList,
      locations,
      (l) => l.toJson(),
    );
  }

  Future<bool> deleteLocation(String locationId) async {
    final locations = await getAllLocations();
    locations.removeWhere((l) => l.locationId == locationId);
    return _storage.setList(
      StorageKeys.locationsList,
      locations,
      (l) => l.toJson(),
    );
  }

  Future<bool> addOperator(OperatorModel operator) async {
    final operators = await _storage.getList(
      StorageKeys.operatorsList,
      OperatorModel.fromJson,
    );
    if (operators.any((o) => o.operatorId == operator.operatorId)) return false;
    operators.add(operator);
    return _storage.setList(
      StorageKeys.operatorsList,
      operators,
      (o) => o.toJson(),
    );
  }

  Future<List<OperatorModel>> getAllOperators() async {
    return _storage.getList(StorageKeys.operatorsList, OperatorModel.fromJson);
  }

  Future<bool> updateOperator(OperatorModel operator) async {
    final operators = await _storage.getList(
      StorageKeys.operatorsList,
      OperatorModel.fromJson,
    );
    final index = operators.indexWhere(
      (o) => o.operatorId == operator.operatorId,
    );
    if (index == -1) return false;
    operators[index] = operator;
    return _storage.setList(
      StorageKeys.operatorsList,
      operators,
      (o) => o.toJson(),
    );
  }

  Future<bool> deleteOperator(String operatorId) async {
    final operators = await getAllOperators();
    operators.removeWhere((o) => o.operatorId == operatorId);
    return _storage.setList(
      StorageKeys.operatorsList,
      operators,
      (o) => o.toJson(),
    );
  }

  Future<void> resetAllData() async {
    await _storage.clear();
  }

  Future<void> resetEntries() async {
    await _storage.setList(StorageKeys.vehicleEntries, <dynamic>[], (e) => {});
  }

  Future<void> resetPasses() async {
    await _storage.setList(StorageKeys.passesList, <dynamic>[], (p) => {});
  }

  Future<void> resetValetTasks() async {
    await _storage.setList(StorageKeys.valetTasks, <dynamic>[], (t) => {});
  }
}
