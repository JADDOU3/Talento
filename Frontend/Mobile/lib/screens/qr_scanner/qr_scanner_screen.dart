import 'package:flutter/material.dart';

import '../../shared/widgets/app_background.dart';
import 'widgets/camera_viewfinder.dart';
import 'widgets/pro_tip_card.dart';
import 'widgets/scanner_action_button.dart';
import 'widgets/scanner_badge.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Column(
            children: [
              ScannerBadge(),
              SizedBox(height: 26),
              CameraViewfinder(),
              SizedBox(height: 24),
              ProTipCard(),
              SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ScannerActionButton(
                      icon: Icons.auto_awesome_rounded,
                      label: 'MAGIC FOUND',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: ScannerActionButton(
                      icon: Icons.lock_rounded,
                      label: 'LOCKED QUEST',
                      isMuted: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}