import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/storage_keys.dart';
import '../models/pass_model.dart';
import 'local_storage_service.dart';

class PassService {
  final LocalStorageService _storage = LocalStorageService();
  static const _uuid = Uuid();

  Future<PassModel> addPass({
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
    if (endDate.isBefore(startDate)) {
      throw Exception('End date must be greater than start date');
    }

    final passes = await _storage.getList(
      StorageKeys.passesList,
      PassModel.fromJson,
    );
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final pass = PassModel(
      passId: 'PASS${_uuid.v4().substring(0, 8).toUpperCase()}',
      customerName: customerName,
      mobileNumber: mobileNumber,
      vehicleNumber: vehicleNumber.toUpperCase(),
      vehicleType: vehicleType,
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
      amount: amount,
      status: 'active',
      notes: notes,
      passType: passType,
    );

    passes.add(pass);
    await _storage.setList(StorageKeys.passesList, passes, (p) => p.toJson());
    return pass;
  }

  Future<PassModel> updatePass(PassModel updatedPass) async {
    final passes = await _storage.getList(
      StorageKeys.passesList,
      PassModel.fromJson,
    );
    final index = passes.indexWhere((p) => p.passId == updatedPass.passId);
    if (index == -1) throw Exception('Pass not found');

    passes[index] = updatedPass;
    await _storage.setList(StorageKeys.passesList, passes, (p) => p.toJson());
    return updatedPass;
  }

  Future<bool> deletePass(String passId) async {
    final passes = await _storage.getList(
      StorageKeys.passesList,
      PassModel.fromJson,
    );
    passes.removeWhere((p) => p.passId == passId);
    return _storage.setList(StorageKeys.passesList, passes, (p) => p.toJson());
  }

  Future<List<PassModel>> getAllPasses() async {
    final passes = await _storage.getList(
      StorageKeys.passesList,
      PassModel.fromJson,
    );
    return _updateExpiredStatuses(passes);
  }

  Future<List<PassModel>> getActivePasses() async {
    final passes = await getAllPasses();
    return passes.where((p) => p.status == 'active').toList();
  }

  Future<List<PassModel>> searchPasses(String query) async {
    final passes = await getAllPasses();
    final q = query.toUpperCase();
    return passes
        .where(
          (p) =>
              p.vehicleNumber.contains(q) ||
              p.mobileNumber.contains(q) ||
              p.customerName.toUpperCase().contains(q),
        )
        .toList();
  }

  Future<PassModel?> findValidPass(String vehicleNumber) async {
    final passes = await getActivePasses();
    final now = DateTime.now();
    try {
      return passes.firstWhere(
        (p) =>
            p.vehicleNumber.toUpperCase() == vehicleNumber.toUpperCase() &&
            DateTime.parse(p.startDate).isBefore(now) &&
            DateTime.parse(p.endDate).isAfter(now),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> resetPasses() async {
    await _storage.setList(
      StorageKeys.passesList,
      <PassModel>[],
      (p) => p.toJson(),
    );
  }

  List<PassModel> _updateExpiredStatuses(List<PassModel> passes) {
    final now = DateTime.now();
    return passes.map((p) {
      if (p.status == 'active' && DateTime.parse(p.endDate).isBefore(now)) {
        return PassModel(
          passId: p.passId,
          customerName: p.customerName,
          mobileNumber: p.mobileNumber,
          vehicleNumber: p.vehicleNumber,
          vehicleType: p.vehicleType,
          startDate: p.startDate,
          endDate: p.endDate,
          amount: p.amount,
          status: 'expired',
          notes: p.notes,
          passType: p.passType,
        );
      }
      return p;
    }).toList();
  }
}
