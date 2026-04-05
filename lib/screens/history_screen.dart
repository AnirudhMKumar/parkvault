import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/date_utils.dart' as app_date;
import '../providers/parking_provider.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await context.read<ParkingProvider>().loadEntries();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredEntries(List<dynamic> entries) {
    var filtered = entries;
    if (_selectedFilter == 'parked') {
      filtered = entries.where((e) => e.status == 'parked').toList();
    } else if (_selectedFilter == 'exited') {
      filtered = entries.where((e) => e.status == 'exited').toList();
    }
    final query = _searchController.text.trim().toUpperCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e.vehicleNumber.contains(query) ||
                e.ticketId.toUpperCase().contains(query),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = context.watch<ParkingProvider>();
    final entries = parkingProvider.entries.reversed.toList();
    final filteredEntries = _getFilteredEntries(entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.search,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Filter: '),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedFilter == 'all',
                      onSelected: (_) =>
                          setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Parked'),
                      selected: _selectedFilter == 'parked',
                      onSelected: (_) =>
                          setState(() => _selectedFilter = 'parked'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Exited'),
                      selected: _selectedFilter == 'exited',
                      onSelected: (_) =>
                          setState(() => _selectedFilter = 'exited'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEntries.isEmpty
                ? const Center(child: Text('No records found'))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        final isParked = entry.status == 'parked';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              isParked
                                  ? Icons.local_parking
                                  : Icons.check_circle,
                              color: isParked
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                            title: Text(entry.vehicleNumber),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ticket: ${entry.ticketId}'),
                                Text('Type: ${entry.vehicleType}'),
                                Text(
                                  'Entry: ${app_date.DateUtils.formatDateTime(entry.entryTime)}',
                                ),
                                if (entry.exitTime != null)
                                  Text(
                                    'Exit: ${app_date.DateUtils.formatDateTime(entry.exitTime!)}',
                                  ),
                                if (entry.amount != null)
                                  Text('Amount: ₹${entry.amount}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                entry.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: isParked
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HistoryDetailScreen(entry: entry),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
