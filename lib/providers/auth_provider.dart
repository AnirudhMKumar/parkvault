import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String get userRole => _currentUser?.role ?? '';
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isOperator => _currentUser?.role == 'operator';
  bool get isValet => _currentUser?.role == 'valet';

  Future<void> loadSession() async {
    _currentUser = await _authService.getLoggedInUser();
    notifyListeners();
  }

  Future<bool> setup({
    required String companyName,
    required String companyCode,
    required String username,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.completeSetup(
        companyName: companyName,
        companyCode: companyCode,
        username: username,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
    required String companyCode,
    required String role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _authService.login(
        username: username,
        password: password,
        companyCode: companyCode,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> isAppInitialized() async {
    return _authService.isAppInitialized();
  }
}
