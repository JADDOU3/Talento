import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../data/blog_posts.dart';
import '../models/blog_post.dart';
import '../utils/blog_style.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> with SingleTickerProviderStateMixin {
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
    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 768 ? 40.0 : 20.0;
    final columns = width >= 980 ? 3 : (width >= 640 ? 2 : 1);

    final featured = blogPosts.first;
    final rest = blogPosts.skip(1).toList();

    return Scaffold(
      backgroundColor: AppColors.cartPageBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const _Hero(),
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _FeaturedCard(
                              post: featured,
                              isArabic: isArabic,
                              index: 0,
                              floatAnimation: _floatAnimation,
                            ),
                            const SizedBox(height: 36),
                            _SectionHeader(isArabic: isArabic),
                            const SizedBox(height: 18),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rest.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: columns == 3 ? 0.92 : (columns == 2 ? 1.15 : 1.7),
                              ),
                              itemBuilder: (context, index) {
                                return _BlogCard(
                                  post: rest[index],
                                  isArabic: isArabic,
                                  index: index + 1,
                                  floatAnimation: _floatAnimation,
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _KeepExploringSection(isArabic: isArabic),
                          ],
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

class _SectionHeader extends StatelessWidget {
  final bool isArabic;

  const _SectionHeader({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.cartTeal, Color(0xFFDDA83A)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          isArabic ? 'المزيد من المقالات' : 'More from the blog',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.cartForestGreen,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '📚',
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}

class _KeepExploringSection extends StatelessWidget {
  final bool isArabic;

  const _KeepExploringSection({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartForestGreen.withValues(alpha: 0.08),
            AppColors.cartTeal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cartTeal.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isArabic ? 'استمر في الاستكشاف' : 'Keep exploring',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cartForestGreen,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '🚀',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.explore_rounded,
            color: AppColors.cartTeal,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 100),
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
            child: _decorativeCircle(70, const Color(0xFFE07A5F).withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 60,
            right: 60,
            child: _decorativeCircle(24, const Color(0xFFDDA83A).withValues(alpha: 0.55)),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: _decorativeCircle(90, Colors.white.withValues(alpha: 0.14)),
          ),
          Positioned(
            bottom: 30,
            left: 100,
            child: _decorativeCircle(18, const Color(0xFFE07A5F).withValues(alpha: 0.5)),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDA83A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isArabic ? 'مدونة تالينتو' : 'TALENTO BLOG',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isArabic
                        ? 'قصص ورؤى حول اكتشاف مواهب الأطفال'
                        : "Stories on discovering every child's talent",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic
                        ? 'نشارككم رحلتنا في بناء تالينتو، والأفكار التي تقف خلف كل نشاط وتقرير.'
                        : "Sharing our journey building Talento, and the thinking "
                        "behind every activity and report.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final BlogPost post;
  final bool isArabic;
  final int index;
  final Animation<double> floatAnimation;

  const _FeaturedCard({
    Key? key,
    required this.post,
    required this.isArabic,
    required this.index,
    required this.floatAnimation,
  }) : super(key: key);

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = blogAccentColorFor(widget.index);
    final width = MediaQuery.sizeOf(context).width;
    final sideBySide = width >= 760;

    return MouseRegion(
      key: ValueKey('featured_card_${widget.post.id}'),
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .pushNamed('/blog-post', arguments: widget.post.id),
        child: AnimatedBuilder(
          animation: widget.floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -3 * widget.floatAnimation.value),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accent.withValues(alpha: _hovered ? 0.5 : 0.25),
                width: _hovered ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: _hovered ? 0.25 : 0.12),
                  blurRadius: _hovered ? 30 : 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsetsDirectional.all(32),
            child: Flex(
              direction: sideBySide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: sideBySide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: sideBySide ? 96 : 72,
                    height: sideBySide ? 96 : 72,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      widget.post.icon,
                      color: accent,
                      size: sideBySide ? 44 : 32,
                    ),
                  ),
                ),
                SizedBox(width: sideBySide ? 28 : 0, height: sideBySide ? 0 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isArabic ? 'مقال مميز' : 'FEATURED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('⭐', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.post.title(widget.isArabic),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cartForestGreen,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.post.excerpt(widget.isArabic),
                        style: TextStyle(
                          fontSize: 14.5,
                          color: AppColors.cartMutedGrey.withValues(alpha: 0.9),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  widget.isArabic ? 'اقرأ المقال' : 'Read the story',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  widget.isArabic
                                      ? Icons.arrow_back_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: accent,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: AppColors.cartMutedGrey.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                blogReadLabel(widget.post, widget.isArabic),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.cartMutedGrey.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('⏱️', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlogCard extends StatefulWidget {
  final BlogPost post;
  final bool isArabic;
  final int index;
  final Animation<double> floatAnimation;

  const _BlogCard({
    Key? key,
    required this.post,
    required this.isArabic,
    required this.index,
    required this.floatAnimation,
  }) : super(key: key);

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _rotationAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = blogAccentColorFor(widget.index);

    return MouseRegion(
      key: ValueKey('blog_card_${widget.index}_${widget.post.id}'),
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .pushNamed('/blog-post', arguments: widget.post.id),
        child: AnimatedBuilder(
          animation: widget.floatAnimation,
          builder: (context, child) {
            final floatOffset = 3 * widget.floatAnimation.value * (widget.index % 2 == 0 ? 1 : 0.7);
            return Transform.translate(
              offset: Offset(0, -floatOffset),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
            padding: const EdgeInsetsDirectional.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border(
                top: BorderSide(
                  color: accent,
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: _hovered ? 0.2 : 0.1),
                  blurRadius: _hovered ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 3.14159 / 180,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.post.icon,
                          color: accent,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.post.title(widget.isArabic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cartForestGreen,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ['•', '✦', '◆', '▪', '▸'][widget.index % 5],
                          style: TextStyle(
                            color: accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.post.excerpt(widget.isArabic),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.cartMutedGrey.withValues(alpha: 0.9),
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.isArabic ? 'اقرأ المزيد' : 'Read more',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '→',
                              style: TextStyle(
                                fontSize: 14,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            blogReadLabel(widget.post, widget.isArabic),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.cartMutedGrey.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ['📚', '⭐', '✨'][widget.index % 3],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}