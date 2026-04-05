import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/validators.dart';
import '../providers/pass_provider.dart';

class AddEditPassScreen extends StatefulWidget {
  final dynamic pass;

  const AddEditPassScreen({super.key, this.pass});

  @override
  State<AddEditPassScreen> createState() => _AddEditPassScreenState();
}

class _AddEditPassScreenState extends State<AddEditPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _vehicleType = 'Car';
  String _passType = 'Monthly';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'Car',
    'Bike',
    'Truck',
    'SUV',
    'Taxi',
    'Bus',
    'Mini Bus',
  ];
  final List<String> _passTypes = ['Monthly', 'Weekly', 'VIP', 'Staff'];

  @override
  void initState() {
    super.initState();
    if (widget.pass != null) {
      _customerNameController.text = widget.pass.customerName;
      _mobileController.text = widget.pass.mobileNumber;
      _vehicleNumberController.text = widget.pass.vehicleNumber;
      _vehicleType = widget.pass.vehicleType;
      _passType = widget.pass.passType;
      _amountController.text = widget.pass.amount.toString();
      _notesController.text = widget.pass.notes ?? '';
      _startDate = DateTime.parse(widget.pass.startDate);
      _endDate = DateTime.parse(widget.pass.endDate);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileController.dispose();
    _vehicleNumberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.endDateAfterStart)),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success;
    if (widget.pass != null) {
      final updatedPass = widget.pass;
      success = await context.read<PassProvider>().updatePass(updatedPass);
    } else {
      success = await context.read<PassProvider>().addPass(
        customerName: _customerNameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleType: _vehicleType,
        startDate: _startDate!,
        endDate: _endDate!,
        amount: double.parse(_amountController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        passType: _passType,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.pass != null ? 'Pass updated' : 'Pass created'),
        ),
      );
      Navigator.pop(context);
    } else {
      final error = context.read<PassProvider>().error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Failed to save pass')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pass != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pass' : 'Add Pass'),
        backgroundColor: AppColors.passColor,
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
                        'Pass Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.customerName,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) =>
                            Validators.validateRequired(v, 'customer name'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mobileController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.mobileNumber,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: Validators.validateMobile,
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
                      DropdownButtonFormField<String>(
                        value: _vehicleType,
                        decoration: const InputDecoration(
                          labelText: AppStrings.vehicleType,
                          border: OutlineInputBorder(),
                        ),
                        items: _vehicleTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _vehicleType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _passType,
                        decoration: const InputDecoration(
                          labelText: AppStrings.passType,
                          border: OutlineInputBorder(),
                        ),
                        items: _passTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _passType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectStartDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: AppStrings.startDate,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startDate != null
                                ? DateFormat('dd MMM yyyy').format(_startDate!)
                                : 'Select Start Date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectEndDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: AppStrings.endDate,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _endDate != null
                                ? DateFormat('dd MMM yyyy').format(_endDate!)
                                : 'Select End Date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.amount,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: Validators.validateAmount,
                      ),
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
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.passColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Pass' : 'Create Pass',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
