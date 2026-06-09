import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0B0B0), // gray scrim background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Allow Shiry Kids To Access This Device\'s Location',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Map circles ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MapCircle(label: 'Precise',       showPin: true),
                      _MapCircle(label: 'Approximation', showPin: false),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Action buttons ────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      _ActionBtn(
                        label: 'While Using The App',
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                      ),
                      const Divider(height: 1, color: Color(0xFFE5E5E5)),
                      _ActionBtn(
                        label: 'Only This Time',
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                      ),
                      const Divider(height: 1, color: Color(0xFFE5E5E5)),
                      _ActionBtn(
                        label: 'Don\'t Allow',
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                        isLast: true,
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

class _MapCircle extends StatelessWidget {
  final String label;
  final bool showPin;
  const _MapCircle({required this.label, required this.showPin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: SizedBox(
            width: 110, height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Map image
                Image.asset(
                  'assets/images/map_preview.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFD4E6B5),
                    child: const Center(child: Icon(Icons.map, color: Colors.grey)),
                  ),
                ),
                // Orange pin for Precise
                if (showPin)
                  const Center(
                    child: Icon(Icons.location_on, color: AppColors.primary, size: 32),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  const _ActionBtn({required this.label, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(24))
            : BorderRadius.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
