import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/settings_provider.dart';
import '../models/operator_model.dart';
import '../models/location_model.dart';
import '../models/driver_model.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  State<LocationManagementScreen> createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  void _showAddLocationDialog() {
    final nameController = TextEditingController();
    final totalSlotsController = TextEditingController();
    final twoWheelerController = TextEditingController();
    final fourWheelerController = TextEditingController();
    final otherController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalSlotsController,
                decoration: const InputDecoration(
                  labelText: 'Total Slots',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: twoWheelerController,
                decoration: const InputDecoration(
                  labelText: '2-Wheeler Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fourWheelerController,
                decoration: const InputDecoration(
                  labelText: '4-Wheeler Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otherController,
                decoration: const InputDecoration(
                  labelText: 'Other Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  totalSlotsController.text.isEmpty) {
                return;
              }
              final location = LocationModel(
                locationId: const Uuid().v4(),
                name: nameController.text.trim(),
                totalSlots: int.tryParse(totalSlotsController.text) ?? 0,
                twoWheelerCapacity:
                    int.tryParse(twoWheelerController.text) ?? 0,
                fourWheelerCapacity:
                    int.tryParse(fourWheelerController.text) ?? 0,
                otherCapacity: int.tryParse(otherController.text) ?? 0,
              );
              await context.read<SettingsProvider>().addLocation(location);
              if (mounted) Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocation(String locationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: const Text('Are you sure you want to delete this location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<SettingsProvider>().deleteLocation(locationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Locations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: settingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : settingsProvider.locations.isEmpty
          ? const Center(child: Text('No locations found'))
          : ListView.builder(
              itemCount: settingsProvider.locations.length,
              itemBuilder: (context, index) {
                final location = settingsProvider.locations[index];
                final availableSlots = location.availableSlots;
                final occupancyPercent = location.totalSlots > 0
                    ? (location.occupiedSlots / location.totalSlots) * 100
                    : 0.0;

                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deleteLocation(location.locationId),
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '$availableSlots available',
                                style: TextStyle(
                                  color: availableSlots > 0
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: occupancyPercent / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              occupancyPercent > 80
                                  ? AppColors.error
                                  : occupancyPercent > 50
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${location.occupiedSlots} / ${location.totalSlots} slots occupied',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCapacityChip(
                                  AppStrings.twoWheeler,
                                  location.twoWheelerCapacity,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildCapacityChip(
                                  AppStrings.fourWheeler,
                                  location.fourWheelerCapacity,
                                  AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildCapacityChip(
                                  AppStrings.others,
                                  location.otherCapacity,
                                  AppColors.fastagColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCapacityChip(String label, int capacity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            capacity.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
