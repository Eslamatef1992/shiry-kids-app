import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import 'profile/my_addresses_screen.dart';
import 'profile/change_password_screen.dart';
import 'profile/app_info_screen.dart';
import 'my_orders_screen.dart';
import 'my_coupons_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic> _settings = {};
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSettings();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await ApiService.isLoggedIn();
    if (mounted) setState(() => _loggedIn = loggedIn);
  }

  Future<void> _loadUser() async {
    try {
      final res = await ApiService.getUser();
      if (mounted && res != null) {
        setState(() => _user = res);
      }
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    try {
      final res = await ApiService.getSettings();
      if (mounted && res['success'] == true && res['data'] != null) {
        setState(() => _settings = Map<String, dynamic>.from(res['data']));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?['name']?.toString() ?? '';
    final email = _user?['email']?.toString() ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile', showBack: false),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const SizedBox(height: 16),

          // ── Avatar ───────────────────────────────────────────
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.divider,
                  child: Icon(Icons.person, size: 56, color: Colors.grey[500]),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(
              _loggedIn ? (name.isNotEmpty ? name : 'My Profile') : 'Guest',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          const SizedBox(height: 4),
          Center(child: Text(
              _loggedIn ? email : 'Log in to access your account',
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium))),
          const SizedBox(height: 24),

          // ── Activity ─────────────────────────────────────────
          _Label('Activity'),
          _Card(children: [
            _SvgRow(asset: 'assets/icons/icon_orders.svg',   label: 'Orders',    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()))),
            _Divider(),
            _SvgRow(asset: 'assets/icons/icon_location.svg', label: 'Addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAddressesScreen()))),
            _Divider(),
            _SvgRow(asset: 'assets/icons/icon_coupons.svg',  label: 'Coupons',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCouponsScreen()))),
          ]),
          const SizedBox(height: 16),

          // ── Settings ─────────────────────────────────────────
          _Label('Settings'),
          _Card(children: [
            _SvgRow(asset: 'assets/icons/icon_change_password.svg', label: 'Change Password', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            _Divider(),
            _SvgRow(
              asset: 'assets/icons/icon_language.svg',
              label: 'Change Language',
              trailing: const Text('AR', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              onTap: () => _showLanguagePicker(context),
            ),
          ]),
          const SizedBox(height: 16),

          // ── App Information (text only) ───────────────────────
          _Label('App Information'),
          _Card(children: [
            _TextRow(label: 'About Us',            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppInfoScreen(title: 'About Us', slug: 'about-us')))),
            _Divider(),
            _TextRow(label: 'Privacy Policy',      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppInfoScreen(title: 'Privacy Policy', slug: 'privacy-policy')))),
            _Divider(),
            _TextRow(label: 'Terms & Conditions',  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppInfoScreen(title: 'Terms & Conditions', slug: 'terms-conditions')))),
          ]),
          const SizedBox(height: 16),

          // ── Company Contact ───────────────────────────────────
          _Label('Company Contact Us'),
          _Card(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Builder(builder: (context) {
                    final phone = (_settings['contact_phone']?.toString().trim().isNotEmpty == true)
                        ? _settings['contact_phone'].toString()
                        : '+9876122323';
                    final email = (_settings['contact_email']?.toString().trim().isNotEmpty == true)
                        ? _settings['contact_email'].toString()
                        : 'Shirykids@Gmail.Com';
                    return Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        const Icon(Icons.phone, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('|', style: TextStyle(color: AppColors.divider)),
                        ),
                        const Icon(Icons.email, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  // Social links — managed by the super admin in the
                  // dashboard (Settings > Social). Only platforms with a
                  // configured link are shown, and tapping opens the link.
                  Builder(builder: (context) {
                    const order = ['twitter', 'instagram', 'linkedin', 'snapchat', 'whatsapp'];
                    final children = <Widget>[];
                    for (final key in order) {
                      final url = _settings[key]?.toString().trim() ?? '';
                      if (url.isEmpty) continue;
                      if (children.isNotEmpty) children.add(_pipe());
                      children.add(_socialIcon(key, () => _openSocialLink(url, key)));
                    }
                    if (children.isEmpty) return const SizedBox.shrink();
                    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
                  }),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Logout / Login ────────────────────────────────────
          _Card(children: [
            _loggedIn
                ? _TextRow(label: 'Logout', onTap: () => _showLogoutDialog(context))
                : _TextRow(label: 'Log In', onTap: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _pipe() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Text('|', style: TextStyle(color: AppColors.divider, fontSize: 18)),
  );

  // Social icons — uses the existing Figma SVGs where available, and a
  // simple branded badge for platforms without a bundled asset.
  Widget _socialIcon(String platform, VoidCallback onTap) {
    Widget icon;
    switch (platform) {
      case 'instagram':
        icon = SvgPicture.asset('assets/icons/social_instagram.svg', width: 38, height: 38);
        break;
      case 'whatsapp':
        icon = SvgPicture.asset('assets/icons/social_whatsapp.svg', width: 38, height: 38);
        break;
      case 'snapchat':
        icon = SvgPicture.asset('assets/icons/social_snapchat.svg', width: 38, height: 38);
        break;
      case 'twitter':
        icon = Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('X', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        );
        break;
      case 'linkedin':
        icon = Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(color: Color(0xFF0A66C2), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        );
        break;
      default:
        icon = const SizedBox(width: 38, height: 38);
    }
    return GestureDetector(onTap: onTap, child: icon);
  }

  // Opens a social link configured by the admin. If the admin entered a
  // bare username/number rather than a full URL, build a sensible link for
  // that platform.
  Future<void> _openSocialLink(String value, String platform) async {
    var link = value;
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      switch (platform) {
        case 'whatsapp':
          link = 'https://wa.me/${link.replaceAll(RegExp(r'[^0-9]'), '')}';
          break;
        case 'twitter':
          link = 'https://twitter.com/${link.replaceAll('@', '')}';
          break;
        case 'instagram':
          link = 'https://instagram.com/${link.replaceAll('@', '')}';
          break;
        case 'linkedin':
          link = 'https://linkedin.com/in/$link';
          break;
        case 'snapchat':
          link = 'https://snapchat.com/add/${link.replaceAll('@', '')}';
          break;
        default:
          link = 'https://$link';
      }
    }
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _LanguagePicker(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are You Sure You\nWant Logout?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.3),
              ),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEEEEE),
                        foregroundColor: const Color(0xFF888888),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Yes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
  );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 52, color: Color(0xFFF0F0F0));
}

/// Row with real SVG icon from Figma
class _SvgRow extends StatelessWidget {
  final String asset;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _SvgRow({required this.asset, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: SvgPicture.asset(asset, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
      ),
      title: Text(label, style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
      dense: true,
      onTap: onTap,
    );
  }
}

/// Text-only row (App Information + Logout)
class _TextRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TextRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
    dense: true,
    onTap: onTap,
  );
}

// ─── Language picker ──────────────────────────────────────────────────────────
class _LanguagePicker extends StatefulWidget {
  const _LanguagePicker();
  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
  String _selected = 'en';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(flag: 'assets/icons/flag_kuwait.svg', label: 'Arabic',  value: 'ar', selected: _selected, onTap: (v) => setState(() => _selected = v)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _LangOption(flag: 'assets/icons/flag_us.svg',     label: 'English', value: 'en', selected: _selected, onTap: (v) => setState(() => _selected = v)),
          const Divider(height: 1),
          // Cancel — plain text button matching Figma
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: Text('Cancel',
                    style: TextStyle(fontSize: 15, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag, label, value, selected;
  final ValueChanged<String> onTap;
  const _LangOption({required this.flag, required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onTap(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Circular flag
            SvgPicture.asset(flag, width: 36, height: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              )),
            ),
            // Radio button — gray when unselected, orange bullseye when selected
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : const Color(0xFFCCCCCC),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFBB2800), // darker orange inner dot
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
