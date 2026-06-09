import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Red AppBar with scalloped/wavy bottom edge — used across all profile screens
class WavyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const WavyAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WavyClipper(),
      child: Container(
        height: 80 + MediaQuery.of(context).padding.top,
        color: AppColors.primary,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                if (!showBack) const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 16);

    double x = 0;
    const waveWidth = 20.0;
    const waveHeight = 12.0;
    bool up = false;

    while (x < size.width) {
      x += waveWidth;
      path.quadraticBezierTo(
        x - waveWidth / 2,
        up ? size.height - 16 - waveHeight : size.height - 16 + waveHeight,
        x,
        size.height - 16,
      );
      up = !up;
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WavyClipper old) => false;
}

/// Breadcrumb widget used under the AppBar
class ProfileBreadcrumb extends StatelessWidget {
  final String section;
  const ProfileBreadcrumb({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'My Profile',
              style: TextStyle(color: AppColors.textMedium, fontSize: 13),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right, size: 16, color: AppColors.textMedium),
          ),
          Text(
            section,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
