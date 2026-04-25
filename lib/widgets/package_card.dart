import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/package_model.dart';
import '../models/review_model.dart';
import '../providers/wishlist_provider.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../screens/traveler/package_detail_screen.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onBook;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PackageCard({
    super.key,
    required this.package,
    this.onBook,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PackageDetailScreen(package: package)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image (Airbnb 4:3 crop)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'pkg-img-${package.id}',
                      child: package.imageUrls.isNotEmpty
                          ? Image.network(package.imageUrls.first, fit: BoxFit.cover, width: double.infinity)
                          : Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.landscape_outlined, size: 48, color: AppColors.textLight),
                            ),
                    ),
                    // Favourite heart (top-right) 
                    Positioned(
                      top: 12, right: 12,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, _) {
                          final isWishlisted = wishlist.isFavorite(package.id);
                          return GestureDetector(
                            onTap: () => wishlist.toggleFavorite(package),
                            child: Icon(
                              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isWishlisted ? AppColors.primary : Colors.white,
                              size: 26,
                              shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                            ),
                          );
                        },
                      ),
                    ),
                    // Duration badge (top-left)
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.schedule_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('${package.duration}d', style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain,
                          )),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info section (below image, like Airbnb)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 12, 2, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Destination + Star rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          package.destination,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<List<ReviewModel>>(
                        stream: FirestoreService().getReviewsForPackage(package.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final avg = snapshot.data!.map((r) => r.rating).reduce((a, b) => a + b) / snapshot.data!.length;
                          return Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.textMain),
                            const SizedBox(width: 2),
                            Text(avg.toStringAsFixed(1), style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain,
                            )),
                          ]);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Row 2: Address (muted, truncated)
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        package.address,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 6),

                  // Row 3: Price (bold) + per person
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text('₹${package.price.toStringAsFixed(0)}', style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textMain,
                    )),
                    const SizedBox(width: 4),
                    Text('/ person', style: AppTextStyles.caption),
                  ]),

                  // Highlights chip row
                  if (package.highlights.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: package.highlights.take(2).map((h) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(h, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
                      )).toList(),
                    ),
                  ],

                  // Agent edit/delete actions
                  if (showActions && (onEdit != null || onDelete != null)) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          _buildActionIcon(Icons.edit_outlined, AppColors.primary, onEdit!),
                        if (onDelete != null) ...[
                          const SizedBox(width: 8),
                          _buildActionIcon(Icons.delete_outline, AppColors.error, onDelete!),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
