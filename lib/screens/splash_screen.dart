import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // Compare semver strings: returns true if current < minimum
  bool _needsUpdate(String current, String minimum) {
    final c = current.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final m = minimum.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final mv = i < m.length ? m[i] : 0;
      if (cv < mv) return true;
      if (cv > mv) return false;
    }
    return false;
  }

  Future<void> _checkVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version; // e.g. "1.0.0"

      final res = await http
          .get(Uri.parse('https://back.sherykids.com/api/v1/app/version'))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200 || !mounted) {
        _goNext();
        return;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final isAndroid = Platform.isAndroid;
      final minVersion = isAndroid
          ? (data['android_min_version'] ?? '1.0.0') as String
          : (data['ios_min_version'] ?? '1.0.0') as String;
      final storeUrl = isAndroid
          ? (data['android_store_url'] ?? '') as String
          : (data['ios_store_url'] ?? '') as String;
      final forceUpdate = data['force_update'] == true;

      if (forceUpdate && _needsUpdate(currentVersion, minVersion)) {
        if (!mounted) return;
        // Show blocking update dialog — cannot dismiss
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Update Required',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: const Text(
                'A new version of Shiry Kids is available. Please update to continue.',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (storeUrl.isNotEmpty) {
                      await launchUrl(Uri.parse(storeUrl),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Update Now',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
        return; // Don't navigate — block here
      }
    } catch (_) {
      // Network error — allow through
    }
    _goNext();
  }

  void _goNext() {
    if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim  = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), _checkVersion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo placeholder — replace with Image.asset('assets/images/logo.png')
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      '🧒',
                      style: TextStyle(fontSize: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Shiry Kids',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fun for every kid!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
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
