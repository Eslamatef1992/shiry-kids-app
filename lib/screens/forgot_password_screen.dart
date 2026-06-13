import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  bool get _canContinue => _emailCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.forgotPassword(_emailCtrl.text.trim());
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pushNamed(context, '/otp', arguments: {
          'email': _emailCtrl.text.trim(),
          'mode': 'forgot',
        });
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Something went wrong'.tr(context));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Network error. Please try again.'.tr(context));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Text('OTP CODE'.tr(context),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Text(
                'Please Enter Your Email To Receive A Verification Code.'.tr(context),
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
              ),
              const SizedBox(height: 32),

              Text('Email'.tr(context),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: 'Enter Your Email'.tr(context)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_canContinue && !_loading) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canContinue ? AppColors.primary : const Color(0xFFEEEEEE),
                    foregroundColor: _canContinue ? Colors.white : AppColors.textMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('Continue'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
