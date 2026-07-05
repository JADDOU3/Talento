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
          // Main content with no top padding
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
                        offset: const Offset(0, -28),
                        child: Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(32, 36, 32, 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ReadingProgressIndicator(accent: accent),
                              const SizedBox(height: 20),
                              for (int i = 0; i < post.body(isArabic).length; i++) ...[
                                _FunParagraph(
                                  text: post.body(isArabic)[i],
                                  index: i,
                                ),
                                if (i < post.body(isArabic).length - 1)
                                  const SizedBox(height: 22),
                              ],
                              const SizedBox(height: 4),
                              Container(height: 1, color: const Color(0xFFEEEEEE)),
                              const SizedBox(height: 20),
                              _MoreStoriesRow(
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
          // Floating Navbar
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80), // Removed top padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, Color.lerp(accent, Colors.black, 0.15)!],
        ),
      ),
      child: Stack(
        children: [
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
                  // Add top padding to push content below navbar
                  const SizedBox(height: 110), // Push content below navbar
                  _BouncyBackButton(isArabic: isArabic),
                  const SizedBox(height: 20),
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
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
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
            opacity: value,
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
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '⏱️ ${blogReadLabel(post, isArabic)}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
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
            Colors.white.withValues(alpha: 0.15),
            24,
            Offset(size.width * 0.08, 30),
            floatAnimation,
          ),
          _FloatingIcon(
            Icons.favorite,
            Colors.white.withValues(alpha: 0.12),
            20,
            Offset(size.width * 0.92, 50),
            floatAnimation,
            delay: 0.5,
          ),
          _FloatingIcon(
            Icons.circle,
            Colors.white.withValues(alpha: 0.10),
            12,
            Offset(size.width * 0.15, 120),
            floatAnimation,
            delay: 0.3,
          ),
          _FloatingIcon(
            Icons.star_half,
            Colors.white.withValues(alpha: 0.12),
            18,
            Offset(size.width * 0.85, 150),
            floatAnimation,
            delay: 0.7,
          ),
          _FloatingIcon(
            Icons.emoji_emotions,
            Colors.white.withValues(alpha: 0.10),
            22,
            Offset(size.width * 0.05, 200),
            floatAnimation,
            delay: 0.2,
          ),
          _FloatingIcon(
            Icons.auto_awesome,
            Colors.white.withValues(alpha: 0.08),
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
          final delayedValue = (floatAnimation.value + delay) % 1.0;
          final offset = 10 * delayedValue;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: Opacity(
              opacity: 0.3 + 0.7 * (1 - delayedValue.abs()),
              child: child,
            ),
          );
        },
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

class _ReadingProgressIndicator extends StatefulWidget {
  final Color accent;

  const _ReadingProgressIndicator({required this.accent});

  @override
  State<_ReadingProgressIndicator> createState() => _ReadingProgressIndicatorState();
}

class _ReadingProgressIndicatorState extends State<_ReadingProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Row(
          children: [
            const Text('📖', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.grey.shade200,
                  color: widget.accent,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(_progressAnimation.value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.accent,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _getProgressEmoji(_progressAnimation.value),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  String _getProgressEmoji(double progress) {
    if (progress < 0.25) return '🚀';
    if (progress < 0.50) return '⭐';
    if (progress < 0.75) return '🌟';
    if (progress < 0.95) return '🎉';
    return '🏆';
  }
}

class _FunParagraph extends StatelessWidget {
  final String text;
  final int index;

  const _FunParagraph({
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 200)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
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
                color: AppColors.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreStoriesRow extends StatelessWidget {
  final int currentIndex;
  final bool isArabic;
  final Animation<double> floatAnimation;

  const _MoreStoriesRow({
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
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).pushReplacementNamed('/blog-post', arguments: next.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -5 * floatAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(next.icon, color: accent, size: 18),
              ),
            ),
            const SizedBox(width: 12),
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.cartMutedGrey.withValues(alpha: 0.7),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👉', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Text(
                    next.title(isArabic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cartForestGreen,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(5 * floatAnimation.value, 0),
                  child: child,
                );
              },
              child: Icon(
                isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                size: 18,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}