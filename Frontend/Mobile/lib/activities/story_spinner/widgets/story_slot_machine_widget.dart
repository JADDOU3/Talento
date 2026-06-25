import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activities/story_spinner/icon_arabic_labels.dart';

TextDirection _directionForText(String text) {
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  return hasArabic ? TextDirection.rtl : TextDirection.ltr;
}

String _cleanIconName(String icon) {
  var clean = icon.trim();

  if (clean.endsWith('.png')) {
    clean = clean.substring(0, clean.length - 4);
  }

  if (clean.contains('/')) {
    clean = clean.split('/').last;
  }

  return clean.trim();
}

List<String> _cleanIconList(List<String> icons) {
  return icons
      .map(_cleanIconName)
      .where((icon) => icon.isNotEmpty)
      .toSet()
      .toList();
}

String _displayNameForIcon(String icon) {
  final cleanIcon = _cleanIconName(icon);

  return iconArabicLabels[cleanIcon] ?? cleanIcon.replaceAll('_', ' ');
}

String? _iconAtOffset({
  required List<String> icons,
  required String? currentIcon,
  required int offset,
}) {
  final cleanIcons = _cleanIconList(icons);

  if (cleanIcons.isEmpty) return null;

  final cleanCurrent = currentIcon == null ? '' : _cleanIconName(currentIcon);
  var currentIndex = cleanIcons.indexOf(cleanCurrent);

  if (currentIndex < 0) currentIndex = 0;

  final index = (currentIndex + offset + cleanIcons.length) % cleanIcons.length;
  return cleanIcons[index];
}

class StorySlotMachineWidget extends StatefulWidget {
  final String characterQuestion;
  final String eventQuestion;
  final String placeQuestion;
  final List<String> characterIcons;
  final List<String> eventIcons;
  final List<String> placeIcons;
  final String? characterLandedIcon;
  final String? eventLandedIcon;
  final String? placeLandedIcon;
  final bool disabled;
  final ValueChanged<bool> onSpinningChanged;
  final ValueChanged<String> onStepSpinStarted;
  final void Function(String step, String icon) onStepLanded;

  const StorySlotMachineWidget({
    super.key,
    required this.characterQuestion,
    required this.eventQuestion,
    required this.placeQuestion,
    required this.characterIcons,
    required this.eventIcons,
    required this.placeIcons,
    required this.characterLandedIcon,
    required this.eventLandedIcon,
    required this.placeLandedIcon,
    required this.disabled,
    required this.onSpinningChanged,
    required this.onStepSpinStarted,
    required this.onStepLanded,
  });

  @override
  State<StorySlotMachineWidget> createState() => _StorySlotMachineWidgetState();
}

class _StorySlotMachineWidgetState extends State<StorySlotMachineWidget> {
  final math.Random _random = math.Random();

  Timer? _shuffleTimer;

  bool _didPrecacheImages = false;
  bool _isSpinning = false;
  bool _characterRunning = false;
  bool _eventRunning = false;
  bool _placeRunning = false;

  String? _characterDisplayIcon;
  String? _eventDisplayIcon;
  String? _placeDisplayIcon;

