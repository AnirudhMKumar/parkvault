import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/pass_model.dart';
import '../utils/validators.dart';
import '../providers/parking_provider.dart';
import '../providers/pass_provider.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  String _selectedType = 'Car';
  String _selectedPaymentType = 'Cash';
  final _notesController = TextEditingController();
  bool _isLoading = false;
  List<PassModel> _activePasses = [];
  String? _selectedPassId;

  final List<String> _vehicleTypes = [
    'Car',
    'Bike',
    'Truck',
    'SUV',
    'Taxi',
    'Bus',
    'Mini Bus',
  ];

  @override
  void initState() {
    super.initState();
    _loadPasses();
  }

  Future<void> _loadPasses() async {
    final passProvider = context.read<PassProvider>();
    await passProvider.loadPasses();
    setState(() {
      _activePasses = passProvider.activePasses;
    });
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<ParkingProvider>().addEntry(
      vehicleNumber: _vehicleNumberController.text.trim(),
      vehicleType: _selectedType,
      paymentType: _selectedPaymentType,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      passId: _selectedPassId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle entry saved successfully')),
      );
      _vehicleNumberController.clear();
      _notesController.clear();
      setState(() => _selectedPassId = null);
    } else {
      final error = context.read<ParkingProvider>().error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Failed to save entry')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newEntry),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vehicleNumberController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.vehicleNumber,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: Validators.validateVehicleNumber,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.vehicleType,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _vehicleTypes.map((type) {
                          final isSelected = type == _selectedType;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedType = type);
                              }
                            },
                            selectedColor: AppColors.primaryLight,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentType,
                        decoration: const InputDecoration(
                          labelText: 'Payment Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPaymentType = value);
                          }
                        },
                      ),
                      if (_activePasses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPassId,
                          decoration: const InputDecoration(
                            labelText: 'Apply Pass (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No Pass'),
                            ),
                            ..._activePasses.map((pass) {
                              return DropdownMenuItem(
                                value: pass.passId,
                                child: Text(
                                  '${pass.vehicleNumber} - ${pass.customerName}',
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedPassId = value);
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Entry', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
