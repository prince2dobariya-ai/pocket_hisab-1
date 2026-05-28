import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_hisab/screens/home/home_main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _bgAnimController;
  late AnimationController _contentAnimController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      gradientColors: [
        const Color(0xFF10B981),
        const Color(0xFF059669),
        const Color(0xFF047857),
      ],
      icon: Icons.account_balance_wallet_rounded,
      illustrationWidgets: _WalletIllustration(),
      title: "Track Every Rupee",
      subtitle:
          "Record your salary, daily expenses, and payments — all in one beautifully simple place.",
      badge: "💰 Smart Finance",
    ),
    _OnboardingPage(
      gradientColors: [
        const Color(0xFF3B82F6),
        const Color(0xFF2563EB),
        const Color(0xFF1D4ED8),
      ],
      icon: Icons.credit_card_rounded,
      illustrationWidgets: _EmiIllustration(),
      title: "Never Miss an EMI",
      subtitle:
          "Stay ahead of your loan payments and grow your savings with monthly goals that keep you on track.",
      badge: "📅 Smart Reminders",
    ),
    _OnboardingPage(
      gradientColors: [
        const Color(0xFFF59E0B),
        const Color(0xFFD97706),
        const Color(0xFFB45309),
      ],
      icon: Icons.people_rounded,
      illustrationWidgets: _HisabIllustration(),
      title: "Clear Hisab, Always",
      subtitle:
          "Track money lent or borrowed from friends. Know exactly who owes you and what you owe — zero confusion.",
      badge: "🤝 Fair & Square",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimController, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimController,
            curve: Curves.easeOut,
          ),
        );
    _contentAnimController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _contentAnimController.reset();
    setState(() => _currentPage = index);
    _contentAnimController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Get.off(() => const HomeMain(), transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    return _PageContent(
                      page: p,
                      contentFade: _contentFade,
                      contentSlide: _contentSlide,
                      size: size,
                    );
                  },
                ),
              ),

              // Bottom section: dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? Colors.white
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.gradientColors[1],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? "Get Started 🚀"
                              : "Continue",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final Size size;

  const _PageContent({
    required this.page,
    required this.contentFade,
    required this.contentSlide,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: contentFade,
      child: SlideTransition(
        position: contentSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(45),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withAlpha(70),
                    width: 1,
                  ),
                ),
                child: Text(
                  page.badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Illustration
              SizedBox(
                height: size.height * 0.32,
                child: page.illustrationWidgets,
              ),

              const SizedBox(height: 36),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page data model ──────────────────────────────────────────────────────────

class _OnboardingPage {
  final List<Color> gradientColors;
  final IconData icon;
  final Widget illustrationWidgets;
  final String title;
  final String subtitle;
  final String badge;

  const _OnboardingPage({
    required this.gradientColors,
    required this.icon,
    required this.illustrationWidgets,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
}

// ─── Illustrations ────────────────────────────────────────────────────────────

class _WalletIllustration extends StatefulWidget {
  const _WalletIllustration();

  @override
  State<_WalletIllustration> createState() => _WalletIllustrationState();
}

class _WalletIllustrationState extends State<_WalletIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(30),
            ),
          ),
          // Inner card shape
          Container(
            width: 160,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹ 45,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Floating chip 1
          Positioned(
            top: 30,
            right: 30,
            child: _FloatingChip(
              icon: Icons.trending_up,
              label: '+₹5,000',
              color: Colors.greenAccent,
            ),
          ),
          // Floating chip 2
          Positioned(
            bottom: 30,
            left: 20,
            child: _FloatingChip(
              icon: Icons.shopping_bag,
              label: '-₹1,200',
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmiIllustration extends StatefulWidget {
  const _EmiIllustration();

  @override
  State<_EmiIllustration> createState() => _EmiIllustrationState();
}

class _EmiIllustrationState extends State<_EmiIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _progress = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(25),
              ),
            ),
            // Arc progress
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _ArcPainter(progress: _progress.value),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.credit_card_rounded,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Text(
                  '${(_progress.value * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'EMI Paid',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Positioned(
              bottom: 22,
              right: 22,
              child: _FloatingChip(
                icon: Icons.savings_rounded,
                label: '₹12,000 saved',
                color: Colors.lightGreenAccent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;

  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HisabIllustration extends StatefulWidget {
  const _HisabIllustration();

  @override
  State<_HisabIllustration> createState() => _HisabIllustrationState();
}

class _HisabIllustrationState extends State<_HisabIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(25),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PersonAvatar(label: 'You', color: Colors.white24),
                  const SizedBox(width: 24),
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white70,
                    size: 32,
                  ),
                  const SizedBox(width: 24),
                  _PersonAvatar(label: 'Raj', color: Colors.white24),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white38, width: 1),
                ),
                child: const Text(
                  'You get ₹3,500 👍',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 18,
            child: _FloatingChip(
              icon: Icons.check_circle,
              label: 'Settled',
              color: Colors.greenAccent,
            ),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            child: _FloatingChip(
              icon: Icons.people,
              label: '4 Friends',
              color: Colors.lightBlueAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  final String label;
  final Color color;

  const _PersonAvatar({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(50),
            border: Border.all(color: Colors.white54, width: 1.5),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FloatingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
