import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/coins/coins_cubit.dart';
import '../../cubits/coins/coins_state.dart';

class TopBar extends StatelessWidget {
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;

  const TopBar({
    super.key,
    this.leadingIcon = Icons.menu_rounded,
    this.onLeadingPressed,
  });

  void _openDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);

    if (scaffold != null && scaffold.hasDrawer) {
      scaffold.openDrawer();
    }
  }

  bool _isChildMode(BuildContext context) {
    final state = context.watch<ChildModeCubit>().state;

    return state is ChildModeStatus && state.isChildMode;
  }

  void _loadCoinsIfNeeded(
      BuildContext context,
      CoinsState state,
      ) {
    if (state is! CoinsInitial) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final currentState = context.read<CoinsCubit>().state;

      if (currentState is CoinsInitial) {
        context.read<CoinsCubit>().loadCoins();
      }
    });
  }

  int _coinsFromState(CoinsState state) {
    if (state is CoinsLoaded) {
      return state.coins;
    }

    if (state is CoinsLoading) {
      return state.previousCoins;
    }

    if (state is CoinsError) {
      return state.previousCoins;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final showChildModeCoins = _isChildMode(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.92),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 13,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                _TopCircleButton(
                  onPressed:
                  onLeadingPressed ?? () => _openDrawer(context),
                  icon: leadingIcon,
                ),
                if (showChildModeCoins) ...[
                  const SizedBox(width: 8),
                  BlocBuilder<CoinsCubit, CoinsState>(
                    builder: (context, coinsState) {
                      _loadCoinsIfNeeded(context, coinsState);

                      return _ChildModeCoinsBadge(
                        count: _coinsFromState(coinsState),
                        isLoading: coinsState is CoinsLoading ||
                            coinsState is CoinsInitial,
                        hasError: coinsState is CoinsError,
                        onTap: () {
                          context.read<CoinsCubit>().refreshCoins();
                        },
                      );
                    },
                  ),
                ],
                const Spacer(),
                Image.asset(
                  'assets/icons/logo1.png',
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Text(
                      'Talento',
                      style: TextStyle(
                        fontFamily: 'BerlinSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildModeCoinsBadge extends StatelessWidget {
  final int count;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onTap;

  const _ChildModeCoinsBadge({
    required this.count,
    this.isLoading = false,
    this.hasError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 38,
      padding: const EdgeInsetsDirectional.fromSTEB(1, 3, 1, 3),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasError
              ? AppColors.error.withValues(alpha: 0.32)
              : const Color(0xFFD99A18).withValues(alpha: 0.38),
          width: 1.15,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD99A18).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-4, 0),
            child: Image.asset(
              'assets/icons/icon.png',
              width: 55,
              height: 55,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          Transform.translate(
            offset: const Offset(-15, 0),
            child: Container(
              width: 1,
              height: 20,
              margin: const EdgeInsetsDirectional.only(
                start: 1,
                end: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFD99A18)
                    .withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(-10, 0),
            child: SizedBox(
              width: 28,
              child: isLoading && count == 0
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFFD99500),
                ),
              )
                  : Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD99500),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0.1,
                  shadows: [
                    Shadow(
                      color: Color(0x22A86700),
                      blurRadius: 1.5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Tooltip(
      message: hasError
          ? 'تعذر تحديث الرصيد، اضغط للمحاولة مرة أخرى'
          : 'اضغط لتحديث الرصيد',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: content,
        ),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const _TopCircleButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
