import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/package_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/custom_textfield.dart';
import '../../models/review_model.dart';

class ManagePackagesScreen extends StatelessWidget {
  const ManagePackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      endDrawer: const AiAssistantSidebar(),
      appBar: AppBar(
        title: const Text('My Packages'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createPackage);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PackageModel>>(
        stream: firestoreService.getPackagesByAgent(authProvider.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final packages = snapshot.data ?? [];

          if (packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_travel, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text('No packages yet', style: AppTextStyles.subtitle),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.createPackage);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Package'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              return _buildPackageCard(context, package, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    PackageModel package,
    FirestoreService firestoreService,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.place, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package.destination, style: AppTextStyles.title),
                      StreamBuilder<List<ReviewModel>>(
                        stream: firestoreService.getReviewsForPackage(package.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No ratings yet', style: AppTextStyles.caption);
                          }
                          final reviews = snapshot.data!;
                          final avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${avgRating.toStringAsFixed(1)} (${reviews.length} reviews)',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                              ),
                            ],
                          );
                        },
                      ),
                      Text(
                        '₹${package.price.toStringAsFixed(0)} - ${package.duration} days',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditDialog(context, package, firestoreService);
                    } else if (value == 'reviews') {
                      _showReviewsDialog(context, package, firestoreService);
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Package'),
                          content: const Text(
                            'Are you sure you want to delete this package?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await firestoreService.deletePackage(package.id);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reviews',
                      child: Row(
                        children: [
                          Icon(Icons.rate_review_outlined),
                          const SizedBox(width: 8),
                          Text('View Reviews'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              package.description,
              style: AppTextStyles.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    PackageModel package,
    FirestoreService firestoreService,
  ) {
    final destinationController = TextEditingController(
      text: package.destination,
    );
    final priceController = TextEditingController(
      text: package.price.toString(),
    );
    final durationController = TextEditingController(
      text: package.duration.toString(),
    );
    final descriptionController = TextEditingController(
      text: package.description,
    );
    final highlightsController = TextEditingController(
      text: package.highlights.join(', '),
    );
    final imageUrlController = TextEditingController(
      text: package.imageUrls.join(', '),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Package'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: destinationController,
                  labelText: 'Destination',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: priceController,
                        labelText: 'Price',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: durationController,
                        labelText: 'Days',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: descriptionController,
                  labelText: 'Description',
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: highlightsController,
                  labelText: 'Trip Highlights (comma separated)',
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: imageUrlController,
                  labelText: 'Image URL',
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return null;
                    final urls = trimmed.split(',');
                    for (var url in urls) {
                      final uri = Uri.tryParse(url.trim());
                      if (uri == null || !uri.hasScheme) {
                        return 'Invalid URL found';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await firestoreService.updatePackage(package.id, {
                  'destination': destinationController.text,
                  'price': double.parse(priceController.text),
                  'duration': int.parse(durationController.text),
                  'description': descriptionController.text,
                  'highlights': highlightsController.text.trim().isEmpty
                      ? []
                      : highlightsController.text.split(',').map((e) => e.trim()).toList(),
                  'imageUrls': imageUrlController.text.trim().isEmpty
                      ? []
                      : imageUrlController.text.split(',').map((e) => e.trim()).toList(),
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Package updated!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showReviewsDialog(BuildContext context, PackageModel package, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${package.destination} Reviews'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<ReviewModel>>(
            stream: firestoreService.getReviewsForPackage(package.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No reviews yet.'));
              }
              final reviews = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(review.userName[0])),
                    title: Row(
                      children: [
                        Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(review.rating.toString()),
                      ],
                    ),
                    subtitle: Text(review.comment),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
