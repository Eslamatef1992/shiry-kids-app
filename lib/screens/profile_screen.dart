import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.white,
                          child: const Text('🧒', style: TextStyle(fontSize: 36)),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                            child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Eslam Atef', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('eslam@teknulugy.com', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick stats
                  Row(
                    children: [
                      _StatCard(label: 'Orders', value: '12', icon: Icons.shopping_bag_outlined),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Wishlist', value: '5', icon: Icons.favorite_outline),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Coupons', value: '3', icon: Icons.confirmation_number_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Account section
                  _SectionCard(
                    title: 'Account',
                    items: [
                      _MenuItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () {}),
                      _MenuItem(icon: Icons.location_on_outlined, label: 'My Addresses', onTap: () {}),
                      _MenuItem(icon: Icons.lock_outline, label: 'Change Password', onTap: () {}),
                      _MenuItem(icon: Icons.language, label: 'Change Language', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // App info section
                  _SectionCard(
                    title: 'App Information',
                    items: [
                      _MenuItem(icon: Icons.info_outline, label: 'About Us', onTap: () {}),
                      _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
                      _MenuItem(icon: Icons.description_outlined, label: 'Terms & Conditions', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Contact section
                  _SectionCard(
                    title: 'Company Contact',
                    items: [
                      _MenuItem(icon: Icons.phone_outlined, label: '+96761223323', onTap: () {}),
                      _MenuItem(icon: Icons.email_outlined, label: 'Shirykids@Gmail.Com', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Social row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialIcon(icon: Icons.facebook, color: const Color(0xFF1877F2), onTap: () {}),
                        _SocialIcon(icon: Icons.camera_alt_outlined, color: const Color(0xFFE1306C), onTap: () {}),
                        _SocialIcon(icon: Icons.alternate_email, color: const Color(0xFF1DA1F2), onTap: () {}),
                        _SocialIcon(icon: Icons.message_outlined, color: const Color(0xFF25D366), onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: AppColors.primary),
                      label: const Text('Logout', style: TextStyle(color: AppColors.primary)),
                      onPressed: () => _showLogoutDialog(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: const Text('Are You Sure You Want Logout?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: const Text('No', style: TextStyle(color: AppColors.textDark)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Yes'),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark)),
            Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMedium, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.primary, size: 22),
                    title: Text(item.label, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
                    onTap: item.onTap,
                    dense: true,
                  ),
                  if (i < items.length - 1) const Divider(height: 1, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
