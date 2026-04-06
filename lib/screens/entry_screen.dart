import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  File? _vehicleImage;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _analyzeImage(File imageFile) async {
    setState(() => _isLoading = true);
    try {
      // Bound directly to the live Hugging Face AI Server
      final uri = Uri.parse('https://zenor20-parkvault-ai.hf.space/detect-plate');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        if (data['plate'] != null && data['plate'] != '') {
          setState(() {
            _vehicleNumberController.text = data['plate'];
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Auto-detected plate: ${data['plate']}')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('OCR API Error: $e');
      // Just fail silently if the AI server isn't running
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 80,
      );
      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final vehicleImagesDir = Directory('${appDir.path}/vehicle_images');
        if (!await vehicleImagesDir.exists()) {
          await vehicleImagesDir.create(recursive: true);
        }
        final fileName =
            'vehicle_${DateTime.now().millisecondsSinceEpoch}${image.path.contains('.') ? image.path.substring(image.path.lastIndexOf('.')) : '.jpg'}';
        final savedImage =
            await File(image.path).copy('${vehicleImagesDir.path}/$fileName');
        setState(() {
          _vehicleImage = savedImage;
        });
        await _analyzeImage(savedImage);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 80,
      );
      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final vehicleImagesDir = Directory('${appDir.path}/vehicle_images');
        if (!await vehicleImagesDir.exists()) {
          await vehicleImagesDir.create(recursive: true);
        }
        final fileName =
            'vehicle_${DateTime.now().millisecondsSinceEpoch}${image.path.contains('.') ? image.path.substring(image.path.lastIndexOf('.')) : '.jpg'}';
        final savedImage =
            await File(image.path).copy('${vehicleImagesDir.path}/$fileName');
        setState(() {
          _vehicleImage = savedImage;
        });
        await _analyzeImage(savedImage);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery error: ${e.toString()}')),
      );
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (_vehicleImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _vehicleImage = null);
                },
              ),
          ],
        ),
      ),
    );
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
      imagePath: _vehicleImage?.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle entry saved successfully')),
      );
      _vehicleNumberController.clear();
      _notesController.clear();
      setState(() {
        _selectedPassId = null;
        _vehicleImage = null;
      });
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
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Photo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Capture a photo of the vehicle for records',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_vehicleImage != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _vehicleImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _vehicleImage = null),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: _showImageOptions,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.divider,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.background,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to capture vehicle photo',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_vehicleImage != null) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _showImageOptions,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Change Photo'),
                        ),
                      ],
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
