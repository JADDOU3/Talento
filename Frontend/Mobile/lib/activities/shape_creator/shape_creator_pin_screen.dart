import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../models/activities/shape_creator/shape_creator_checklist_item_model.dart';
//import '../../services/child_mode_service.dart';
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
  State<ShapeCreatorPinScreen> createState() =>
      _ShapeCreatorPinScreenState();
}

class _ShapeCreatorPinScreenState
    extends State<ShapeCreatorPinScreen> {
  final TextEditingController _pinController =
      TextEditingController();

 //final ChildModeService _childModeService =
      //ChildModeService();

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
      //final verified = await _childModeService.verifyPin(
        //_pinController.text,
        final verified = true;
        //مؤقت
      //);

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

      // setState(() {
      //   _error = 'الرقم السري غير صحيح، حاول مجدداً';
      // });
      //مؤقت
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
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'هذا القسم للوالدين فقط',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'أدخل الرقم السري للمتابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '******',
                    errorText: _error,
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _loading ? null : _verifyPin,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('إرسال'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}