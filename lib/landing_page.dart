import 'package:flutter/material.dart';
import 'auth_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    // Slide 1 - Secure Health Records
    OnboardingData(
      icon: Icons.shield_outlined,
      secondaryIcon: Icons.medical_information_outlined,
      title: 'Secure Health Records',
      description:
      'Store all your medical reports, prescriptions, and health documents safely in one cloud-based vault — accessible only by you.',
      bulletPoints: [],
    ),
    // Slide 2 - Emergency Medical Information
    OnboardingData(
      icon: Icons.emergency_outlined,
      secondaryIcon: Icons.favorite_outline,
      title: 'Emergency Medical\nInformation',
      description:
      'Critical health info available instantly when it matters most. Your allergies, chronic conditions, and medications are always one tap away.',
      bulletPoints: [],
    ),
    // Slide 3 - Smart Organization
    OnboardingData(
      icon: Icons.folder_special_outlined,
      secondaryIcon: Icons.timeline_outlined,
      title: 'Smart Organization\nof Records',
      description: 'Your records organized the way you need them:',
      bulletPoints: [
        ' • Department-wise folders categorization',
        ' • Year-wise timeline view',
        '',
        '',
        'Track your health journey',
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _OnboardingCard(data: _pages[index]);
              },
            ),
          ),
          _BottomControls(
            currentPage: _currentPage,
            totalPages: _pages.length,
            onNext: _nextPage,
            isLast: _currentPage == _pages.length - 1,
          ),
        ],
      ),
    );
  }
}

// ─── Single Onboarding Slide ───────────────────────────────────────────────────

class _OnboardingCard extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF1E88E5),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Circular illustration
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative dots
                    Positioned(
                      top: 30,
                      right: 30,
                      child: _Dot(size: 8),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 28,
                      child: _Dot(size: 6),
                    ),
                    Positioned(
                      top: 50,
                      left: 40,
                      child: _Dot(size: 5),
                    ),
                    // Secondary icon
                    Positioned(
                      top: 42,
                      right: 42,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data.secondaryIcon,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ),
                    // Main icon
                    Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data.icon,
                        color: const Color(0xFF1565C0),
                        size: 56,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 44),
              // Title
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              // Description
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // Bullet points (for slide 3)
              if (data.bulletPoints.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: data.bulletPoints.asMap().entries.map((entry) {
                    final isTagline =
                        entry.key == data.bulletPoints.length - 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTagline ? 19 : 16,
                          height: 1.5,
                          fontWeight: isTagline
                              ? FontWeight.w300
                              : FontWeight.w500,
                          fontStyle: isTagline
                              ? FontStyle.italic
                              : FontStyle.normal,
                          letterSpacing: isTagline ? 1.5 : 0.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final bool isLast;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E88E5),
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page indicators
          Row(
            children: List.generate(
              totalPages,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                width: currentPage == index ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          // Next / Get Started button
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1565C0),
              padding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLast ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLast
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward_rounded,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final double size;
  const _Dot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Data Model ────────────────────────────────────────────────────────────────

class OnboardingData {
  final IconData icon;
  final IconData secondaryIcon;
  final String title;
  final String description;
  final List<String> bulletPoints;

  OnboardingData({
    required this.icon,
    required this.secondaryIcon,
    required this.title,
    required this.description,
    required this.bulletPoints,
  });
}