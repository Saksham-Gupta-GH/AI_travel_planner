import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/package_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/package_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _budgetController = TextEditingController();
  final _destinationController = TextEditingController();
  List<PackageModel> _filteredPackages = [];
  bool _isFiltering = false;
  bool _showFilteredResults = false;

  Future<void> _filterPackages() async {
    setState(() => _isFiltering = true);

    final budget = _budgetController.text.isNotEmpty
        ? double.tryParse(_budgetController.text)
        : null;
    final destination = _destinationController.text.trim();

    final packages = await _firestoreService.filterPackages(
      maxBudget: budget,
      destination: destination.isNotEmpty ? destination : null,
    );

    setState(() {
      _filteredPackages = packages;
      _isFiltering = false;
      _showFilteredResults = true;
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const AiAssistantSidebar(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Find your escape', style: AppTextStyles.title.copyWith(fontSize: 18)),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.smart_toy_outlined),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Search/Filter Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _destinationController,
                          labelText: 'Locality (e.g. Mumbai)',
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 56, // Match textfield height
                        width: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: _filterPackages,
                        ),
                      ),
                    ],
                  ),
                  if (_showFilteredResults) ...[
                    const SizedBox(height: 12),
                    ActionChip(
                      avatar: const Icon(Icons.close, size: 16),
                      label: const Text('Clear Filters'),
                      onPressed: () {
                        setState(() {
                          _showFilteredResults = false;
                          _destinationController.clear();
                          _budgetController.clear();
                        });
                      },
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // List Section
          _showFilteredResults 
            ? _buildFilteredList()
            : _buildAllPackagesStream(),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    if (_isFiltering) return const SliverFillRemaining(child: LoadingIndicator());
    if (_filteredPackages.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No matches found.')));
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: PackageCard(package: _filteredPackages[index]),
          ),
          childCount: _filteredPackages.length,
        ),
      ),
    );
  }

  Widget _buildAllPackagesStream() {
    return StreamBuilder<List<PackageModel>>(
      stream: _firestoreService.getAllPackages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: LoadingIndicator());
        }
        final packages = snapshot.data ?? [];
        if (packages.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('No packages available.')));
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: PackageCard(package: packages[index]),
              ),
              childCount: packages.length,
            ),
          ),
        );
      },
    );
  }
}
