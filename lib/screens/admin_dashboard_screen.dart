import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import '../providers/pass_provider.dart';
import '../providers/valet_provider.dart';
import '../providers/settings_provider.dart';
import '../services/report_service.dart';
import 'pass_list_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';
import 'valet_manager_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ParkingProvider>().loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = context.watch<ParkingProvider>();
    final passProvider = context.watch<PassProvider>();
    final valetProvider = context.watch<ValetProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final stats = parkingProvider.todayStats;
    final settings = settingsProvider.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Today\'s Summary'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Total Entries',
                    '${stats['totalEntries'] ?? 0}',
                    Icons.login,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Parked',
                    '${stats['activeParked'] ?? 0}',
                    Icons.local_parking,
                    AppColors.warning,
                  ),
                  _buildStatCard(
                    'Exits',
                    '${stats['totalExits'] ?? 0}',
                    Icons.logout,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Revenue',
                    '\u20B9${(stats['revenue'] ?? 0).toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Occupancy'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOccupancyCard(
                      '2-Wheeler',
                      stats['twoWheelers'] ?? 0,
                      settings.twoWheelerCapacity,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOccupancyCard(
                      '4-Wheeler',
                      stats['fourWheelers'] ?? 0,
                      settings.fourWheelerCapacity,
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _buildActionCard(
                    context,
                    'Pass Management',
                    Icons.card_membership,
                    AppColors.passColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PassListScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Settings',
                    Icons.settings,
                    AppColors.textSecondary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Reports',
                    Icons.bar_chart,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Valet Manager',
                    Icons.car_repair,
                    AppColors.valetColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ValetManagerScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard(
    String title,
    int used,
    int capacity,
    Color color,
  ) {
    final percentage = capacity > 0 ? (used / capacity) : 0.0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$used / $capacity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}% occupied',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
