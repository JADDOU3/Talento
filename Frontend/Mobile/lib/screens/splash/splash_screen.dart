import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_background.dart';
import '../../services/auth/token_storage_service.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../auth/login_screen.dart';
import '../home/new_user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    String? accessToken;
    String? refreshToken;

    try {
      accessToken = await TokenStorageService.getAccessToken()
          .timeout(const Duration(seconds: 5));
      refreshToken = await TokenStorageService.getRefreshToken()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      accessToken = null;
      refreshToken = null;
    }

    if (!mounted) return;

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      // ✅ نادي checkChildMode بعد ما نتأكد إنه logged in
      if (mounted) {
        context.read<ChildModeCubit>().checkChildMode();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NewUser()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/logo1.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
