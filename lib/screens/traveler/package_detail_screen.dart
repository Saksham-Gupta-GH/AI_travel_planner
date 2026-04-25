import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/package_model.dart';
import '../../models/booking_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/custom_button.dart';

class PackageDetailScreen extends StatefulWidget {
  final PackageModel package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  int _currentImage = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final wishlist = context.watch<WishlistProvider>();
    final isFav = wishlist.isFavorite(package.id);

    return Scaffold(
      endDrawer: AiAssistantSidebar(
        title: 'Trip Expert',
        contextData: 'Dest: ${package.destination}, Price: ${package.price}, Stay: ${package.duration} days. Desc: ${package.description}',
      ),
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Current image
                  if (package.imageUrls.isNotEmpty)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.network(
                        package.imageUrls[_currentImage],
                        key: ValueKey(_currentImage),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else
                    Container(color: AppColors.primary),

                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),

                  // Left arrow
                  if (package.imageUrls.length > 1 && _currentImage > 0)
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentImage--),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),

                  // Right arrow
                  if (package.imageUrls.length > 1 && _currentImage < package.imageUrls.length - 1)
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentImage++),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ),

                  // Dot indicator
                  if (package.imageUrls.length > 1)
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(package.imageUrls.length, (i) {
                          final active = i == _currentImage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
              title: Text(
                package.destination,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.error : Colors.white,
                ),
                onPressed: () => wishlist.toggleFavorite(package),
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.background),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Agent & Price Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                            ),
                            child: const CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.surface,
                              child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURATED BY', style: AppTextStyles.caption.copyWith(fontSize: 10, letterSpacing: 1.5)),
                              Text(package.agentName, style: AppTextStyles.title.copyWith(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${package.price.toStringAsFixed(0)}',
                              style: AppTextStyles.heading.copyWith(color: AppColors.accentDark, fontSize: 32)),
                          Text('per traveler', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Highlights
                  Text('The Experience', style: AppTextStyles.heading.copyWith(fontSize: 22)),
                  const SizedBox(height: 24),
                  if (package.highlights.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: package.highlights.map((h) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildHighlight(_getHighlightIcon(h), h),
                        )).toList(),
                      ),
                    )
                  else
                    Text('No highlights specified', style: AppTextStyles.caption),
                  
                  const SizedBox(height: 48),

                  // Description
                  Text('About this Journey', style: AppTextStyles.subtitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  Text(package.description, style: AppTextStyles.body.copyWith(fontSize: 16, color: AppColors.textMuted)),
                  
                  const SizedBox(height: 48),

                  // Itinerary
                  Text('The Path', style: AppTextStyles.subtitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 24),
                  if (package.itinerary.isNotEmpty)
                    ...List.generate(package.itinerary.length, (index) {
                      return _buildItineraryStep(index + 1, package.itinerary[index]);
                    })
                  else
                    Text('Itinerary details coming soon!', style: AppTextStyles.caption),
                  
                  const SizedBox(height: 48),

                  // Map Section
                  Text('Location Details', style: AppTextStyles.subtitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place_rounded, size: 22, color: AppColors.accentDark),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${package.address}, ${package.destination}',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                      boxShadow: AppShadows.light,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (package.latitude != null && package.longitude != null)
                        ? FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(package.latitude!, package.longitude!),
                              initialZoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                                userAgentPackageName: 'com.saksham.web_app_travel_planner',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(package.latitude!, package.longitude!),
                                    width: 80,
                                    height: 80,
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.accentDark,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Center(child: Text('Map location not available')),
                  ),

                  const SizedBox(height: 32),


                  // Reviews Section
                  Text('Echoes from Travelers', style: AppTextStyles.subtitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 24),
                  StreamBuilder<List<ReviewModel>>(
                    stream: FirestoreService().getReviewsForPackage(package.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.comment_bank_outlined, size: 64, color: AppColors.primary.withOpacity(0.1)),
                                const SizedBox(height: 16),
                                Text('No stories shared yet.', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        );
                      }
                      final reviews = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                              boxShadow: AppShadows.light,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryLight,
                                      child: Text(review.userName[0].toUpperCase(),
                                          style: AppTextStyles.title.copyWith(color: AppColors.primary, fontSize: 14)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(review.userName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                                          Text(DateFormat('MMM d, y').format(review.createdAt), style: AppTextStyles.caption.copyWith(fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (idx) => Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: idx < review.rating ? AppColors.accentDark : AppColors.divider,
                                      )),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(review.comment, style: AppTextStyles.body.copyWith(fontSize: 14)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 120), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: CustomButton(
          text: 'Request This Journey',
          onPressed: () => _showBookingDialog(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHighlight(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        const SizedBox(height: 8),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildItineraryStep(int day, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('D$day', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day $day Activities', style: AppTextStyles.subtitle),
                Text(description,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModernBookingSheet(package: widget.package),
    );
  }

  IconData _getHighlightIcon(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('stay') || lower.contains('hotel')) return Icons.hotel_outlined;
    if (lower.contains('meal') || lower.contains('food')) return Icons.restaurant_outlined;
    if (lower.contains('days')) return Icons.timer_outlined;
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('tour') || lower.contains('guide')) return Icons.map_outlined;
    if (lower.contains('pool')) return Icons.pool_outlined;
    return Icons.check_circle_outline;
  }
}

class _ModernBookingSheet extends StatefulWidget {
  final PackageModel package;
  const _ModernBookingSheet({required this.package});

  @override
  State<_ModernBookingSheet> createState() => _ModernBookingSheetState();
}

class _ModernBookingSheetState extends State<_ModernBookingSheet> {
  DateTime? _travelDate;
  int _numPeople = 1;
  String _paymentMode = 'Card'; // 'Card' or 'UPI'
  
  // Card Controllers
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  
  // UPI Controllers
  final _upiIdController = TextEditingController();
  final _upiPasswordController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _travelDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reserve spot', style: AppTextStyles.heading.copyWith(fontSize: 24)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: _pickDate,
              leading: const Icon(Icons.calendar_month, color: AppColors.accent),
              title: const Text('Travel Date'),
              subtitle: Text(_travelDate == null ? 'Select Date' : DateFormat('MMM d, y').format(_travelDate!)),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            ),
            const SizedBox(height: 16),
            // People Count Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: AppColors.accent),
                  const SizedBox(width: 16),
                  const Expanded(child: Text('Number of People', style: TextStyle(fontSize: 14))),
                  Row(
                    children: [
                      IconButton(
                          onPressed: _numPeople > 1 ? () => setState(() => _numPeople--) : null,
                          icon: const Icon(Icons.remove_circle_outline)),
                      Text('$_numPeople', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                          onPressed: _numPeople < 20 ? () => setState(() => _numPeople++) : null,
                          icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment Mode Selection
            Text('Payment Method', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPaymentChoice('Card', Icons.credit_card),
                const SizedBox(width: 12),
                _buildPaymentChoice('UPI', Icons.qr_code_scanner),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_paymentMode == 'Card') ...[
              TextField(
                controller: _cardNumberController,
                decoration: AppDecorations.inputDecoration('Card Number', prefixIcon: Icons.numbers),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: _cardExpiryController,
                    decoration: AppDecorations.inputDecoration('MM/YY', prefixIcon: Icons.calendar_today),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: _cardCvvController,
                    decoration: AppDecorations.inputDecoration('CVV', prefixIcon: Icons.lock_outline),
                    obscureText: true,
                  )),
                ],
              ),
            ] else ...[
              TextField(
                controller: _upiIdController,
                decoration: AppDecorations.inputDecoration('UPI ID (e.g. user@bank)', prefixIcon: Icons.alternate_email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _upiPasswordController,
                decoration: AppDecorations.inputDecoration('UPI Password / PIN', prefixIcon: Icons.password),
                obscureText: true,
              ),
            ],
            
            const SizedBox(height: 24),
            // Price Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹${(widget.package.price * _numPeople).toStringAsFixed(0)}',
                      style: AppTextStyles.title.copyWith(color: AppColors.accent)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_travelDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a travel date')));
                    return;
                  }
                  
                  String details = '';
                  if (_paymentMode == 'Card') {
                    details = 'Card: ${_cardNumberController.text}, Exp: ${_cardExpiryController.text}';
                  } else {
                    details = 'UPI ID: ${_upiIdController.text}';
                  }
                  
                  final auth = context.read<AuthProvider>();
                  final booking = BookingModel(
                    id: '',
                    userId: auth.userId,
                    userName: auth.userName,
                    packageId: widget.package.id,
                    packageDestination: widget.package.destination,
                    packagePrice: widget.package.price,
                    numPeople: _numPeople,
                    travelDate: _travelDate!,
                    paymentMethod: _paymentMode,
                    paymentDetails: details,
                    qrCodeData: 'TICKET: ${widget.package.destination}\n'
                                'TRAVELER: ${auth.userName}\n'
                                'PEOPLE: $_numPeople\n'
                                'DATE: ${DateFormat('MMM d, y').format(_travelDate!)}\n'
                                'VALID FOR: ${widget.package.duration} DAYS',
                    status: BookingStatus.pending,
                    createdAt: DateTime.now(),
                  );
                  
                  await FirestoreService().createBooking(booking);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Requested! Waiting for Agent Approval.')));
                  }
                },
                child: const Text('Confirm & Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentChoice(String mode, IconData icon) {
    bool isSelected = _paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textLight),
              const SizedBox(width: 8),
              Text(mode, style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
