import 'package:flutter/foundation.dart';
import '../models/pass_model.dart';
import '../services/pass_service.dart';

class PassProvider extends ChangeNotifier {
  final PassService _passService = PassService();
  List<PassModel> _passes = [];
  bool _isLoading = false;
  String? _error;

  List<PassModel> get passes => _passes;
  List<PassModel> get activePasses =>
      _passes.where((p) => p.status == 'active').toList();
  List<PassModel> get expiredPasses =>
      _passes.where((p) => p.status == 'expired').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _passes = await _passService.getAllPasses();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPass({
    required String customerName,
    required String mobileNumber,
    required String vehicleNumber,
    required String vehicleType,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    String? notes,
    String passType = 'Monthly',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _passService.addPass(
        customerName: customerName,
        mobileNumber: mobileNumber,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
        notes: notes,
        passType: passType,
      );
      await loadPasses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePass(PassModel pass) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _passService.updatePass(pass);
      await loadPasses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePass(String passId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _passService.deletePass(passId);
      await loadPasses();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<PassModel>> searchPasses(String query) async {
    return _passService.searchPasses(query);
  }
}
