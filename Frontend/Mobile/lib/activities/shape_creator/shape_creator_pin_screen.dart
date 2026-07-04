import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../models/activities/shape_creator/shape_creator_checklist_item_model.dart';
import '../../services/child_mode_service.dart';
import '../../shared/layout/app_background.dart';
import 'shape_creator_checklist_screen.dart';

class ShapeCreatorPinScreen extends StatefulWidget {
  final List<ShapeCreatorChecklistItemModel> checklist;
  final int currentAttemptId;
  final String? targetImageUrl;

  const ShapeCreatorPinScreen({
    super.key,
    required this.checklist,
    required this.currentAttemptId,
    required this.targetImageUrl,
  });

  @override
  State<ShapeCreatorPinScreen> createState() => _ShapeCreatorPinScreenState();
}

class _ShapeCreatorPinScreenState extends State<ShapeCreatorPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final ChildModeService _childModeService = ChildModeService();

  bool _loading = false;
  String? _error;

  Future<void> _verifyPin() async {
    if (_pinController.text.length != 6) {
      setState(() {
        _error = 'الرقم السري يجب أن يتكون من 6 أرقام';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final verified = await _childModeService.verifyPin(
        _pinController.text,
      );

      if (!mounted) return;

      if (verified) {
        setState(() {
          _loading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ShapeCreatorCubit>(),
              child: ShapeCreatorChecklistScreen(
                checklist: widget.checklist,
                currentAttemptId: widget.currentAttemptId,
                targetImageUrl: widget.targetImageUrl,
              ),
            ),
          ),
        );

        return;
      }

      setState(() {
        _error = 'الرقم السري غير صحيح، حاول مجدداً';
      });
    } catch (_) {
      setState(() {
        _error = 'حدث خطأ أثناء التحقق من الرقم السري';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      if (!_loading) {
                        _verifyPin();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _loading ? null : _verifyPin,
                    child: _loading
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