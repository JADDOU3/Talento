import 'package:flutter/material.dart';
import 'qr_scanner_test_screen.dart';
import 'sensors_test_screen.dart';
import 'flame_test_screen.dart';
import 'forge2d_test_screen.dart';

class TestMenuScreen extends StatelessWidget {
  const TestMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      appBar: AppBar(
        title: const Text('Talento Tech Prototypes'),
        backgroundColor: const Color(0xFF10A896),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Technical Investigation Screens',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123835),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These screens are for testing libraries only. They are not production UI.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF60706D),
            ),
          ),
          const SizedBox(height: 24),

          _PrototypeButton(
            title: 'QR Scanner Prototype',
            subtitle: 'Test card scanning, debounce, haptic feedback',
            icon: Icons.qr_code_scanner,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QrScannerTestScreen(),
                ),
              );
            },
          ),

          _PrototypeButton(
            title: 'Gyroscope / Sensors Prototype',
            subtitle: 'Test device tilt for maze-style activities',
            icon: Icons.screen_rotation_alt,onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SensorsTestScreen(),
              ),
            );
          },
          ),

          _PrototypeButton(
            title: 'Flame Prototype',
            subtitle: 'Test mini game engine inside Flutter',
            icon: Icons.sports_esports,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FlameTestScreen(),
                ),
              );
            },
          ),

          _PrototypeButton(
            title: 'Forge2D Prototype',
            subtitle: 'Test physics for ball maze and collisions',
            icon: Icons.bubble_chart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Forge2DTestScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PrototypeButton extends StatelessWidget {
  const _PrototypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF10A896).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF10A896),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF123835),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF60706D),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Color(0xFF9AA7A4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}