  @override
  void initState() {
    super.initState();
    _syncDisplayIcons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didPrecacheImages) {
      _didPrecacheImages = true;
      _precacheSlotImages();
    }
  }

  @override
  void didUpdateWidget(covariant StorySlotMachineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isSpinning) {
      _syncDisplayIcons();
    }

    if (oldWidget.characterIcons != widget.characterIcons ||
        oldWidget.eventIcons != widget.eventIcons ||
        oldWidget.placeIcons != widget.placeIcons) {
      _precacheSlotImages();
    }
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  void _precacheSlotImages() {
    final icons = <String>{
      ..._cleanIconList(widget.characterIcons),
      ..._cleanIconList(widget.eventIcons),
      ..._cleanIconList(widget.placeIcons),
    };

    for (final icon in icons) {
      precacheImage(
        AssetImage('assets/images/cards/$icon.png'),
        context,
      ).catchError((_) {});
    }
  }

  void _syncDisplayIcons() {
    _characterDisplayIcon = _iconOrFirst(
      widget.characterLandedIcon,
      widget.characterIcons,
    );
    _eventDisplayIcon = _iconOrFirst(
      widget.eventLandedIcon,
      widget.eventIcons,
    );
    _placeDisplayIcon = _iconOrFirst(
      widget.placeLandedIcon,
      widget.placeIcons,
    );
  }

  String? _iconOrFirst(String? icon, List<String> icons) {
    final cleanIcon = icon == null ? null : _cleanIconName(icon);

    if (cleanIcon != null && cleanIcon.isNotEmpty) {
      return cleanIcon;
    }

    final cleanIcons = _cleanIconList(icons);

    if (cleanIcons.isEmpty) return null;

    return cleanIcons.first;
  }

  String _randomIcon(List<String> cleanIcons) {
    return cleanIcons[_random.nextInt(cleanIcons.length)];
  }

  void _startShuffleTimer() {
    _shuffleTimer?.cancel();

    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 95), (_) {
      if (!mounted) return;

      if (!_characterRunning && !_eventRunning && !_placeRunning) {
        _shuffleTimer?.cancel();
        return;
      }

      final characterIcons = _cleanIconList(widget.characterIcons);
      final eventIcons = _cleanIconList(widget.eventIcons);
      final placeIcons = _cleanIconList(widget.placeIcons);

      setState(() {
        if (_characterRunning && characterIcons.isNotEmpty) {
          _characterDisplayIcon = _randomIcon(characterIcons);
        }

        if (_eventRunning && eventIcons.isNotEmpty) {
          _eventDisplayIcon = _randomIcon(eventIcons);
        }

        if (_placeRunning && placeIcons.isNotEmpty) {
          _placeDisplayIcon = _randomIcon(placeIcons);
        }
      });
    });
  }

  Future<void> _spinAll() async {
    if (_isSpinning || widget.disabled) return;

    final characterIcons = _cleanIconList(widget.characterIcons);
    final eventIcons = _cleanIconList(widget.eventIcons);
    final placeIcons = _cleanIconList(widget.placeIcons);

    if (characterIcons.isEmpty || eventIcons.isEmpty || placeIcons.isEmpty) {
      return;
    }

    final selectedCharacterIcon = _randomIcon(characterIcons);
    final selectedEventIcon = _randomIcon(eventIcons);
    final selectedPlaceIcon = _randomIcon(placeIcons);

    setState(() {
      _isSpinning = true;
      _characterRunning = true;
      _eventRunning = true;
      _placeRunning = true;
    });

    widget.onSpinningChanged(true);
    _startShuffleTimer();

    try {
      widget.onStepSpinStarted('character');

      await Future.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;

      setState(() {
        _characterRunning = false;
        _characterDisplayIcon = selectedCharacterIcon;
      });
      widget.onStepLanded('character', selectedCharacterIcon);

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      widget.onStepSpinStarted('event');

      await Future.delayed(const Duration(milliseconds: 720));
      if (!mounted) return;

      setState(() {
        _eventRunning = false;
        _eventDisplayIcon = selectedEventIcon;
      });
      widget.onStepLanded('event', selectedEventIcon);

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      widget.onStepSpinStarted('place');

      await Future.delayed(const Duration(milliseconds: 720));
      if (!mounted) return;

      setState(() {
        _placeRunning = false;
        _placeDisplayIcon = selectedPlaceIcon;
      });
      widget.onStepLanded('place', selectedPlaceIcon);
    } finally {
      if (!mounted) return;

      _shuffleTimer?.cancel();

      setState(() {
        _isSpinning = false;
        _characterRunning = false;
        _eventRunning = false;
        _placeRunning = false;
      });

      widget.onSpinningChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final characterIcons = _cleanIconList(widget.characterIcons);
    final eventIcons = _cleanIconList(widget.eventIcons);
    final placeIcons = _cleanIconList(widget.placeIcons);

    final hasAllLanded = widget.characterLandedIcon != null &&
        widget.eventLandedIcon != null &&
        widget.placeLandedIcon != null;

    final canSpin = !_isSpinning &&
        !widget.disabled &&
        characterIcons.isNotEmpty &&
        eventIcons.isNotEmpty &&
        placeIcons.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            AppColors.white.withOpacity(0.97),
            const Color(0xFFFFFCF4).withOpacity(0.96),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: const Color(0xFFFFC640).withOpacity(0.34),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.045),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.055),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _ReelsPanel(
            characterIcons: characterIcons,
            eventIcons: eventIcons,
            placeIcons: placeIcons,
            characterIcon: _characterDisplayIcon,
            eventIcon: _eventDisplayIcon,
            placeIcon: _placeDisplayIcon,
            characterRunning: _characterRunning,
            eventRunning: _eventRunning,
            placeRunning: _placeRunning,
            characterLanded:
            widget.characterLandedIcon != null && !_characterRunning,
            eventLanded: widget.eventLandedIcon != null && !_eventRunning,
            placeLanded: widget.placeLandedIcon != null && !_placeRunning,
            leverEnabled: canSpin,
            leverSpinning: _isSpinning,
            onLeverTap: _spinAll,
          ),
          _SlotMachineStatus(
            isSpinning: _isSpinning,
            hasAllLanded: hasAllLanded,
          ),
        ],
      ),
    );
  }
}

