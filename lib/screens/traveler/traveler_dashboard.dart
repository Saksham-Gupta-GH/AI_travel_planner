import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/loading_indicator.dart';

class TravelerDashboard extends StatefulWidget {
  const TravelerDashboard({super.key});

  @override
  State<TravelerDashboard> createState() => _TravelerDashboardState();
}

class _TravelerDashboardState extends State<TravelerDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = context.read<AuthProvider>().userId;
      final stats = await _firestoreService.getStatistics();
      final bookings = await _firestoreService
          .getBookingsByUser(userId)
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () => []);

      if (mounted) {
        setState(() {
          _stats = {
            'myBookings': bookings.length,
            'totalPackages': stats['totalPackages'] ?? 0,
            'confirmedBookings': bookings
                .where((b) => b.status.name == 'confirmed')
                .length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _stats = {'myBookings': 0, 'totalPackages': 0, 'confirmedBookings': 0}; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final firstName = authProvider.userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const AiAssistantSidebar(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 20,
        toolbarHeight: 64,
        title: Row(
          children: [
            // Airbnb-style logo mark
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.travel_explore, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Dashr', style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5,
            )),
          ],
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.auto_awesome_outlined, color: AppColors.textMain),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              tooltip: 'AI Assistant',
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final auth = context.read<AuthProvider>();
                await auth.logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text('Sign Out', style: AppTextStyles.body),
                ]),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.textMain,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, thickness: 0.8),

                    // ── Hero greeting
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back, $firstName',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Where are you going next?',
                            style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCard('Trips', _stats['myBookings'] ?? 0, Icons.luggage_outlined)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Confirmed', _stats['confirmedBookings'] ?? 0, Icons.check_circle_outline)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Available', _stats['totalPackages'] ?? 0, Icons.explore_outlined)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 1),
                    ),
                    const SizedBox(height: 24),

                    // ── Navigation section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Quick Links', style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted,
                      )),
                    ),
                    const SizedBox(height: 16),
                    _buildNavTile(
                      context,
                      icon: Icons.search_rounded,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      title: 'Find Your Escape',
                      subtitle: 'Browse destinations & packages',
                      route: AppRoutes.packageList,
                    ),
                    _buildNavTile(
                      context,
                      icon: Icons.receipt_long_outlined,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: AppColors.success,
                      title: 'My Bookings',
                      subtitle: 'View booking history & tickets',
                      route: AppRoutes.bookingHistory,
                    ),
                    _buildNavTile(
                      context,
                      icon: Icons.map_outlined,
                      iconBg: const Color(0xFFE3F2FD),
                      iconColor: Color(0xFF1976D2),
                      title: 'World Map',
                      subtitle: 'Explore destinations on the globe',
                      route: AppRoutes.worldExplorer,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(height: 8),
          Text('$value', style: GoogleFonts.plusJakartaSans(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain,
          )),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}
