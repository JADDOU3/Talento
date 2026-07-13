// lib/features/blog/pages/blog_post_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../data/blog_posts.dart';
import '../models/blog_post.dart';
import '../utils/blog_style.dart';

class BlogPostPage extends StatefulWidget {
  final String postId;

  const BlogPostPage({super.key, required this.postId});

  @override
  State<BlogPostPage> createState() => _BlogPostPageState();
}

class _BlogPostPageState extends State<BlogPostPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  int get _postIndex {
    final index = blogPosts.indexWhere((p) => p.id == widget.postId);
    return index == -1 ? 0 : index;
  }

  BlogPost get _post => blogPosts[_postIndex];

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 768 ? 40.0 : 20.0;
    final post = _post;
    final accent = blogAccentColorFor(_postIndex);

    return Scaffold(
      backgroundColor: AppColors.cartPageBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _AccentHeader(
                  post: post,
                  isArabic: isArabic,
                  accent: accent,
                  floatAnimation: _floatAnimation,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: accent.withOpacity(0.18),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.14),
                                blurRadius: 26,
                                offset: const Offset(0, 12),
                              ),
                              const BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ArticleTag(isArabic: isArabic, accent: accent),
                              const SizedBox(height: 24),
                              for (int i = 0; i < post.body(isArabic).length; i++) ...[
                                _FunParagraph(
                                  text: post.body(isArabic)[i],
                                  index: i,
                                  accent: accent,
                                ),
                                if (i < post.body(isArabic).length - 1)
                                  const SizedBox(height: 22),
                              ],
                              const SizedBox(height: 12),
                              Container(height: 1, color: const Color(0xFFEEEEEE)),
                              const SizedBox(height: 20),
                              _MoreStoriesCard(
                                currentIndex: _postIndex,
                                isArabic: isArabic,
                                floatAnimation: _floatAnimation,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Footer(scrollController: _scrollController),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Navbar(scrollController: _scrollController),
          ),
        ],
      ),
    );
  }
}

Widget _decorativeCircle(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _AccentHeader extends StatelessWidget {
  final BlogPost post;
  final bool isArabic;
  final Color accent;
  final Animation<double> floatAnimation;

  const _AccentHeader({
    required this.post,
    required this.isArabic,
    required this.accent,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartForestGreen,
            AppColors.cartTeal,
            Color(0xFF3FA796),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: _decorativeCircle(70, const Color(0xFFE07A5F).withOpacity(0.35)),
          ),
          Positioned(
            top: 60,
            right: 60,
            child: _decorativeCircle(24, const Color(0xFFDDA83A).withOpacity(0.55)),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: _decorativeCircle(90, Colors.white.withOpacity(0.14)),
          ),
          Positioned(
            bottom: 30,
            left: 100,
            child: _decorativeCircle(18, const Color(0xFFE07A5F).withOpacity(0.5)),
          ),
          Positioned.fill(
            child: _FloatingDecorations(
              color: accent,
              floatAnimation: floatAnimation,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 110),
                  _BouncyBackButton(isArabic: isArabic),
                  const SizedBox(height: 22),
                  _ArticleBadge(isArabic: isArabic),
                  const SizedBox(height: 18),
                  _FunIconContainer(accent: accent, icon: post.icon),
                  const SizedBox(height: 20),
                  _AnimatedTitle(title: post.title(isArabic)),
                  const SizedBox(height: 14),
                  _FunReadTime(
                    post: post,
                    isArabic: isArabic,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleBadge extends StatelessWidget {
  final bool isArabic;

  const _ArticleBadge({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDDA83A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isArabic ? 'مقال' : 'ARTICLE',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _BouncyBackButton extends StatelessWidget {
  final bool isArabic;

  const _BouncyBackButton({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pushNamed('/blog'),
        icon: Icon(
          isArabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
          size: 16,
          color: Colors.white,
        ),
        label: Text(
          isArabic ? 'العودة إلى المدونة' : 'Back to Blog',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _FunIconContainer extends StatelessWidget {
  final Color accent;
  final IconData icon;

  const _FunIconContainer({required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 360),
      duration: const Duration(seconds: 2),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 3.14159 / 180,
          child: child,
        );
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

class _AnimatedTitle extends StatelessWidget {
  final String title;

  const _AnimatedTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0), // ✅ Clamped
            child: child,
          ),
        );
      },
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1.25,
        ),
      ),
    );
  }
}

class _FunReadTime extends StatelessWidget {
  final BlogPost post;
  final bool isArabic;

  const _FunReadTime({
    required this.post,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 360),
          duration: const Duration(seconds: 10),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 3.14159 / 180,
              child: child,
            );
          },
          child: Icon(
            Icons.schedule_rounded,
            size: 15,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '⏱️ ${blogReadLabel(post, isArabic)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              ['📚', '⭐', '🌈', '🎯', '💡'][index % 5],
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
      ],
    );
  }
}

class _FloatingDecorations extends StatelessWidget {
  final Color color;
  final Animation<double> floatAnimation;

  const _FloatingDecorations({
    required this.color,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _FloatingIcon(
            Icons.star,
            Colors.white.withOpacity(0.15),
            24,
            Offset(size.width * 0.08, 30),
            floatAnimation,
          ),
          _FloatingIcon(
            Icons.favorite,
            Colors.white.withOpacity(0.12),
            20,
            Offset(size.width * 0.92, 50),
            floatAnimation,
            delay: 0.5,
          ),
          _FloatingIcon(
            Icons.circle,
            Colors.white.withOpacity(0.10),
            12,
            Offset(size.width * 0.15, 120),
            floatAnimation,
            delay: 0.3,
          ),
          _FloatingIcon(
            Icons.star_half,
            Colors.white.withOpacity(0.12),
            18,
            Offset(size.width * 0.85, 150),
            floatAnimation,
            delay: 0.7,
          ),
          _FloatingIcon(
            Icons.emoji_emotions,
            Colors.white.withOpacity(0.10),
            22,
            Offset(size.width * 0.05, 200),
            floatAnimation,
            delay: 0.2,
          ),
          _FloatingIcon(
            Icons.auto_awesome,
            Colors.white.withOpacity(0.08),
            28,
            Offset(size.width * 0.95, 220),
            floatAnimation,
            delay: 0.9,
          ),
        ],
      ),
    );
  }
}

