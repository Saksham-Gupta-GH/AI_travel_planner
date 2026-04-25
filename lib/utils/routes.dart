import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/traveler/traveler_dashboard.dart';
import '../screens/traveler/package_list_screen.dart';
import '../screens/traveler/booking_history_screen.dart';
import '../screens/agent/agent_dashboard.dart';
import '../screens/agent/create_package_screen.dart';
import '../screens/agent/manage_packages_screen.dart';
import '../screens/agent/customer_bookings_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_agents_screen.dart';
import '../screens/admin/system_monitor_screen.dart';
import '../screens/agent/location_picker_screen.dart';
import '../screens/traveler/world_explorer_screen.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Traveler routes
  static const String travelerDashboard = '/traveler-dashboard';
  static const String packageList = '/package-list';
  static const String bookingHistory = '/booking-history';

  // Agent routes
  static const String agentDashboard = '/agent-dashboard';
  static const String createPackage = '/create-package';
  static const String managePackages = '/manage-packages';
  static const String customerBookings = '/customer-bookings';

  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String manageUsers = '/manage-users';
  static const String manageAgents = '/manage-agents';
  static const String systemMonitor = '/system-monitor';

  // Map routes
  static const String worldExplorer = '/world-explorer';
  static const String locationPicker = '/location-picker';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Auth
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),

      // Traveler
      travelerDashboard: (context) => const TravelerDashboard(),
      packageList: (context) => const PackageListScreen(),
      bookingHistory: (context) => const BookingHistoryScreen(),

      // Agent
      agentDashboard: (context) => const AgentDashboard(),
      createPackage: (context) => const CreatePackageScreen(),
      managePackages: (context) => const ManagePackagesScreen(),
      customerBookings: (context) => const CustomerBookingsScreen(),

      // Admin
      adminDashboard: (context) => const AdminDashboard(),
      manageUsers: (context) => const ManageUsersScreen(),
      manageAgents: (context) => const ManageAgentsScreen(),
      systemMonitor: (context) => const SystemMonitorScreen(),

      // Maps
      worldExplorer: (context) => const WorldExplorerScreen(),
      locationPicker: (context) => const LocationPickerScreen(),
    };
  }

  // Get initial route based on auth state and role
  static String getInitialRoute(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return login;
    }

    switch (authProvider.userRole) {
      case 'traveler':
        return travelerDashboard;
      case 'agent':
        return agentDashboard;
      case 'admin':
        return adminDashboard;
      default:
        return login;
    }
  }

  // Navigate based on role
  static void navigateBasedOnRole(BuildContext context, String role) {
    String route;
    switch (role) {
      case 'traveler':
        route = travelerDashboard;
        break;
      case 'agent':
        route = agentDashboard;
        break;
      case 'admin':
        route = adminDashboard;
        break;
      default:
        route = login;
    }

    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}
