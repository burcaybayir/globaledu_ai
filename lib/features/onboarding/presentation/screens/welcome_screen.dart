import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/widgets/premium_button.dart';
import 'package:globaledu_ai/core/widgets/section_header.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _floatCtrl;
  late Animation<double> _float;

  static const _pages = [
    _PageData(
      gradient: AppColors.primaryGradient,
      emoji: '🎓',
      title: 'Find Your\nDream University',
      subtitle: 'AI-powered matching across 10,000+ universities in 50 countries.',
      illustration: _IllustrationType.university,
    ),
    _PageData(
      gradient: AppColors.skyGradient,
      emoji: '🤖',
      title: 'Your Personal\nAI Advisor',
      subtitle: 'Get expert guidance from application strategy to visa approval.',
      illustration: _IllustrationType.ai,
    ),
    _PageData(
      gradient: AppColors.mintGradient,
      emoji: '✈️',
      title: 'From Dream\nto Reality',
      subtitle: 'Track applications, manage documents, ace interviews — all in one.',
      illustration: _IllustrationType.visa,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final data = _pages[_page];

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient background ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(gradient: data.gradient),
            width: size.width,
            height: size.height * 0.55,
          ),

          // ── Bottom surface ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.52,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Skip ──
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 8),
                    child: TextButton(
                      onPressed: () => context.goNamed(RouteNames.login),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Illustration ──
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) {
                      return AnimatedBuilder(
                        animation: _float,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _float.value),
                          child: _OnboardingIllustration(
                            type: _pages[i].illustration,
                            emoji: _pages[i].emoji,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Content ──
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Dot indicators
                        DotIndicator(
                          count: _pages.length,
                          current: _page,
                          activeColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 20),

                        // Title
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Text(
                            data.title,
                            key: ValueKey(_page),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            data.subtitle,
                            key: ValueKey('sub$_page'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // CTA
                        PremiumButton(
                          label: _page == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          onPressed: _next,
                          gradient: data.gradient,
                          icon: _page == _pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Illustration Widget ──────────────────────────────────────────────────────

enum _IllustrationType { university, ai, visa }

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({
    required this.type,
    required this.emoji,
  });

  final _IllustrationType type;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: CustomPaint(
          painter: _IllustrationPainter(type: type),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 72),
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter({required this.type});
  final _IllustrationType type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Glow circle
    canvas.drawCircle(
      center,
      r * 0.85,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );

    // Orbit rings
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        center,
        r * (0.5 + i * 0.18),
        Paint()
          ..color = Colors.white.withOpacity(0.08 - i * 0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Floating dots
    final rng = math.Random(type.index);
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final dist = r * (0.6 + rng.nextDouble() * 0.25);
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist;
      canvas.drawCircle(
        Offset(x, y),
        3 + rng.nextDouble() * 3,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) => old.type != type;
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _PageData {
  const _PageData({
    required this.gradient,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.illustration,
  });

  final Gradient gradient;
  final String emoji;
  final String title;
  final String subtitle;
  final _IllustrationType illustration;
}
