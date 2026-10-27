import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../theme/app_colors.dart';
import '../services/api_service.dart';

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
        if (!mounted) return;

        // ── Force-update check ─────────────────────────────────
        final needsUpdate = await _checkForceUpdate();
        if (!mounted) return;
        if (needsUpdate) return; // dialog is showing — stop navigation

        // If the user already has a valid session, skip onboarding/login
        // and go straight to the app so they stay logged in between
        // app launches/backgrounds.
        final loggedIn = await ApiService.isLoggedIn();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/onboarding');
      });
    });
  }

  // Returns true if a force-update dialog was shown (caller should halt navigation).
  Future<bool> _checkForceUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version; // e.g. "1.2.3"

      final res = await ApiService.getAppVersion();
      if (res['success'] != true) return false;
      final data = res['data'] as Map<String, dynamic>;

      final bool forceUpdate = data['force_update'] == true;
      if (!forceUpdate) return false;

      final minVersion = Platform.isIOS
          ? (data['ios_min_version'] as String? ?? '1.0.0')
          : (data['android_min_version'] as String? ?? '1.0.0');
      final storeUrl = Platform.isIOS
          ? (data['ios_store_url'] as String? ?? '')
          : (data['android_store_url'] as String? ?? '');

      if (!_isOutdated(current, minVersion)) return false;

      // Show non-dismissible update dialog
      if (!mounted) return true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.system_update_rounded, color: AppColors.primary, size: 38),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Update Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'A new version of Shiry Kids is available. Please update to continue.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (storeUrl.isNotEmpty) {
                        final uri = Uri.parse(storeUrl);
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('Update Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return true;
    } catch (_) {
      return false; // never block the app on a version-check error
    }
  }

  // Returns true if [current] version is less than [minimum].
  // Compares major.minor.patch numerically.
  bool _isOutdated(String current, String minimum) {
    List<int> parse(String v) =>
        v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final c = parse(current);
    final m = parse(minimum);
    for (int i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final mv = i < m.length ? m[i] : 0;
      if (cv < mv) return true;
      if (cv > mv) return false;
    }
    return false;
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
