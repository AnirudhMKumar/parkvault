import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/valet_provider.dart';

class ValetManagerScreen extends StatefulWidget {
  const ValetManagerScreen({super.key});

  @override
  State<ValetManagerScreen> createState() => _ValetManagerScreenState();
}

class _ValetManagerScreenState extends State<ValetManagerScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ValetProvider>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final valetProvider = context.watch<ValetProvider>();
    final stats = valetProvider.stats;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Valet Manager'),
          backgroundColor: AppColors.valetColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.login), text: AppStrings.vehicleIn),
              Tab(icon: Icon(Icons.local_parking), text: AppStrings.parked),
              Tab(icon: Icon(Icons.logout), text: AppStrings.outRequest),
              Tab(icon: Icon(Icons.car_repair), text: AppStrings.readyToOut),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.valetColor.withOpacity(0.1),
              child: Column(
                children: [
                  const Text(
                    'Valet Workflow Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        'In',
                        stats['vehicle_in'] ?? 0,
                        AppColors.primary,
                      ),
                      _buildStatChip(
                        'Parked',
                        stats['parked'] ?? 0,
                        AppColors.success,
                      ),
                      _buildStatChip(
                        'Out Req',
                        stats['out_request'] ?? 0,
                        AppColors.warning,
                      ),
                      _buildStatChip(
                        'Ready',
                        stats['ready_to_out'] ?? 0,
                        AppColors.valetColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: valetProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const TabBarView(
                        children: [
                          _StatusTab(
                            status: 'vehicle_in',
                            nextStatus: 'parked',
                          ),
                          _StatusTab(
                            status: 'parked',
                            nextStatus: 'out_request',
                          ),
                          _StatusTab(
                            status: 'out_request',
                            nextStatus: 'ready_to_out',
                          ),
                          _StatusTab(
                            status: 'ready_to_out',
                            nextStatus: 'delivered',
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String status;
  final String nextStatus;

  const _StatusTab({required this.status, required this.nextStatus});

  @override
  Widget build(BuildContext context) {
    final valetProvider = context.watch<ValetProvider>();
    final drivers = valetProvider.drivers;

    List tasks;
    String emptyMessage;
    IconData emptyIcon;
    Color statusColor;

    switch (status) {
      case 'vehicle_in':
        tasks = valetProvider.vehicleInTasks;
        emptyMessage = 'No vehicles waiting to be parked';
        emptyIcon = Icons.login;
        statusColor = AppColors.primary;
        break;
      case 'parked':
        tasks = valetProvider.parkedTasks;
        emptyMessage = 'No vehicles currently parked';
        emptyIcon = Icons.local_parking;
        statusColor = AppColors.success;
        break;
      case 'out_request':
        tasks = valetProvider.outRequestTasks;
        emptyMessage = 'No release requests';
        emptyIcon = Icons.logout;
        statusColor = AppColors.warning;
        break;
      case 'ready_to_out':
        tasks = valetProvider.readyToOutTasks;
        emptyMessage = 'No vehicles ready for release';
        emptyIcon = Icons.car_repair;
        statusColor = AppColors.valetColor;
        break;
      default:
        tasks = [];
        emptyMessage = 'No tasks';
        emptyIcon = Icons.inbox;
        statusColor = AppColors.textSecondary;
    }

    String getButtonLabel() {
      switch (nextStatus) {
        case 'parked':
          return 'Mark Parked';
        case 'out_request':
          return 'Request Out';
        case 'ready_to_out':
          return 'Mark Ready';
        case 'delivered':
          return 'Mark Delivered';
        default:
          return 'Next';
      }
    }

    IconData getButtonIcon() {
      switch (nextStatus) {
        case 'parked':
          return Icons.local_parking;
        case 'out_request':
          return Icons.logout;
        case 'ready_to_out':
          return Icons.check_circle;
        case 'delivered':
          return Icons.delivery_dining;
        default:
          return Icons.arrow_forward;
      }
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
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
        final assignedDriver = drivers
            .where((d) => d.driverId == task.driverId)
            .firstOrNull;

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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
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
                if (assignedDriver != null)
                  _buildInfoRow(Icons.drive_eta, 'Driver', assignedDriver.name),
                if (task.otp != null)
                  _buildInfoRow(Icons.lock, 'OTP', task.otp),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<ValetProvider>().updateStatus(
                        task.taskId,
                        nextStatus,
                      );
                    },
                    icon: Icon(getButtonIcon()),
                    label: Text(getButtonLabel()),
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
