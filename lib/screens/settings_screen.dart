import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import '../providers/pass_provider.dart';
import '../providers/valet_provider.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../services/parking_service.dart';
import '../services/pass_service.dart';
import '../services/valet_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final ParkingService _parkingService = ParkingService();
  final PassService _passService = PassService();
  final ValetService _valetService = ValetService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await context.read<SettingsProvider>().loadSettings();
  }

  Future<void> _confirmReset({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppColors.textSecondary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard('Company Details', Icons.business, [
              _buildInfoRow('Company Name', settings.companyName),
              _buildInfoRow('Company Code', settings.companyCode),
              _buildInfoRow('Location', settings.selectedLocation),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard(AppStrings.feeConfiguration, Icons.attach_money, [
              _buildInfoRow(
                'Bike Fee',
                '\u20B9${settings.bikeFee.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'Car Fee',
                '\u20B9${settings.carFee.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'Taxi Fee',
                '\u20B9${settings.taxiFee.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'Bus/Truck Fee',
                '\u20B9${settings.busTruckFee.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'Mini Bus Fee',
                '\u20B9${settings.miniBusFee.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'SUV Fee',
                '\u20B9${settings.suvFee.toStringAsFixed(0)}',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard(AppStrings.capacity, Icons.meeting_room, [
              _buildInfoRow(
                '2-Wheeler',
                '${settings.twoWheelerCapacity} slots',
              ),
              _buildInfoRow(
                '4-Wheeler',
                '${settings.fourWheelerCapacity} slots',
              ),
              _buildInfoRow('Others', '${settings.otherCapacity} slots'),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard('Feature Toggles', Icons.toggle_on, [
              _buildToggleRow('QR Code', settings.qrEnabled, (value) async {
                final updated = SettingsModel(
                  companyName: settings.companyName,
                  companyCode: settings.companyCode,
                  selectedLocation: settings.selectedLocation,
                  bikeFee: settings.bikeFee,
                  carFee: settings.carFee,
                  taxiFee: settings.taxiFee,
                  busTruckFee: settings.busTruckFee,
                  miniBusFee: settings.miniBusFee,
                  suvFee: settings.suvFee,
                  twoWheelerCapacity: settings.twoWheelerCapacity,
                  fourWheelerCapacity: settings.fourWheelerCapacity,
                  otherCapacity: settings.otherCapacity,
                  ticketPrefix: settings.ticketPrefix,
                  qrEnabled: value,
                  valetEnabled: settings.valetEnabled,
                  fastagEnabled: settings.fastagEnabled,
                  firstHourCharge: settings.firstHourCharge,
                  additionalHourCharge: settings.additionalHourCharge,
                  fullDayCharge: settings.fullDayCharge,
                  nightCharge: settings.nightCharge,
                  lostTicketCharge: settings.lostTicketCharge,
                  valetCharge: settings.valetCharge,
                  version: settings.version,
                );
                await settingsProvider.saveSettings(updated);
              }),
              _buildToggleRow('Valet Parking', settings.valetEnabled, (
                value,
              ) async {
                final updated = SettingsModel(
                  companyName: settings.companyName,
                  companyCode: settings.companyCode,
                  selectedLocation: settings.selectedLocation,
                  bikeFee: settings.bikeFee,
                  carFee: settings.carFee,
                  taxiFee: settings.taxiFee,
                  busTruckFee: settings.busTruckFee,
                  miniBusFee: settings.miniBusFee,
                  suvFee: settings.suvFee,
                  twoWheelerCapacity: settings.twoWheelerCapacity,
                  fourWheelerCapacity: settings.fourWheelerCapacity,
                  otherCapacity: settings.otherCapacity,
                  ticketPrefix: settings.ticketPrefix,
                  qrEnabled: settings.qrEnabled,
                  valetEnabled: value,
                  fastagEnabled: settings.fastagEnabled,
                  firstHourCharge: settings.firstHourCharge,
                  additionalHourCharge: settings.additionalHourCharge,
                  fullDayCharge: settings.fullDayCharge,
                  nightCharge: settings.nightCharge,
                  lostTicketCharge: settings.lostTicketCharge,
                  valetCharge: settings.valetCharge,
                  version: settings.version,
                );
                await settingsProvider.saveSettings(updated);
              }),
              _buildToggleRow('FASTag', settings.fastagEnabled, (value) async {
                final updated = SettingsModel(
                  companyName: settings.companyName,
                  companyCode: settings.companyCode,
                  selectedLocation: settings.selectedLocation,
                  bikeFee: settings.bikeFee,
                  carFee: settings.carFee,
                  taxiFee: settings.taxiFee,
                  busTruckFee: settings.busTruckFee,
                  miniBusFee: settings.miniBusFee,
                  suvFee: settings.suvFee,
                  twoWheelerCapacity: settings.twoWheelerCapacity,
                  fourWheelerCapacity: settings.fourWheelerCapacity,
                  otherCapacity: settings.otherCapacity,
                  ticketPrefix: settings.ticketPrefix,
                  qrEnabled: settings.qrEnabled,
                  valetEnabled: settings.valetEnabled,
                  fastagEnabled: value,
                  firstHourCharge: settings.firstHourCharge,
                  additionalHourCharge: settings.additionalHourCharge,
                  fullDayCharge: settings.fullDayCharge,
                  nightCharge: settings.nightCharge,
                  lostTicketCharge: settings.lostTicketCharge,
                  valetCharge: settings.valetCharge,
                  version: settings.version,
                );
                await settingsProvider.saveSettings(updated);
              }),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard(AppStrings.resetData, Icons.restore, [
              _buildResetButton(
                'Reset History',
                Icons.history,
                () => _confirmReset(
                  title: 'Reset History',
                  message:
                      'Are you sure you want to reset all parking history?',
                  onConfirm: () async {
                    await context.read<ParkingProvider>().loadEntries();
                    await _parkingService.resetEntries();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('History reset successfully'),
                        ),
                      );
                    }
                  },
                ),
              ),
              _buildResetButton(
                'Reset Passes',
                Icons.card_membership,
                () => _confirmReset(
                  title: 'Reset Passes',
                  message: 'Are you sure you want to reset all passes?',
                  onConfirm: () async {
                    await context.read<PassProvider>().loadPasses();
                    await _passService.resetPasses();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passes reset successfully'),
                        ),
                      );
                    }
                  },
                ),
              ),
              _buildResetButton(
                'Reset Valet Tasks',
                Icons.car_repair,
                () => _confirmReset(
                  title: 'Reset Valet Tasks',
                  message: 'Are you sure you want to reset all valet tasks?',
                  onConfirm: () async {
                    await context.read<ValetProvider>().loadTasks();
                    await _valetService.resetTasks();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Valet tasks reset successfully'),
                        ),
                      );
                    }
                  },
                ),
              ),
              _buildResetButton(
                'Reset All Data',
                Icons.delete_forever,
                () => _confirmReset(
                  title: 'Reset All Data',
                  message: AppStrings.confirmReset,
                  onConfirm: () async {
                    await settingsProvider.resetAllData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppStrings.dataResetSuccess),
                        ),
                      );
                    }
                  },
                ),
                isDanger: true,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionCard('App Info', Icons.info, [
              _buildInfoRow('Version', AppStrings.appVersion),
            ]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: isDanger ? AppColors.error : AppColors.primary,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: isDanger ? AppColors.error : AppColors.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDanger ? AppColors.error : AppColors.primary,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
