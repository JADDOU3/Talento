import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/models/kit_model.dart';
import '../../../cubits/kit/kit_cubit.dart';

class ExplorationsSection extends StatefulWidget {
  const ExplorationsSection({super.key});

  @override
  State<ExplorationsSection> createState() => _ExplorationsSectionState();
}

class _ExplorationsSectionState extends State<ExplorationsSection> {
  static const double kRowHeight = 420.0;

  @override
  void initState() {
    super.initState();
    // Fetch first 3 kits from backend
    context.read<KitCubit>().getAllKits(page: 0, size: 3);
  }

  void _openKitDetails(BuildContext context, int kitId) {
    Navigator.pushNamed(context, '/kit-details', arguments: kitId);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return BlocBuilder<KitCubit, KitState>(
      builder: (context, state) {
        if (state is KitLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is KitError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<KitCubit>().getAllKits(page: 0, size: 3);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is KitLoaded && state.kits.isNotEmpty) {
          final displayKits = state.kits.take(3).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width >= 768 ? 40 : 20,
                  vertical: 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, mobile: width < 768),
                    const SizedBox(height: 32),
                    width >= 768
                        ? _buildDesktop(context, displayKits)
                        : _buildMobile(context, displayKits),
                  ],
                ),
              ),
            ),
          );
        }

        // Empty state
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Text('No exploration kits available'),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, {required bool mobile}) {
    final l10n = AppLocalizations.of(context)!;

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("🧭", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              l10n.explorationsTitle,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            l10n.explorationsSubtitle,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _BounceButton(
              text: l10n.explorationsViewAll,
              onTap: () {
                Navigator.pushNamed(context, '/catalog');
              },
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text("🧭", style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(
                l10n.explorationsTitle,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              l10n.explorationsSubtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        _BounceButton(
          text: l10n.explorationsViewAll,
          onTap: () {
            Navigator.pushNamed(context, '/catalog');
          },
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, List<KitModel> kits) {
    if (kits.isEmpty) {
      return const Center(child: Text('No kits available'));
    }

    return SizedBox(
      height: kRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: _bigCard(context, kits[0])),
          if (kits.length > 1) ...[
            const SizedBox(width: 20),
            Expanded(child: _compactCard(context, kits[1])),
          ],
          if (kits.length > 2) ...[
            const SizedBox(width: 20),
            Expanded(child: _compactCard(context, kits[2])),
          ],
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context, List<KitModel> kits) {
    if (kits.isEmpty) {
      return const Center(child: Text('No kits available'));
    }

    return Column(
      children: [
        for (int i = 0; i < kits.length; i++) ...[
          _BouncyTapCard(
            onTap: () => _openKitDetails(context, kits[i].id),
            child: _mobileCardContent(
              context: context,
              kit: kits[i],
              hasButton: i == 0, // Only first card has the button
            ),
          ),
          if (i < kits.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _mobileCardContent({
    required BuildContext context,
    required KitModel kit,
    bool hasButton = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final tagColor = _getTagColor(kit.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: kit.imageURL.isNotEmpty
                ? Image.network(
              kit.imageURL,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                );
              },
            )
                : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WiggleTag(
                  label: kit.displayAge,
                  color: tagColor,
                ),
                const SizedBox(height: 10),
                Text(
                  kit.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  kit.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasButton) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _OutlineBounceButton(
                      text: l10n.card1Button,
                      color: tagColor,
                      onTap: () => _openKitDetails(context, kit.id),
                    ),
                  ),
                ],
                if (kit.mindset != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.psychology, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '🧠 ${kit.mindset!.name}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigCard(BuildContext context, KitModel kit) {
    final l10n = AppLocalizations.of(context)!;
    final tagColor = _getTagColor(kit.id);

    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, kit.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
                child: kit.imageURL.isNotEmpty
                    ? Image.network(
                  kit.imageURL,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 80),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 80),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WiggleTag(
                          label: kit.displayAge,
                          color: tagColor,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          kit.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          kit.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (kit.isNew) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NEW!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (kit.mindset != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.psychology, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                kit.mindset!.name,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    _OutlineBounceButton(
                      text: l10n.card1Button,
                      color: tagColor,
                      onTap: () => _openKitDetails(context, kit.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactCard(BuildContext context, KitModel kit) {
    final tagColor = _getTagColor(kit.id);

    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, kit.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: kit.imageURL.isNotEmpty
                  ? Image.network(
                kit.imageURL,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _WiggleTag(
                        label: kit.displayAge,
                        color: tagColor,
                      ),
                      if (kit.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kit.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kit.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (kit.rating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          kit.ratingDisplay,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${kit.rating.toStringAsFixed(1)})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (kit.mindset != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.psychology, size: 12, color: Colors.blue),
                        const SizedBox(width: 2),
                        Text(
                          kit.mindset!.name,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to assign colors based on kit ID
  Color _getTagColor(int kitId) {
    const colors = [
      Colors.green,
      Color(0xFFE91E8C),
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[kitId % colors.length];
  }
}

// ... Rest of your widget classes (_BouncyTapCard, _WiggleTag, _BounceButton, _OutlineBounceButton)
// remain exactly the same as in your original code ...

/// 🎈 Card that lifts and bounces when tapped or hovered — feels alive.
class _BouncyTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BouncyTapCard({required this.child, required this.onTap});

  @override
  State<_BouncyTapCard> createState() => _BouncyTapCardState();
}

class _BouncyTapCardState extends State<_BouncyTapCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.96 : (_hovered ? 1.03 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovered ? 0.12 : 0.06),
                  blurRadius: _hovered ? 24 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 🏷️ Tag that gives a tiny wiggle on hover
class _WiggleTag extends StatefulWidget {
  final String label;
  final Color color;
  const _WiggleTag({required this.label, required this.color});

  @override
  State<_WiggleTag> createState() => _WiggleTagState();
}

class _WiggleTagState extends State<_WiggleTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedRotation(
        turns: _hovered ? 0.02 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: widget.color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(widget.label, style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

/// 🔘 Solid bounce button (View All, etc.)
class _BounceButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _BounceButton({required this.text, required this.onTap});

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4D4D),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFFFF4D4D).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// 🔘 Outline bounce button used inside cards
class _OutlineBounceButton extends StatefulWidget {
  final String text;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _OutlineBounceButton({required this.text, required this.color, required this.onTap, this.filled = false});

  @override
  State<_OutlineBounceButton> createState() => _OutlineBounceButtonState();
}

class _OutlineBounceButtonState extends State<_OutlineBounceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: widget.filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: widget.filled ? null : Border.all(color: widget.color, width: 1.5),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.color, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}