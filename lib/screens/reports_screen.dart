import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/parking_provider.dart';
import '../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final ReportService _reportService = ReportService();
  late TabController _tabController;
  Map<String, dynamic> _revenueReport = {};
  Map<String, dynamic> _entryExitReport = {};
  Map<String, dynamic> _valetReport = {};
  Map<String, dynamic> _fastagReport = {};
  bool _isLoading = true;
  String _revenuePeriod = 'daily';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _reportService.getRevenueReport(period: _revenuePeriod),
        _reportService.getEntryExitReport(),
        _reportService.getValetReport(),
        _reportService.getFastagReport(),
      ]);
      setState(() {
        _revenueReport = results[0] as Map<String, dynamic>;
        _entryExitReport = results[1] as Map<String, dynamic>;
        _valetReport = results[2] as Map<String, dynamic>;
        _fastagReport = results[3] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.reports),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Revenue'),
            Tab(text: 'Entry/Exit'),
            Tab(text: 'Valet'),
            Tab(text: 'FASTag'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRevenueTab(),
                _buildEntryExitTab(),
                _buildValetTab(),
                _buildFastagTab(),
              ],
            ),
    );
  }

  Widget _buildRevenueTab() {
    final totalRevenue = _revenueReport['totalRevenue'] ?? 0.0;
    final normalRevenue = _revenueReport['normalRevenue'] ?? 0.0;
    final fastagRevenue = _revenueReport['fastagRevenue'] ?? 0.0;
    final totalEntries = _revenueReport['totalEntries'] ?? 0;
    final totalExits = _revenueReport['totalExits'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Period: '),
              DropdownButton<String>(
                value: _revenuePeriod,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _revenuePeriod = value);
                    _loadReports();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRevenueSummary(
                        'Total',
                        totalRevenue,
                        AppColors.primary,
                      ),
                      _buildRevenueSummary(
                        'Normal',
                        normalRevenue,
                        AppColors.success,
                      ),
                      _buildRevenueSummary(
                        'FASTag',
                        fastagRevenue,
                        AppColors.fastagColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatText('Entries', totalEntries.toString()),
                      _buildStatText('Exits', totalExits.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: totalRevenue > 0 ? totalRevenue * 1.2 : 100,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text(
                                  'Normal',
                                  style: TextStyle(fontSize: 10),
                                );
                              case 1:
                                return const Text(
                                  'FASTag',
                                  style: TextStyle(fontSize: 10),
                                );
                              case 2:
                                return const Text(
                                  'Total',
                                  style: TextStyle(fontSize: 10),
                                );
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\u20B9${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: normalRevenue,
                            color: AppColors.success,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: fastagRevenue,
                            color: AppColors.fastagColor,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: totalRevenue,
                            color: AppColors.primary,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummary(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '\u20B9${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEntryExitTab() {
    final todayEntries = _entryExitReport['todayEntries'] ?? 0;
    final todayExits = _entryExitReport['todayExits'] ?? 0;
    final activeParked = _entryExitReport['activeParked'] ?? 0;
    final totalEntries = _entryExitReport['totalEntries'] ?? 0;
    final totalExits = _entryExitReport['totalExits'] ?? 0;
    final vehicleTypeBreakdown =
        _entryExitReport['vehicleTypeBreakdown'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Activity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(
                        'Today Entries',
                        todayEntries.toString(),
                        Icons.login,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        'Today Exits',
                        todayExits.toString(),
                        Icons.logout,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        'Active Parked',
                        activeParked.toString(),
                        Icons.local_parking,
                        AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatText('Total Entries', totalEntries.toString()),
                      _buildStatText('Total Exits', totalExits.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicle Type Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (vehicleTypeBreakdown.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: vehicleTypeBreakdown.entries.map((e) {
                            final colorIndex = vehicleTypeBreakdown.keys
                                .toList()
                                .indexOf(e.key);
                            final colors = [
                              AppColors.primary,
                              AppColors.success,
                              AppColors.warning,
                              AppColors.accent,
                              AppColors.valetColor,
                              AppColors.fastagColor,
                            ];
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title: '${e.key}\n${e.value}',
                              color: colors[colorIndex % colors.length],
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    )
                  else
                    const Center(child: Text('No vehicle data available')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValetTab() {
    final totalTasks = _valetReport['totalTasks'] ?? 0;
    final todayTasks = _valetReport['todayTasks'] ?? 0;
    final delivered = _valetReport['delivered'] ?? 0;
    final pending = _valetReport['pending'] ?? 0;
    final driverStats =
        _valetReport['driverStats'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Total Tasks',
                        totalTasks.toString(),
                        Icons.assignment,
                        AppColors.valetColor,
                      ),
                      _buildStatCard(
                        'Today Tasks',
                        todayTasks.toString(),
                        Icons.today,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        'Delivered',
                        delivered.toString(),
                        Icons.check_circle,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        'Pending',
                        pending.toString(),
                        Icons.pending,
                        AppColors.warning,
                      ),
                    ],
                  ),
                  if (driverStats.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Driver Statistics',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...driverStats.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Driver: ${e.key}'),
                            Text(
                              '${e.value} tasks',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastagTab() {
    final totalTransactions = _fastagReport['totalTransactions'] ?? 0;
    final todayTransactions = _fastagReport['todayTransactions'] ?? 0;
    final active = _fastagReport['active'] ?? 0;
    final totalRevenue = _fastagReport['totalRevenue'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Total Transactions',
                        totalTransactions.toString(),
                        Icons.receipt_long,
                        AppColors.fastagColor,
                      ),
                      _buildStatCard(
                        'Today',
                        todayTransactions.toString(),
                        Icons.today,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        'Active',
                        active.toString(),
                        Icons.check_circle,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        'Revenue',
                        '\u20B9${totalRevenue.toStringAsFixed(0)}',
                        Icons.currency_rupee,
                        AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatText(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
