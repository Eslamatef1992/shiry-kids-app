import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';
import '../l10n/app_strings.dart';
import 'location_picker_screen.dart';

class GuestCheckoutScreen extends StatefulWidget {
  final void Function(Map<String, String?> data)? onSaved;
  final bool hasProducts;
  const GuestCheckoutScreen({super.key, this.onSaved, this.hasProducts = false});
  @override
  State<GuestCheckoutScreen> createState() => _GuestCheckoutScreenState();
}

class _GuestCheckoutScreenState extends State<GuestCheckoutScreen> {
  final _nameFocus  = FocusNode();
  final _phoneFocus = FocusNode();
  String _name  = '';
  String _phone = '';
  String? _phoneError;
  String? _locationCity;
  String? _locationDetail;

  bool _isPhoneValid(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '').length == 8;

  @override
  void dispose() {
    _nameFocus.dispose();
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
            Text(
              'Enjoy The Best Shopping Experience\nThrough The App.'.tr(context),
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
            ),
            const SizedBox(height: 28),

            // ── Full Name ─────────────────────────────────────────
            Text('Full Name'.tr(context),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              focusNode: _nameFocus,
              onChanged: (v) => setState(() => _name = v),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter Full Name'.tr(context),
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
            Text('Phone Number'.tr(context),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
                border: _phoneError != null
                    ? Border.all(color: Colors.red, width: 1.5)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
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
                        onChanged: (v) => setState(() {
                          _phone = v;
                          _phoneError = v.isEmpty
                              ? null
                              : (_isPhoneValid(v) ? null : 'Phone must be exactly 8 digits');
                        }),
                        keyboardType: TextInputType.phone,
                        maxLength: 8,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'Enter Phone Number'.tr(context),
                          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                  ]),
                  if (_phoneError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(_phoneError!,
                          style: const TextStyle(color: Colors.red, fontSize: 11)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Location — only for product orders ────────────────
            if (widget.hasProducts && _locationCity == null)
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
                    Text('Set Your Location'.tr(context),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ]),
                ),
              )
            else if (widget.hasProducts)
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
                  if (_name.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter your name'.tr(context)), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (!_isPhoneValid(_phone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone must be exactly 8 digits'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (widget.hasProducts && _locationDetail == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please set your delivery location'.tr(context)), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (widget.onSaved != null) {
                    widget.onSaved!({
                      'name': _name.trim(),
                      'phone': _phone.replaceAll(RegExp(r'\D'), ''),
                      'address': widget.hasProducts ? _locationDetail : 'Kuwait',
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEDED),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save'.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
