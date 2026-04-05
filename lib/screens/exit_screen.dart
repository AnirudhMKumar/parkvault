import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/date_utils.dart' as app_date;
import '../providers/parking_provider.dart';

class ExitScreen extends StatefulWidget {
  const ExitScreen({super.key});

  @override
  State<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVehicle() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await context.read<ParkingProvider>().searchEntries(query);
    final activeResults = results.where((e) => e.status == 'parked').toList();

    setState(() {
      _searchResults = activeResults;
      _isLoading = false;
    });
  }

  Future<void> _processExit(String ticketId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await context.read<ParkingProvider>().processExit(ticketId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle exit processed successfully')),
      );
      _searchController.clear();
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    } else {
      _error = context.read<ParkingProvider>().error;
      setState(() => _isLoading = false);
    }
  }

  void _showExitConfirmation(dynamic entry) {
    final duration = app_date.DateUtils.calculateDurationMinutes(
      entry.entryTime,
      null,
    );
    final durationStr = app_date.DateUtils.formatDuration(duration);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket: ${entry.ticketId}'),
            Text('Vehicle: ${entry.vehicleNumber}'),
            Text('Type: ${entry.vehicleType}'),
            Text(
              'Entry: ${app_date.DateUtils.formatDateTime(entry.entryTime)}',
            ),
            Text('Duration: $durationStr'),
            if (entry.passId != null && entry.passId!.isNotEmpty)
              const Text(
                'Fee: ₹0 (Pass Applied)',
                style: TextStyle(color: AppColors.success),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processExit(entry.ticketId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.completeExit),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vehicleExit),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by Vehicle Number or Ticket ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _searchVehicle(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('Search for a parked vehicle'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final entry = _searchResults[index];
                      final duration =
                          app_date.DateUtils.calculateDurationMinutes(
                            entry.entryTime,
                            null,
                          );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                          ),
                          title: Text(entry.vehicleNumber),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ticket: ${entry.ticketId}'),
                              Text('Type: ${entry.vehicleType}'),
                              Text(
                                'Duration: ${app_date.DateUtils.formatDuration(duration)}',
                              ),
                              if (entry.passId != null &&
                                  entry.passId!.isNotEmpty)
                                const Text(
                                  'Pass Applied - Fee: ₹0',
                                  style: TextStyle(color: AppColors.success),
                                ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _showExitConfirmation(entry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Exit'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
