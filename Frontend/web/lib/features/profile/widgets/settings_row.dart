// lib/features/profile/widgets/settings_row.dart
import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDanger;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            icon,
            color: isDanger ? Colors.red : const Color(0xFF2D4059),
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDanger ? Colors.red : const Color(0xFF1A1A2E),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDanger ? Colors.red.withOpacity(0.5) : Colors.grey[400],
            size: 20,
          ),
          onTap: onTap,
        ),
        const Divider(height: 4, color: Colors.grey),
      ],
    );
  }
}