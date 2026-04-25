import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/package_model.dart';
import '../../models/review_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/package_card.dart';
import '../traveler/package_detail_screen.dart';
import '../../services/geocoding_service.dart';

class WorldExplorerScreen extends StatefulWidget {
  const WorldExplorerScreen({super.key});

  @override
  State<WorldExplorerScreen> createState() => _WorldExplorerScreenState();
}

class _WorldExplorerScreenState extends State<WorldExplorerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<PackageModel> _allPackages = [];
  List<PackageModel> _filteredPackages = [];
  PackageModel? _selectedPackage;
  bool _isSearching = false;

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredPackages = _allPackages);
      return;
    }

    // Filter local pins
    setState(() {
      final searchLower = query.toLowerCase();
      _filteredPackages = _allPackages
          .where((p) => 
              p.destination.toLowerCase().contains(searchLower) || 
              p.address.toLowerCase().contains(searchLower))
          .toList();
    });

    // Geocode the search term and zoom map
    setState(() => _isSearching = true);
    final point = await GeocodingService.geocode(query);
    if (mounted) {
      setState(() => _isSearching = false);
      if (point != null) {
        _mapController.move(point, 10);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<List<PackageModel>>(
            stream: FirestoreService().getAllPackages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }
              _allPackages = snapshot.data ?? [];
              if (_filteredPackages.isEmpty && _searchController.text.isEmpty) {
                _filteredPackages = _allPackages;
              }

              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(20, 0),
                  initialZoom: 2.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.saksham.web_app_travel_planner',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'Tiles &copy; Esri &mdash; Source: Esri, DeLorme, NAVTEQ, USGS, Intermap, iPC, NRCAN, Esri Japan, METI, Esri China (Hong Kong), Esri (Thailand), TomTom, 2012',
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: _filteredPackages
                        .where((p) => p.latitude != null)
                        .map((p) => Marker(
                              point: LatLng(p.latitude!, p.longitude!),
                              width: 24,
                              height: 24,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedPackage = p),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectedPackage?.id == p.id 
                                        ? AppColors.primary 
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      const BoxShadow(color: Colors.black26, blurRadius: 2)
                                    ],
                                    border: Border.all(color: AppColors.primary, width: 1.5),
                                  ),
                                  child: Icon(
                                    Icons.place,
                                    color: _selectedPackage?.id == p.id 
                                        ? Colors.white 
                                        : AppColors.primary,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              );
            },
          ),
          
          // Custom Search Bar (Google Style)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  suffixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Selected Package Card
          if (_selectedPackage != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Dismissible(
                key: Key('map-pkg-${_selectedPackage!.id}'),
                onDismissed: (_) => setState(() => _selectedPackage = null),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PackageDetailScreen(package: _selectedPackage!),
                    ),
                  ),
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppShadows.deep,
                      border: Border.all(color: AppColors.divider, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'pkg-img-${_selectedPackage!.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _selectedPackage!.imageUrls.isNotEmpty
                                ? Image.network(_selectedPackage!.imageUrls.first, 
                                    width: 108, height: 108, fit: BoxFit.cover)
                                : Container(width: 108, height: 108, color: AppColors.primaryLight),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_selectedPackage!.destination, 
                                style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold, fontSize: 18)
                              ),
                              const SizedBox(height: 4),
                              Text('₹${_selectedPackage!.price.toStringAsFixed(0)}', 
                                  style: AppTextStyles.title.copyWith(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              StreamBuilder<List<ReviewModel>>(
                                stream: FirestoreService().getReviewsForPackage(_selectedPackage!.id),
                                builder: (context, snapshot) {
                                  final ratingText = (!snapshot.hasData || snapshot.data!.isEmpty)
                                      ? 'New'
                                      : '${(snapshot.data!.map((r) => r.rating).reduce((a, b) => a + b) / snapshot.data!.length).toStringAsFixed(1)}';
                                  return Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                                      const SizedBox(width: 4),
                                      Text('$ratingText · ${_selectedPackage!.duration} days', 
                                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textLight.withOpacity(0.3), size: 18),
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
}
