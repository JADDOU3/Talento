import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';

class ExplorationsSection extends StatelessWidget {
  const ExplorationsSection({super.key});

  static const double kRowHeight = 420.0;

  /// Backend kit IDs aligned with home marketing cards (catalog uses live IDs).
  static const int _botanistKitId = 1;
  static const int _avianKitId = 2;
  static const int _prismKitId = 3;

  void _openKitDetails(BuildContext context, int kitId) {
    Navigator.pushNamed(context, '/kit-details', arguments: kitId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width >= 768 ? 40 : 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(l10n, mobile: width < 768),
              const SizedBox(height: 32),
              width >= 768
                  ? _buildDesktop(context, l10n)
                  : _buildMobile(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, {required bool mobile}) {
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.explorationsTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(l10n.explorationsSubtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {},
              child: Text(l10n.explorationsViewAll),
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
            Text(l10n.explorationsTitle, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(l10n.explorationsSubtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D4D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {},
          child: Text(l10n.explorationsViewAll),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: kRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _bigCard(context, l10n)),
              const SizedBox(width: 20),
              Expanded(child: _avianCard(context, l10n)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: kRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _prismCard(context, l10n)),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _featured(context, l10n)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _mobileCard(
          context: context,
          kitId: _botanistKitId,
          imagePath: 'assets/images/img5.png',
          tag: 'AGES 6-9',
          tagColor: Colors.green,
          title: l10n.card1Title,
          description: l10n.card1Desc,
          hasButton: true,
          buttonText: l10n.card1Button,
        ),
        const SizedBox(height: 16),
        _mobileCard(
          context: context,
          kitId: _avianKitId,
          imagePath: 'assets/images/img6.png',
          tag: 'AGES 4-6',
          tagColor: const Color(0xFFE91E8C),
          title: l10n.card2Title,
          description: l10n.card2Desc,
        ),
        const SizedBox(height: 16),
        _mobileCard(
          context: context,
          kitId: _prismKitId,
          imagePath: 'assets/images/img7.png',
          tag: 'AGES 8-12',
          tagColor: Colors.blue,
          title: l10n.card3Title,
          description: l10n.card3Desc,
        ),
        const SizedBox(height: 16),
        _featuredMobile(context, l10n),
      ],
    );
  }

  Widget _mobileCard({
    required BuildContext context,
    required int kitId,
    required String imagePath,
    required String tag,
    required Color tagColor,
    required String title,
    required String description,
    bool hasButton = false,
    String? buttonText,
  }) {
    return GestureDetector(
      onTap: () => _openKitDetails(context, kitId),
      child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(imagePath, width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tag(tag, tagColor),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                if (hasButton && buttonText != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: () => _openKitDetails(context, kitId),
                      child: Text(buttonText, style: const TextStyle(fontSize: 15)),
                    ),
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

  Widget _featuredMobile(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openKitDetails(context, _botanistKitId),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Image.asset("assets/images/img8.png", width: double.infinity, height: 380, fit: BoxFit.cover),
          Container(width: double.infinity, height: 380, color: Colors.black.withOpacity(0.45)),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(l10n.featuredBadge, style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 16),
                Text(l10n.featuredTitle, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 12),
                Text(l10n.featuredDesc, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2DC5A2), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () => _openKitDetails(context, _botanistKitId),
                    child: Text(l10n.featuredButton, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _bigCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openKitDetails(context, _botanistKitId),
      child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)), child: Image.asset("assets/images/img5.png", fit: BoxFit.cover, height: double.infinity))),
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
                      _tag("AGES 6-9", Colors.green),
                      const SizedBox(height: 14),
                      Text(l10n.card1Title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(l10n.card1Desc, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                    ],
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () => _openKitDetails(context, _botanistKitId),
                    child: Text(l10n.card1Button, style: const TextStyle(fontSize: 16)),
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

  Widget _avianCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openKitDetails(context, _avianKitId),
      child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Image.asset("assets/images/img6.png", width: double.infinity, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tag("AGES 4-6", const Color(0xFFE91E8C)),
                const SizedBox(height: 8),
                Text(l10n.card2Title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(l10n.card2Desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _prismCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openKitDetails(context, _prismKitId),
      child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Image.asset("assets/images/img7.png", width: double.infinity, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tag("AGES 8-12", Colors.blue),
                const SizedBox(height: 8),
                Text(l10n.card3Title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(l10n.card3Desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _featured(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _openKitDetails(context, _botanistKitId),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/img8.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                  child: Text(l10n.featuredBadge, style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 20),
                Text(l10n.featuredTitle, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 14),
                SizedBox(width: 300, child: Text(l10n.featuredDesc, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5))),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2DC5A2), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: () => _openKitDetails(context, _botanistKitId),
                  child: Text(l10n.featuredButton, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}