import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import '../../models/activities/tower_builder/tower_builder_checklist_item_model.dart';
import '../../services/auth/auth_api_client.dart';
import '../../shared/layout/app_background.dart';
import 'tower_builder_checklist_screen.dart';

class TowerBuilderPinScreen extends StatefulWidget {
  final List<TowerBuilderChecklistItemModel> checklist;
  final int currentAttemptId;
  final String? targetImageUrl;

  const TowerBuilderPinScreen({
    super.key,
    required this.checklist,
    required this.currentAttemptId,
    required this.targetImageUrl,
  });

  @override
  State<TowerBuilderPinScreen> createState() => _TowerBuilderPinScreenState();
}

class _TowerBuilderPinScreenState extends State<TowerBuilderPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final AuthApiClient _client = AuthApiClient();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (pin.length != 6) {
      setState(() {
        _errorMessage = 'الرقم السري غير صحيح، حاول مجدداً';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verifyPinUrl = '${ApiConstants.baseUrl}/childMode/verifyPin';

      debugPrint('TOWER BUILDER VERIFY PIN URL: $verifyPinUrl');

      final response = await _client.post(
        Uri.parse(verifyPinUrl),
        body: jsonEncode({
          'pin': pin,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final cubit = context.read<TowerBuilderCubit>();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: TowerBuilderChecklistScreen(
                checklist: widget.checklist,
                currentAttemptId: widget.currentAttemptId,
                targetImageUrl: widget.targetImageUrl,
              ),
            ),
          ),
        );
        return;
      }

      if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'الرقم السري غير صحيح، حاول مجدداً';
        });
        return;
      }

      setState(() {
        _errorMessage = 'حدث خطأ، حاول مجدداً';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'حدث خطأ، حاول مجدداً';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  Text(
                    'هذا القسم للوالدين فقط',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'أدخل الرقم السري للمتابعة',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      errorText: _errorMessage,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _verifyPin();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPin,
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('إرسال'),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}