class _ReelsPanel extends StatelessWidget {
  final List<String> characterIcons;
  final List<String> eventIcons;
  final List<String> placeIcons;
  final String? characterIcon;
  final String? eventIcon;
  final String? placeIcon;
  final bool characterRunning;
  final bool eventRunning;
  final bool placeRunning;
  final bool characterLanded;
  final bool eventLanded;
  final bool placeLanded;
  final bool leverEnabled;
  final bool leverSpinning;
  final VoidCallback onLeverTap;

  const _ReelsPanel({
    required this.characterIcons,
    required this.eventIcons,
    required this.placeIcons,
    required this.characterIcon,
    required this.eventIcon,
    required this.placeIcon,
    required this.characterRunning,
    required this.eventRunning,
    required this.placeRunning,
    required this.characterLanded,
    required this.eventLanded,
    required this.placeLanded,
    required this.leverEnabled,
    required this.leverSpinning,
    required this.onLeverTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 9, 8, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF8E5).withOpacity(0.98),
            AppColors.white.withOpacity(0.96),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: const Color(0xFFFFC640).withOpacity(0.74),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC640).withOpacity(0.13),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.white.withOpacity(0.42),
                      Colors.transparent,
                      AppColors.primary.withOpacity(0.025),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LeverButton(
                enabled: leverEnabled,
                spinning: leverSpinning,
                onTap: onLeverTap,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SlotReel(
                        label: 'الشخصية',
                        icons: characterIcons,
                        icon: characterIcon,
                        running: characterRunning,
                        landed: characterLanded,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _SlotReel(
                        label: 'الحدث',
                        icons: eventIcons,
                        icon: eventIcon,
                        running: eventRunning,
                        landed: eventLanded,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _SlotReel(
                        label: 'المكان',
                        icons: placeIcons,
                        icon: placeIcon,
                        running: placeRunning,
                        landed: placeLanded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeverButton extends StatelessWidget {
  final bool enabled;
  final bool spinning;
  final VoidCallback onTap;

  const _LeverButton({
    required this.enabled,
    required this.spinning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled || spinning;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 38,
          height: 232,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 28,
                bottom: 28,
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: active
                          ? [
                        AppColors.primary.withOpacity(0.22),
                        AppColors.primary.withOpacity(0.62),
                        AppColors.primary.withOpacity(0.22),
                      ]
                          : [
                        AppColors.border.withOpacity(0.38),
                        AppColors.border.withOpacity(0.56),
                        AppColors.border.withOpacity(0.34),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.85),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: active
                            ? AppColors.primary.withOpacity(0.10)
                            : AppColors.black.withOpacity(0.025),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                top: spinning ? 116 : 34,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: active
                          ? const [
                        Color(0xFFFFF1A8),
                        Color(0xFFFFC640),
                        Color(0xFFFFB23E),
                      ]
                          : [
                        AppColors.white.withOpacity(0.92),
                        AppColors.border.withOpacity(0.72),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.96),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: active
                            ? const Color(0xFFFFC640).withOpacity(0.30)
                            : AppColors.black.withOpacity(0.04),
                        blurRadius: active ? 12 : 7,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.touch_app_rounded,
                      color: active
                          ? AppColors.primary.withOpacity(0.82)
                          : AppColors.textSecondary.withOpacity(0.36),
                      size: 17,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 3,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: active ? 1 : 0.58,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.82),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotReel extends StatelessWidget {
  final String label;
  final List<String> icons;
  final String? icon;
  final bool running;
  final bool landed;

  const _SlotReel({
    required this.label,
    required this.icons,
    required this.icon,
    required this.running,
    required this.landed,
  });

  @override
  Widget build(BuildContext context) {
    final displayIcon = icon == null ? null : _cleanIconName(icon!);

    final topIcon = _iconAtOffset(
      icons: icons,
      currentIcon: displayIcon,
      offset: -1,
    );

    final bottomIcon = _iconAtOffset(
      icons: icons,
      currentIcon: displayIcon,
      offset: 1,
    );

    return SizedBox(
      height: 244,
      child: Column(
        children: [
          _ReelLabel(label: label),
          const SizedBox(height: 7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 174,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withOpacity(0.98),
                  const Color(0xFFFFFAEC).withOpacity(0.98),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: landed
                    ? const Color(0xFFFFC640).withOpacity(0.95)
                    : AppColors.primary.withOpacity(0.055),
                width: landed ? 2.2 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: landed
                      ? const Color(0xFFFFC640).withOpacity(0.16)
                      : AppColors.black.withOpacity(0.038),
                  blurRadius: landed ? 14 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.035),
                            Colors.transparent,
                            Colors.transparent,
                            AppColors.primary.withOpacity(0.03),
                          ],
                          stops: const [0.0, 0.22, 0.78, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: running ? 0.42 : 0.26,
                      child: _MiniReelItem(
                        icon: topIcon,
                        size: 50,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: running ? 0.42 : 0.26,
                      child: _MiniReelItem(
                        icon: bottomIcon,
                        size: 50,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Container(
                            height: 1.2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: AppColors.primary.withOpacity(0.07),
                          ),
                          const Spacer(),
                          Container(
                            height: 1.2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: AppColors.primary.withOpacity(0.07),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.white.withOpacity(0.70),
                              Colors.transparent,
                              Colors.transparent,
                              AppColors.white.withOpacity(0.70),
                            ],
                            stops: const [0.0, 0.24, 0.76, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (landed)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFFFE29A).withOpacity(0.70),
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: running ? 95 : 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, -0.26),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slide,
                          child: child,
                        ),
                      );
                    },
                    child: displayIcon == null
                        ? _EmptySlotIcon(key: ValueKey('$label-empty'))
                        : _MainReelItem(
                      key: ValueKey(
                        '$label-$displayIcon-${running ? 'run' : 'stop'}',
                      ),
                      icon: displayIcon,
                      running: running,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 26,
            child: displayIcon == null
                ? const SizedBox(height: 26)
                : _ReelNameChip(
              icon: displayIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelLabel extends StatelessWidget {
  final String label;

  const _ReelLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.105),
            AppColors.primary.withOpacity(0.045),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: AppColors.white.withOpacity(0.82),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.035),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MiniReelItem extends StatelessWidget {
  final String? icon;
  final double size;

  const _MiniReelItem({
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null || icon!.trim().isEmpty) {
      return SizedBox(height: size);
    }

    return Center(
      child: _IconBubble(
        icon: icon!,
        size: size,
        padding: 6,
        mini: true,
      ),
    );
  }
}

class _MainReelItem extends StatelessWidget {
  final String icon;
  final bool running;

  const _MainReelItem({
    super.key,
    required this.icon,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: running ? 0.94 : 1.0,
      child: _IconBubble(
        icon: icon,
        size: 82,
        padding: 8,
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final String icon;
  final double size;
  final double padding;
  final bool mini;

  const _IconBubble({
    required this.icon,
    required this.size,
    required this.padding,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanIcon = _cleanIconName(icon);
    final displayName = _displayNameForIcon(cleanIcon);
    final fallbackText =
    displayName.trim().isEmpty ? '?' : displayName.trim().characters.first;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: mini
              ? [
            AppColors.white.withOpacity(0.72),
            AppColors.white.withOpacity(0.56),
          ]
              : [
            AppColors.white.withOpacity(0.98),
            const Color(0xFFFFFBF2).withOpacity(0.94),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: AppColors.white.withOpacity(mini ? 0.80 : 0.98),
          width: mini ? 1.1 : 1.7,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(mini ? 0.025 : 0.06),
            blurRadius: mini ? 6 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/cards/$cleanIcon.png',
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Text(
              fallbackText,
              textAlign: TextAlign.center,
              textDirection: _directionForText(fallbackText),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: size < 50 ? 16 : 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptySlotIcon extends StatelessWidget {
  const _EmptySlotIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withOpacity(0.72),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
          width: 1.2,
        ),
      ),
      child: Icon(
        Icons.question_mark_rounded,
        color: AppColors.primary.withOpacity(0.60),
        size: 28,
      ),
    );
  }
}

class _ReelNameChip extends StatelessWidget {
  final String icon;

  const _ReelNameChip({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _displayNameForIcon(icon);

    return Container(
      height: 26,
      constraints: const BoxConstraints(maxWidth: 96),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.025),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        textDirection: _directionForText(displayName),
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 10.8,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SlotMachineStatus extends StatelessWidget {
  final bool isSpinning;
  final bool hasAllLanded;

  const _SlotMachineStatus({
    required this.isSpinning,
    required this.hasAllLanded,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSpinning && !hasAllLanded) {
      return const SizedBox.shrink();
    }

    final text =
    isSpinning ? 'جاري اختيار العناصر...' : 'رائع! اضغط التالي لتسجيل القصة';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSpinning
              ? const Color(0xFFFFF2A3).withOpacity(0.76)
              : AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSpinning
                ? const Color(0xFFFFD24D).withOpacity(0.55)
                : AppColors.primary.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}