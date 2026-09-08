import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_choice_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int page = 0;

  final data = const [
    (
      icon: Icons.movie_filter_rounded,
      title: 'Discover Your Next Movie',
      text:
          'Explore what is playing and find the perfect movie for your next cinema night.'
    ),
    (
      icon: Icons.event_seat_rounded,
      title: 'Pick Your Perfect Seat',
      text:
          'Choose your preferred seats from an interactive cinema layout in just a few taps.'
    ),
    (
      icon: Icons.confirmation_num_rounded,
      title: 'Book Tickets Easily',
      text:
          'Select a showtime, confirm your seats and get ready for an unforgettable movie night.'
    ),
  ];

  // ============================================================
  // FINISH ONBOARDING
  // ============================================================

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'onboarding_completed',
      true,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthChoiceScreen(),
      ),
    );
  }

  // ============================================================
  // NEXT / GET STARTED
  // ============================================================

  void next() {
    if (page < data.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  // ============================================================
  // SKIP
  // ============================================================

  Future<void> skip() async {
    await _finishOnboarding();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            22,
          ),
          child: Column(
            children: [
              // ==================================================
              // TOP BAR
              // ==================================================

              Row(
                children: [
                  const Text(
                    'CINEMA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // PAGES
              // ==================================================

              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: data.length,
                  onPageChanged: (i) {
                    setState(() {
                      page = i;
                    });
                  },
                  itemBuilder: (_, i) {
                    final item = data[i];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ========================================
                        // FEATURE CARD
                        // ========================================

                        Container(
                          width: 235,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(42),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF79877C),
                                Color(0xFF202522),
                                Color(0xFF0D0F0E),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white12,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.6),
                                blurRadius: 35,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 25,
                                right: 22,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.07),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Icon(
                                item.icon,
                                size: 110,
                                color: const Color(0xFFF3F0D6),
                              ),
                              Positioned(
                                bottom: 23,
                                child: Text(
                                  'SCREEN ${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 3,
                                    color: Colors.white38,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 45),

                        // ========================================
                        // TITLE
                        // ========================================

                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 27,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ========================================
                        // DESCRIPTION
                        // ========================================

                        Text(
                          item.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.55,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ==================================================
              // PAGE INDICATORS
              // ==================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  data.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    width: i == page ? 26 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          i == page ? const Color(0xFFF3F0D6) : Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // CONTINUE / GET STARTED
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F0D6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    page == data.length - 1 ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
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
