import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/pass_provider.dart';
import 'add_edit_pass_screen.dart';

class PassListScreen extends StatefulWidget {
  const PassListScreen({super.key});

  @override
  State<PassListScreen> createState() => _PassListScreenState();
}

class _PassListScreenState extends State<PassListScreen> {
  final _searchController = TextEditingController();
  String _filterStatus = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasses();
  }

  Future<void> _loadPasses() async {
    setState(() => _isLoading = true);
    await context.read<PassProvider>().loadPasses();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredPasses(List<dynamic> passes) {
    var filtered = passes;
    if (_filterStatus == 'active') {
      filtered = passes.where((p) => p.status == 'active').toList();
    } else if (_filterStatus == 'expired') {
      filtered = passes.where((p) => p.status == 'expired').toList();
    }
    final query = _searchController.text.trim().toUpperCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.vehicleNumber.contains(query) ||
                p.mobileNumber.contains(query) ||
                p.customerName.toUpperCase().contains(query),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final passProvider = context.watch<PassProvider>();
    final passes = passProvider.passes.reversed.toList();
    final filteredPasses = _getFilteredPasses(passes);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.passes),
        backgroundColor: AppColors.passColor,
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
                      selected: _filterStatus == 'all',
                      onSelected: (_) => setState(() => _filterStatus = 'all'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Active'),
                      selected: _filterStatus == 'active',
                      onSelected: (_) =>
                          setState(() => _filterStatus = 'active'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Expired'),
                      selected: _filterStatus == 'expired',
                      onSelected: (_) =>
                          setState(() => _filterStatus = 'expired'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPasses.isEmpty
                ? const Center(child: Text('No passes found'))
                : RefreshIndicator(
                    onRefresh: _loadPasses,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPasses.length,
                      itemBuilder: (context, index) {
                        final pass = filteredPasses[index];
                        final isActive = pass.status == 'active';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.card_membership,
                              color: isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            title: Text(pass.vehicleNumber),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pass.customerName),
                                Text('Type: ${pass.passType}'),
                                Text(
                                  'Valid: ${pass.startDate} to ${pass.endDate}',
                                ),
                                Text('Amount: ₹${pass.amount}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                pass.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditPassScreen(pass: pass),
                                ),
                              ).then((_) => _loadPasses());
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPassScreen()),
          ).then((_) => _loadPasses());
        },
        backgroundColor: AppColors.passColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
