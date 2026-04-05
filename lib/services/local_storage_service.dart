import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return _prefs!.setString(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return _prefs!.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return _prefs!.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return _prefs!.setDouble(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return _prefs!.remove(key);
  }

  Future<bool> clear() async {
    await _ensureInitialized();
    return _prefs!.clear();
  }

  Future<List<T>> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final data = getString(key);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> setList<T>(
    String key,
    List<T> list,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final jsonString = jsonEncode(list.map((e) => toJson(e)).toList());
    return setString(key, jsonString);
  }

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
