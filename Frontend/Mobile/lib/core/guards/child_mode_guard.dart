import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';

class ChildModeGuard {
  static bool isChildMode(BuildContext context) {
    final state = context.read<ChildModeCubit>().state;

    return state is ChildModeStatus && state.isChildMode;
  }

  static bool shouldBlockJournal(BuildContext context) {
    return isChildMode(context);
  }
}