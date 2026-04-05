import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/parking_provider.dart';
import 'entry_screen.dart';
import 'exit_screen.dart';
import 'history_screen.dart';
import 'pass_list_screen.dart';
import 'settings_screen.dart';
import 'admin_dashboard_screen.dart';
import 'valet_driver_screen.dart';
import 'valet_manager_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final authProvider = context.watch<AuthProvider>();
    final parkingProvider = context.watch<ParkingProvider>();
    final stats = parkingProvider.todayStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
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
              Text(
                '${AppStrings.welcome}, ${authProvider.currentUser?.username ?? 'User'}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${authProvider.currentUser?.role.toUpperCase() ?? ''}',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Entries Today',
                    '${stats['totalEntries'] ?? 0}',
                    Icons.login,
                    AppColors.primary,
                  ),
                  _buildStatCard(
                    'Exits Today',
                    '${stats['totalExits'] ?? 0}',
                    Icons.logout,
                    AppColors.success,
                  ),
                  _buildStatCard(
                    'Currently Parked',
                    '${stats['activeParked'] ?? 0}',
                    Icons.local_parking,
                    AppColors.warning,
                  ),
                  _buildStatCard(
                    'Revenue Today',
                    '₹${(stats['revenue'] ?? 0).toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    context,
                    'Vehicle Entry',
                    Icons.login,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EntryScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Vehicle Exit',
                    Icons.logout,
                    AppColors.success,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExitScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'History',
                    Icons.history,
                    AppColors.warning,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    'Passes',
                    Icons.card_membership,
                    AppColors.passColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PassListScreen()),
                    ),
                  ),
                  if (authProvider.isAdmin)
                    _buildActionCard(
                      context,
                      'Admin Dashboard',
                      Icons.admin_panel_settings,
                      AppColors.primaryDark,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen(),
                        ),
                      ),
                    ),
                  if (authProvider.isAdmin || authProvider.isValet)
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
                  if (authProvider.isValet)
                    _buildActionCard(
                      context,
                      'Valet Driver',
                      Icons.drive_eta,
                      AppColors.valetColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ValetDriverScreen(),
                        ),
                      ),
                    ),
                  if (authProvider.isAdmin)
                    _buildActionCard(
                      context,
                      'Settings',
                      Icons.settings,
                      AppColors.textSecondary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
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

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
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
