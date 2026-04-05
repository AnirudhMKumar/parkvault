import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/valet_provider.dart';
import '../models/driver_model.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ValetProvider>().loadDrivers();
    });
  }

  void _showAddDriverDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final employeeIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(),
                ),
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
                  contactController.text.isEmpty ||
                  employeeIdController.text.isEmpty) {
                return;
              }
              final driver = DriverModel(
                driverId: const Uuid().v4(),
                name: nameController.text.trim(),
                contactNumber: contactController.text.trim(),
                employeeId: employeeIdController.text.trim(),
              );
              await context.read<ValetProvider>().addDriver(driver);
              if (mounted) Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDuty(String driverId, bool isOnDuty) async {
    await context.read<ValetProvider>().toggleDriverDuty(driverId);
  }

  Future<void> _deleteDriver(String driverId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Driver'),
        content: const Text('Are you sure you want to delete this driver?'),
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
      await context.read<ValetProvider>().deleteDriver(driverId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valetProvider = context.watch<ValetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Management'),
        backgroundColor: AppColors.valetColor,
        foregroundColor: Colors.white,
      ),
      body: valetProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : valetProvider.drivers.isEmpty
          ? const Center(child: Text('No drivers found'))
          : ListView.builder(
              itemCount: valetProvider.drivers.length,
              itemBuilder: (context, index) {
                final driver = valetProvider.drivers[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deleteDriver(driver.driverId),
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.valetColor,
                        child: Text(
                          driver.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        driver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Contact: ${driver.contactNumber}'),
                          Text('Emp ID: ${driver.employeeId}'),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    driver.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${driver.carsHandled} cars',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Chip(
                                label: Text(
                                  driver.isOnDuty
                                      ? AppStrings.onDuty
                                      : AppStrings.offDuty,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: driver.isOnDuty
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: driver.isOnDuty,
                        onChanged: (_) =>
                            _toggleDuty(driver.driverId, driver.isOnDuty),
                        activeColor: AppColors.success,
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverDialog,
        backgroundColor: AppColors.valetColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
