import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import 'location_picker_screen.dart';

class GuestCheckoutScreen extends StatefulWidget {
  final void Function(Map<String, String?> data)? onSaved;
  const GuestCheckoutScreen({super.key, this.onSaved});
  @override
  State<GuestCheckoutScreen> createState() => _GuestCheckoutScreenState();
}

class _GuestCheckoutScreenState extends State<GuestCheckoutScreen> {
  final _nameFocus  = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  String _name  = '';
  String _email = '';
  String _phone = '';
  String? _locationCity;
  String? _locationDetail;

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _locationCity   = 'Selected Location';
        _locationDetail = result['detail'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: WavyAppBar(title: 'Continue As A Guest', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            const Text(
              'Enjoy The Best Shopping Experience\nThrough The App.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
            ),
            const SizedBox(height: 28),

            // ── Full Name ─────────────────────────────────────────
            const Text('Full Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              focusNode: _nameFocus,
              onChanged: (v) => _name = v,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter Full Name',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            // ── Email ─────────────────────────────────────────────
            const Text('Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              focusNode: _emailFocus,
              onChanged: (v) => _email = v,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter Email',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            // ── Phone ─────────────────────────────────────────────
            const Text('Phone Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.48,
                        child: SvgPicture.asset(
                          'assets/icons/phone_prefix_kw.svg',
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('+965',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                  ]),
                ),
                Container(width: 1, height: 24, color: const Color(0xFFDDDDDD)),
                Expanded(
                  child: TextField(
                    focusNode: _phoneFocus,
                    onChanged: (v) => _phone = v,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    decoration: const InputDecoration(
                      hintText: 'Enter Phone Number',
                      hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Location ──────────────────────────────────────────
            if (_locationCity == null)
              GestureDetector(
                onTap: _openLocationPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.primary),
                          child: const Icon(Icons.add, size: 8, color: Colors.white),
                        ),
                      ),
                    ]),
                    const SizedBox(width: 8),
                    const Text('Set Your Location',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ]),
                ),
              )
            else
              GestureDetector(
                onTap: _openLocationPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_locationCity!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        Text(_locationDetail ?? '',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMedium, size: 20),
                  ]),
                ),
              ),

            const SizedBox(height: 40),

            // ── Save ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_name.trim().isEmpty || _phone.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your name and phone number'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (_locationDetail == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please set your delivery location'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (widget.onSaved != null) {
                    widget.onSaved!({
                      'name': _name.trim(),
                      'email': _email.trim().isNotEmpty ? _email.trim() : null,
                      'phone': '+965${_phone.trim()}',
                      'address': _locationDetail,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEDED),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
