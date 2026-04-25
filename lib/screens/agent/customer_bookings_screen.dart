import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/package_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/loading_indicator.dart';

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      endDrawer: const AiAssistantSidebar(),
      appBar: AppBar(
        title: const Text('Customer Bookings'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<PackageModel>>(
        stream: firestoreService.getPackagesByAgent(authProvider.userId),
        builder: (context, packageSnapshot) {
          if (packageSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          final packages = packageSnapshot.data ?? [];
          final packageIds = packages.map((p) => p.id).toSet();
          final packageMap = {for (var p in packages) p.id: p};

          return StreamBuilder<List<BookingModel>>(
            stream: firestoreService.getAllBookings(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              }

              final allBookings = bookingSnapshot.data ?? [];
              final agentBookings = allBookings
                  .where((b) => packageIds.contains(b.packageId))
                  .toList();

              if (agentBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No customer bookings yet',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agentBookings.length,
                itemBuilder: (context, index) {
                  final booking = agentBookings[index];
                  final package = packageMap[booking.packageId];
                  return _buildBookingCard(
                    context,
                    booking,
                    package,
                    firestoreService,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    BookingModel booking,
    PackageModel? package,
    FirestoreService firestoreService,
  ) {
    Color statusColor;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = AppColors.success;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

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
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    booking.userName.isNotEmpty
                        ? booking.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.userName, style: AppTextStyles.title),
                      Text(
                        'Booked: ${booking.packageDestination}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Price', style: AppTextStyles.caption),
                          Text(
                            '₹${(booking.packagePrice * booking.numPeople).toStringAsFixed(0)}',
                            style: AppTextStyles.title,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('People', style: AppTextStyles.caption),
                          Text(
                            '${booking.numPeople}',
                            style: AppTextStyles.title,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Travel date: ${DateFormat('MMM d, y').format(booking.travelDate)}',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payment: ${booking.paymentMethod}',
                    style: AppTextStyles.body,
                  ),
                  if (booking.status == BookingStatus.declined && booking.declineReason != null) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 4),
                    Text('Decline Reason:', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                    Text(booking.declineReason!, style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showDeclineDialog(context, booking, firestoreService),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAcceptDialog(context, booking, firestoreService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, BookingModel booking, FirestoreService firestoreService) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Booking'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for declining',
            hintText: 'e.g., Sold out for these dates',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              firestoreService.declineBooking(booking.id, controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, BookingModel booking, FirestoreService firestoreService) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Confirm Booking')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking for ${booking.packageDestination} will be confirmed.',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Message to traveller (optional)',
                hintText: 'e.g., Looking forward to your trip! Please carry your ID.',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreService.confirmBookingWithMessage(booking.id, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );
  }
}
