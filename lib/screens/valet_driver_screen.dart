import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/valet_provider.dart';
import '../providers/auth_provider.dart';

class ValetDriverScreen extends StatefulWidget {
  const ValetDriverScreen({super.key});

  @override
  State<ValetDriverScreen> createState() => _ValetDriverScreenState();
}

class _ValetDriverScreenState extends State<ValetDriverScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ValetProvider>().loadTasks();
    await context.read<ValetProvider>().loadDrivers();
  }

  @override
  Widget build(BuildContext context) {
    final valetProvider = context.watch<ValetProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final drivers = valetProvider.drivers;
    final currentDriver = drivers
        .where((d) => d.driverId == currentUser?.id)
        .firstOrNull;
    final isOnDuty = currentDriver?.isOnDuty ?? false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.valetParking),
          backgroundColor: AppColors.valetColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.local_parking), text: 'Park'),
              Tab(icon: Icon(Icons.car_repair), text: 'Release'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.valetColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDriver?.name ??
                            currentUser?.username ??
                            'Driver',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isOnDuty ? AppStrings.onDuty : AppStrings.offDuty,
                        style: TextStyle(
                          fontSize: 14,
                          color: isOnDuty ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: Text(
                      isOnDuty ? AppStrings.onDuty : AppStrings.offDuty,
                      style: TextStyle(
                        color: isOnDuty ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: isOnDuty,
                    activeColor: AppColors.success,
                    onChanged: currentDriver != null
                        ? (_) {
                            context.read<ValetProvider>().toggleDriverDuty(
                              currentDriver.driverId,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: valetProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !isOnDuty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.toggle_off,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'You are currently Off Duty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Switch On Duty to start receiving tasks',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : const TabBarView(children: [_ParkTab(), _ReleaseTab()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParkTab extends StatelessWidget {
  const _ParkTab();

  @override
  Widget build(BuildContext context) {
    final valetProvider = context.watch<ValetProvider>();
    final tasks = valetProvider.vehicleInTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No vehicles to park',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.vehicleNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.valetColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.valetColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.key, 'Key', task.keyNumber),
                _buildInfoRow(Icons.meeting_room, 'Bay', task.bayNumber),
                _buildInfoRow(Icons.person, 'Customer', task.customerName),
                if (task.vehicleModel != null)
                  _buildInfoRow(
                    Icons.directions_car,
                    'Model',
                    task.vehicleModel,
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ValetProvider>().updateStatus(
                        task.taskId,
                        'parked',
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Complete Parking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? '-'),
        ],
      ),
    );
  }
}

class _ReleaseTab extends StatelessWidget {
  const _ReleaseTab();

  @override
  Widget build(BuildContext context) {
    final valetProvider = context.watch<ValetProvider>();
    final tasks = valetProvider.outRequestTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_repair, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No vehicles to release',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.vehicleNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.key, 'Key', task.keyNumber),
                _buildInfoRow(Icons.meeting_room, 'Bay', task.bayNumber),
                _buildInfoRow(Icons.person, 'Customer', task.customerName),
                if (task.otp != null)
                  _buildInfoRow(Icons.lock, 'OTP', task.otp),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ValetProvider>().updateStatus(
                        task.taskId,
                        'delivered',
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? '-'),
        ],
      ),
    );
  }
}
