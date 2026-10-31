import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/wavy_app_bar.dart';

class GuestCheckoutScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const GuestCheckoutScreen({super.key, required this.onSaved});

  @override
  State<GuestCheckoutScreen> createState() => _GuestCheckoutScreenState();
}

class _GuestCheckoutScreenState extends State<GuestCheckoutScreen> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool get _canContinue =>
      _nameCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty &&
      _addressCtrl.text.isNotEmpty;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Guest Info', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _label('Full Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 20),
            _label('Phone Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Enter your phone'),
            ),
            const SizedBox(height: 20),
            _label('Delivery Address'),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Enter delivery address',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canContinue ? widget.onSaved : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canContinue ? AppColors.primary : const Color(0xFFEEEEEE),
                  foregroundColor:
                      _canContinue ? Colors.white : AppColors.textMedium,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark));
}
