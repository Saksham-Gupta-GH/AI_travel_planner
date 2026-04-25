import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  static const String appName = 'Dashr';
  static const String appVersion = '1.0.0';
  static const String roleTraveler = 'traveler';
  static const String roleAgent = 'agent';
  static const String roleAdmin = 'admin';
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCancelled = 'cancelled';
  static const String usersCollection = 'users';
  static const String packagesCollection = 'packages';
  static const String bookingsCollection = 'bookings';
}

class AppColors {
  // True Warm Red — easy on the eyes, not pinkish
  static const Color primary = Color(0xFFE53935);      // Material Red 600
  static const Color primaryDark = Color(0xFFC62828);  // Deep Red
  static const Color primaryLight = Color(0xFFFFEBEE);  // Very light red tint

  static const Color accent = Color(0xFF00897B);        // Teal (softer)
  static const Color accentDark = Color(0xFF00695C);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Neutral light gray

  static const Color success = Color(0xFF388E3C);       // Green
  static const Color warning = Color(0xFFF57C00);       // Amber
  static const Color error = Color(0xFFB71C1C);         // Dark red for errors

  static const Color textMain = Color(0xFF212121);      // Near-black
  static const Color textMuted = Color(0xFF757575);     // Gray
  static const Color textLight = Color(0xFFBDBDBD);     // Light gray

  static const Color divider = Color(0xFFE0E0E0);
  static const Color transparent = Colors.transparent;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static List<BoxShadow> light = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> soft = [
    BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> deep = [
    BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 32, offset: const Offset(0, 8)),
  ];
}

class AppTextStyles {
  static TextStyle heading = GoogleFonts.plusJakartaSans(
    fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textMain, letterSpacing: -0.5,
  );
  static TextStyle title = GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain,
  );
  static TextStyle subtitle = GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain,
  );
  static TextStyle body = GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textMain, height: 1.5,
  );
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textMuted,
  );
}

class AppDecorations {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: AppShadows.light,
  );

  static InputDecoration inputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontWeight: FontWeight.w400),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textMuted, size: 20) : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.textMain, width: 1.5)),
    );
  }
}