// ✅ COMPLETELY REWRITTEN _FloatingIcon with safe opacity
class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Offset position;
  final Animation<double> floatAnimation;
  final double delay;

  const _FloatingIcon(
      this.icon,
      this.color,
      this.size,
      this.position,
      this.floatAnimation, {
        this.delay = 0,
      });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: AnimatedBuilder(
        animation: floatAnimation,
        builder: (context, child) {
          // ✅ Safe calculation with clamp
          double rawValue = (floatAnimation.value + delay) % 1.0;
          double clampedValue = rawValue.clamp(0.0, 1.0);
          double offset = 10 * clampedValue;
          double opacity = (0.3 + 0.7 * (1 - clampedValue)).clamp(0.0, 1.0);

          return Transform.translate(
            offset: Offset(0, -offset),
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

class _ArticleTag extends StatelessWidget {
  final bool isArabic;
  final Color accent;

  const _ArticleTag({required this.isArabic, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          isArabic ? 'مقال' : 'ARTICLE',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: accent,
          ),
        ),
        const SizedBox(width: 8),
        const Text('📖', style: TextStyle(fontSize: 15)),
      ],
    );
  }
}

class _FunParagraph extends StatelessWidget {
  final String text;
  final int index;
  final Color accent;

  const _FunParagraph({
    required this.text,
    required this.index,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 200)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0), // ✅ Clamped
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(
              ['👉', '🌟', '💡', '🎯', '📌', '✨', '🌈', '⭐'][index % 8],
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.5,
                height: 1.85,
                color: AppColors.textPrimary.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreStoriesCard extends StatelessWidget {
  final int currentIndex;
  final bool isArabic;
  final Animation<double> floatAnimation;

  const _MoreStoriesCard({
    required this.currentIndex,
    required this.isArabic,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final nextIndex = (currentIndex + 1) % blogPosts.length;
    final next = blogPosts[nextIndex];
    final accent = blogAccentColorFor(nextIndex);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).pushReplacementNamed('/blog-post', arguments: next.id),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withOpacity(0.18),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: floatAnimation,
              builder: (context, child) {
                // ✅ Safe float value
                floatAnimation.value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, -5 * (floatAnimation.value / 15)),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(next.icon, color: accent, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isArabic ? 'المقال التالي' : 'Next up',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👉', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next.title(isArabic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cartForestGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}