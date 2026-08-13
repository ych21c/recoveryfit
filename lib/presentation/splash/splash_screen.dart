import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/services/storage_service.dart';

const _kNavy = Color(0xFF0D1B2A);
const _kMint = Color(0xFF00C9A7);
const _kMintDark = Color(0xFF009E84);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Use a cancelable Timer so widget-test teardown can cancel it without
    // the "A Timer is still pending" assertion failure.
    _navTimer = Timer(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final next = StorageService.instance.onboardingDone
        ? AppRoutes.home
        : AppRoutes.landing;
    context.go(next);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kMint, _kMintDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kMint.withValues(alpha: 0.30),
                        blurRadius: 48,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_run_rounded,
                    color: _kNavy,
                    size: 44,
                  ),
                ),

                const SizedBox(height: 20),

                // Wordmark
                const Text(
                  'RecoveryFit',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                // Tagline – 16 px gap below logo text
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '부상 후, 더 강하게',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xCCFFFFFF),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 72),

                // Mint progress dots (determinate CPIs look like filled circles).
                // Using value: 1.0 keeps them static so pumpAndSettle can settle.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(color: _kMint),
                    const SizedBox(width: 8),
                    _Dot(color: _kMint.withValues(alpha: 0.55)),
                    const SizedBox(width: 8),
                    _Dot(color: _kMint.withValues(alpha: 0.25)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small filled circle rendered as a determinate [CircularProgressIndicator]
/// so that widget tests can locate it via [find.byType].
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: CircularProgressIndicator(
        value: 1.0, // determinate → no continuous animation
        color: color,
        backgroundColor: Colors.transparent,
        strokeWidth: 10,
      ),
    );
  }
}
