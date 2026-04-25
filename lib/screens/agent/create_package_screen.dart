import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/package_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants.dart';
import 'location_picker_screen.dart';

class CreatePackageScreen extends StatefulWidget {
  const CreatePackageScreen({super.key});

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final List<TextEditingController> _itineraryControllers = [];
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _durationController.addListener(_updateItineraryFields);
  }

  void _updateItineraryFields() {
    final duration = int.tryParse(_durationController.text) ?? 0;
    final constrainedDuration = duration > 10 ? 10 : duration;
    
    setState(() {
      if (_itineraryControllers.length < constrainedDuration) {
        for (int i = _itineraryControllers.length; i < constrainedDuration; i++) {
          _itineraryControllers.add(TextEditingController());
        }
      } else if (_itineraryControllers.length > constrainedDuration) {
        for (int i = _itineraryControllers.length - 1; i >= constrainedDuration; i--) {
          _itineraryControllers[i].dispose();
          _itineraryControllers.removeAt(i);
        }
      }
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _durationController.removeListener(_updateItineraryFields);
    _durationController.dispose();
    for (var controller in _itineraryControllers) {
      controller.dispose();
    }
    _descriptionController.dispose();
    _highlightsController.dispose();
    _imageUrlController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final package = PackageModel(
      id: '',
      agentId: authProvider.userId,
      agentName: authProvider.userName,
      destination: _destinationController.text.trim(),
      address: _addressController.text.trim(),
      price: double.parse(_priceController.text),
      duration: int.parse(_durationController.text),
      description: _descriptionController.text.trim(),
      imageUrls: _imageUrlController.text.trim().isEmpty
          ? []
          : _imageUrlController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      latitude: _latController.text.isNotEmpty ? double.tryParse(_latController.text) : null,
      longitude: _longController.text.isNotEmpty ? double.tryParse(_longController.text) : null,
      itinerary: _itineraryControllers.map((c) => c.text.trim()).toList(),
      highlights: _highlightsController.text.trim().isEmpty
          ? []
          : _highlightsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      createdAt: DateTime.now(),
    );

    try {
      await _firestoreService.createPackage(package);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AiAssistantSidebar(),
      appBar: AppBar(
        title: const Text('Create Package'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _destinationController,
                labelText: 'Locality / General Location',
                hintText: 'e.g. Mumbai, Paris, Tokyo',
                prefixIcon: const Icon(Icons.location_city_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a locality';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                labelText: 'Exact Address',
                hintText: 'e.g. Building A, Street B, Area C',
                prefixIcon: const Icon(Icons.place_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exact address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Price (₹)',
                      hintText: 'Package price',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.currency_rupee),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _durationController,
                      labelText: 'Duration (days)',
                      hintText: 'Max 10 days',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calendar_today),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final dur = int.tryParse(value);
                        if (dur == null || dur <= 0) {
                          return 'Invalid';
                        }
                        if (dur > 10) {
                          return 'Max 10 days';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dynamic Itinerary Section
              if (_itineraryControllers.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text('Day-by-Day Itinerary', style: AppTextStyles.title.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                ...List.generate(_itineraryControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomTextField(
                      controller: _itineraryControllers[index],
                      labelText: 'Day ${index + 1} Plan',
                      hintText: 'What happens on day ${index + 1}?',
                      prefixIcon: const Icon(Icons.event_note_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe day ${index + 1}';
                        }
                        return null;
                      },
                    ),
                  );
                }),
                const Divider(),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Describe the package details...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _highlightsController,
                labelText: 'Trip Highlights (comma separated)',
                hintText: 'e.g. Luxury Stay, Free Meals, Guided Tour',
                prefixIcon: const Icon(Icons.star_outline),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one highlight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Select Location on Map',
                isOutlined: true,
                onPressed: () async {
                  final LocationPickerResult? picked = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationPickerScreen(),
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _latController.text = picked.location.latitude.toString();
                      _longController.text = picked.location.longitude.toString();
                      _addressController.text = picked.address;
                    });
                  }
                },
                height: 48,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _latController,
                      labelText: 'Latitude',
                      hintText: 'e.g. 48.8566',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _longController,
                      labelText: 'Longitude',
                      hintText: 'e.g. 2.3522',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageUrlController,
                labelText: 'Place Image URLs (comma separated)',
                hintText: 'https://url1.jpg, https://url2.jpg',
                prefixIcon: const Icon(Icons.image_outlined),
                keyboardType: TextInputType.url,
                maxLines: 2,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  
                  final urls = trimmed.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
                  for (final url in urls) {
                    final uri = Uri.tryParse(url);
                    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
                      return 'One or more URLs are invalid';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Package',
                isLoading: _isLoading,
                onPressed: _savePackage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
