import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/loading_indicator.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
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
      final authProvider = context.read<AuthProvider>();
      final packages = await _firestoreService
          .getPackagesByAgent(authProvider.userId)
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () => []);
      final allBookings = await _firestoreService
          .getAllBookings()
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () => []);

      final packageIds = packages.map((p) => p.id).toSet();
      final agentBookings = allBookings.where((b) => packageIds.contains(b.packageId)).toList();

      if (mounted) {
        setState(() {
          _stats = {
            'myPackages': packages.length,
            'totalBookings': agentBookings.length,
            'pendingBookings': agentBookings.where((b) => b.status.name == 'pending').length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _stats = {'myPackages': 0, 'totalBookings': 0, 'pendingBookings': 0}; _isLoading = false; });
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
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.travel_explore, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Dashr', style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5,
            )),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Agent', style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted,
              )),
            ),
          ],
        ),
        actions: [
          Builder(builder: (ctx) => IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          )),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authProvider.logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'logout', child: Row(children: [
                const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                const SizedBox(width: 12),
                Text('Sign Out', style: AppTextStyles.body),
              ])),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.textMain,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A',
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
                    const Divider(height: 1),

                    // Greeting
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, $firstName',
                            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain),
                          ),
                          const SizedBox(height: 4),
                          Text('Here\'s what\'s happening today', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCard('Packages', _stats['myPackages'] ?? 0, Icons.card_travel_outlined, AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Bookings', _stats['totalBookings'] ?? 0, Icons.receipt_long_outlined, AppColors.success)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Pending', _stats['pendingBookings'] ?? 0, Icons.hourglass_empty_rounded, AppColors.warning)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1)),
                    const SizedBox(height: 24),

                    // Quick actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Actions', style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted,
                      )),
                    ),
                    const SizedBox(height: 16),
                    _buildNavTile(context,
                      icon: Icons.add_circle_outline_rounded,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      title: 'Create Package',
                      subtitle: 'Add a new travel destination',
                      route: AppRoutes.createPackage,
                    ),
                    _buildNavTile(context,
                      icon: Icons.list_alt_rounded,
                      iconBg: const Color(0xFFEDE7F6),
                      iconColor: const Color(0xFF7B1FA2),
                      title: 'My Packages',
                      subtitle: 'Manage your existing packages',
                      route: AppRoutes.managePackages,
                    ),
                    _buildNavTile(context,
                      icon: Icons.people_alt_outlined,
                      iconBg: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1976D2),
                      title: 'Customer Bookings',
                      subtitle: 'Review and manage traveller bookings',
                      route: AppRoutes.customerBookings,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, {
    required IconData icon, required Color iconBg, required Color iconColor,
    required String title, required String subtitle, required String route,
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
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            )),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}
