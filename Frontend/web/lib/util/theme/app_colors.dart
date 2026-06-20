import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 🎨 Brand Colors
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color coral = Color(0xFFFF6B6B);

  // 🔹 Deep Blue (The color you wanted to use instead of green)
  static const Color deepBlue = Color(0xFF0B2F5C);

  // 📝 Typography
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B7280);

  // 🏠 Backgrounds & UI
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color shadow = Color(0x14000000);

  // 🛒 Cart/Specialized UI
  static const Color cartPageBackground = Color(0xFFF5F0EB); // Added this back
  static const Color cartTeal = deepBlue;        // Maps your "Teal" calls to the new Blue
  static const Color yellow = Color(0xFFFFC107); // Added back
  static const Color cartSummaryPink = Color(0xFFFFD6D6);
  static const Color cartApplyPink = Color(0xFFFF9FA8);
  static const Color cartDeliveryCard = Colors.white;
  static const Color cartForestGreen = Color(0xFF1B4332);
  static const Color cartMutedGrey = Color(0xFF8A8A8A);
  static const Color cartStepperPink = Color(0xFFFF8FA3);
  static const Color cartTotalRose = Color(0xFFD64562);
  static const Color teal = deepBlue;
}