import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../constants/storage_keys.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final LocalStorageService _storage = LocalStorageService();
  static const _uuid = Uuid();

  Future<bool> isAppInitialized() async {
    return _storage.getBool(StorageKeys.appInitialized) ?? false;
  }

  Future<bool> isFirstTime() async {
    return !await isAppInitialized();
  }

  Future<void> completeSetup({
    required String companyName,
    required String companyCode,
    required String username,
    required String password,
  }) async {
    final adminUser = UserModel(
      id: _uuid.v4(),
      username: username,
      password: password,
      companyCode: companyCode,
      role: 'admin',
      isLoggedIn: false,
    );

    final users = await _storage.getList(
      StorageKeys.usersList,
      UserModel.fromJson,
    );
    users.add(adminUser);
    await _storage.setList(StorageKeys.usersList, users, (u) => u.toJson());
    await _storage.setBool(StorageKeys.appInitialized, true);
  }

  Future<UserModel?> login({
    required String username,
    required String password,
    required String companyCode,
    required String role,
  }) async {
    final users = await _storage.getList(
      StorageKeys.usersList,
      UserModel.fromJson,
    );
    final user = users.firstWhere(
      (u) =>
          u.username.toLowerCase() == username.toLowerCase() &&
          u.password == password &&
          u.companyCode == companyCode &&
          u.role == role,
      orElse: () => throw Exception('Invalid credentials'),
    );

    final updatedUser = UserModel(
      id: user.id,
      username: user.username,
      password: user.password,
      companyCode: user.companyCode,
      role: user.role,
      isLoggedIn: true,
    );

    final updatedUsers = users
        .map((u) => u.id == user.id ? updatedUser : u)
        .toList();
    await _storage.setList(
      StorageKeys.usersList,
      updatedUsers,
      (u) => u.toJson(),
    );
    await _storage.setString(
      StorageKeys.loggedInUser,
      jsonEncode(updatedUser.toJson()),
    );

    return updatedUser;
  }

  Future<void> logout() async {
    await _storage.remove(StorageKeys.loggedInUser);
  }

  Future<UserModel?> getLoggedInUser() async {
    final data = _storage.getString(StorageKeys.loggedInUser);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  Future<bool> addUser(UserModel user) async {
    final users = await _storage.getList(
      StorageKeys.usersList,
      UserModel.fromJson,
    );
    if (users.any(
      (u) => u.username.toLowerCase() == user.username.toLowerCase(),
    )) {
      return false;
    }
    users.add(user);
    return _storage.setList(StorageKeys.usersList, users, (u) => u.toJson());
  }

  Future<List<UserModel>> getAllUsers() async {
    return _storage.getList(StorageKeys.usersList, UserModel.fromJson);
  }

  Future<bool> removeUser(String userId) async {
    final users = await _storage.getList(
      StorageKeys.usersList,
      UserModel.fromJson,
    );
    users.removeWhere((u) => u.id == userId);
    return _storage.setList(StorageKeys.usersList, users, (u) => u.toJson());
  }
}
