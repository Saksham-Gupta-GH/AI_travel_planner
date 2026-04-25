import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/geocoding_service.dart';

class LocationPickerResult {
  final LatLng location;
  final String address;
  LocationPickerResult({required this.location, required this.address});
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  String _address = '';
  bool _isSearching = false;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  Future<void> _handleMapTap(LatLng point) async {
    setState(() {
      _pickedLocation = point;
      _address = 'Loading address...';
    });

    final address = await GeocodingService.reverseGeocode(point.latitude, point.longitude);
    if (mounted) {
      setState(() {
        _address = address ?? 'Address not found';
        _searchController.text = _address;
      });
    }
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final point = await GeocodingService.geocode(query);
    
    if (mounted) {
      setState(() => _isSearching = false);
      if (point != null) {
        setState(() {
          _pickedLocation = point;
          _address = query;
        });
        _mapController.move(point, 15);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_pickedLocation != null)
            TextButton(
              onPressed: () => Navigator.pop(context, LocationPickerResult(location: _pickedLocation!, address: _address)),
              child: const Text('CONFIRM', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? const LatLng(20.5937, 78.9629),
              initialZoom: 5,
              onTap: (tapPosition, point) => _handleMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.saksham.web_app_travel_planner',
              ),
              if (_pickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: AppColors.error, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          
          // Search Bar at Top
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search address or place...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchAddress(),
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: _searchAddress,
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pickedLocation == null
                              ? 'Tap map or search to select destination'
                              : _address.isEmpty ? 'Loading...' : _address,
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_pickedLocation != null)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Confirm Location',
                      onPressed: () => Navigator.pop(context, LocationPickerResult(location: _pickedLocation!, address: _address)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
