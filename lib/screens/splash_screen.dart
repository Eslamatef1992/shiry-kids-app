import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Stage 1 — entry: fade + drop from top + scale up
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  // Stage 2 — pulse loop after entry
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Stage 3 — exit: scale up + fade out
  late AnimationController _exitCtrl;
  late Animation<double> _exitScaleAnim;
  late Animation<double> _exitFadeAnim;

  @override
  void initState() {
    super.initState();

    // ── Entry (700ms) ──────────────────────────────────────────
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );

    // ── Pulse loop (repeating breathe) ────────────────────────
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulseCtrl.reverse();
      else if (s == AnimationStatus.dismissed) _pulseCtrl.forward();
    });

    // ── Exit (400ms) ───────────────────────────────────────────
    _exitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _exitScaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _exitFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    // ── Sequence ───────────────────────────────────────────────
    _entryCtrl.forward().then((_) {
      _pulseCtrl.forward(); // start pulse after entry
      Future.delayed(const Duration(milliseconds: 1400), () async {
        if (!mounted) return;
        _pulseCtrl.stop();
        await _exitCtrl.forward();
        if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
      });
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Blobs ─────────────────────────────────────────────
          Positioned(
            top: -60, left: -60,
            child: _Blob(size: 220, opacity: 0.18),
          ),
          Positioned(
            top: 30, right: -40,
            child: _Blob(size: 160, opacity: 0.12),
          ),
          Positioned(
            bottom: -80, right: -40,
            child: _Blob(size: 200, opacity: 0.10),
          ),
          Positioned(
            bottom: 60, left: -30,
            child: _Blob(size: 120, opacity: 0.08),
          ),

          // ── Logo ──────────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_entryCtrl, _pulseCtrl, _exitCtrl]),
              builder: (_, child) {
                final entryDone = _entryCtrl.isCompleted;
                final exitStarted = _exitCtrl.value > 0;

                double scale = _scaleAnim.value;
                if (entryDone && !exitStarted) scale *= _pulseAnim.value;
                if (exitStarted) scale = _exitScaleAnim.value;

                double opacity = _fadeAnim.value;
                if (exitStarted) opacity = _exitFadeAnim.value;

                return SlideTransition(
                  position: _slideAnim,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/logo_cropped.png',
                width: size.width * 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.primary.withOpacity(opacity),
    ),
  );
}
