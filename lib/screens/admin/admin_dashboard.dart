import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/ai_assistant_sidebar.dart';
import '../../widgets/loading_indicator.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _popularDestinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _firestoreService.getStatistics();
      final destinations = await _firestoreService.getPopularDestinations();

      if (mounted) {
        setState(() {
          _stats = stats;
          _popularDestinations = destinations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = {};
          _popularDestinations = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

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
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(6)),
              child: Text('Admin', style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted,
              )),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final navigator = Navigator.of(context);
                await authProvider.logout();
                if (!mounted) return;
                navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
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
                  authProvider.userName.isNotEmpty ? authProvider.userName[0].toUpperCase() : 'A',
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
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Panel', style: GoogleFonts.plusJakartaSans(
                            fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textMain,
                          )),
                          const SizedBox(height: 4),
                          Text('System overview & management', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    
                    // Pending Admin Approvals Section
                    StreamBuilder<List<UserModel>>(
                      stream: FirestoreService().getUsersByRole('admin'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final pendingAdmins = snapshot.data!.where((u) => !u.isApproved).toList();
                        if (pendingAdmins.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.privacy_tip_outlined, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Text('Pending Approvals', style: AppTextStyles.title.copyWith(color: AppColors.error)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...pendingAdmins.map((admin) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withOpacity(0.18)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.error.withOpacity(0.15),
                                    child: Text(
                                      admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
                                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(admin.name,
                                          style: AppTextStyles.subtitle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(admin.email,
                                          style: AppTextStyles.caption,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton(
                                    onPressed: () async {
                                      await FirestoreService().updateUser(admin.id, {'isApproved': true});
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${admin.name} approved!'))
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      backgroundColor: AppColors.error.withOpacity(0.1),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // Statistics
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Overview', style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted,
                      )),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('Users', _stats['totalUsers'] ?? 0, Icons.people_outline, AppColors.primary)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard('Agents', _stats['totalAgents'] ?? 0, Icons.support_agent_outlined, AppColors.accent)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('Packages', _stats['totalPackages'] ?? 0, Icons.card_travel_outlined, AppColors.success)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard('Bookings', _stats['totalBookings'] ?? 0, Icons.receipt_long_outlined, AppColors.warning)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1)),
                    const SizedBox(height: 24),

                    // Popular Destinations
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Top Destinations', style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted,
                      )),
                    ),
                    const SizedBox(height: 12),
                    if (_popularDestinations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('No destinations data yet', style: AppTextStyles.caption),
                      )
                    else
                      ...List.generate(
                        _popularDestinations.length > 5 ? 5 : _popularDestinations.length,
                        (index) {
                          final dest = _popularDestinations[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryLight,
                              child: Text('${index + 1}', style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary,
                              )),
                            ),
                            title: Text(dest['destination'], style: AppTextStyles.subtitle),
                            trailing: Text('${dest['count']} bookings', style: AppTextStyles.caption),
                          );
                        },
                      ),
                    const SizedBox(height: 28),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1)),
                    const SizedBox(height: 24),

                    // Management
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Management', style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted,
                      )),
                    ),
                    const SizedBox(height: 16),
                    _buildActionTile('Manage Users', Icons.people_alt_outlined, const Color(0xFFE3F2FD), const Color(0xFF1976D2), AppRoutes.manageUsers),
                    _buildActionTile('Manage Agents', Icons.support_agent_outlined, const Color(0xFFEDE7F6), const Color(0xFF7B1FA2), AppRoutes.manageAgents),
                    _buildActionTile('System Monitor', Icons.monitor_heart_outlined, const Color(0xFFE8F5E9), AppColors.success, AppRoutes.systemMonitor),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('$value', style: GoogleFonts.plusJakartaSans(
              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain,
            )),
          ),
          const SizedBox(height: 2),
          Text(title,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color iconBg, Color iconColor, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.subtitle)),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}
