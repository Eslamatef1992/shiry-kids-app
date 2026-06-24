import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms  = false;
  bool _loading = false;

  bool get _canSubmit =>
      _nameCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty &&
      _passCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      _acceptedTerms;

  void _signUp() async {
    if (!_canSubmit) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match'.tr(context)), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        '+965${_phoneCtrl.text.trim()}',
        _passCtrl.text,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        // Send OTP via SMS before showing the OTP screen
        await ApiService.sendOtp('+965${_phoneCtrl.text.trim()}');
        Navigator.pushNamed(context, '/otp', arguments: {
          'phone': '+965${_phoneCtrl.text.trim()}',
          'mode': 'signup',
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Registration failed'), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again.'.tr(context)), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
              Text('SIGN UP'.tr(context),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Text(
                'Enjoy The Best Shopping Experience Through The App.'.tr(context),
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
              ),
              const SizedBox(height: 32),

              _FieldLabel('Full Name'),
              const SizedBox(height: 8),
              TextField(controller: _nameCtrl, onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(hintText: 'Enter Full Name'.tr(context))),
              const SizedBox(height: 20),

              _FieldLabel('Email'),
              const SizedBox(height: 8),
              TextField(controller: _emailCtrl, onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(hintText: 'Enter Email'.tr(context))),
              const SizedBox(height: 20),

              _FieldLabel('Phone Number'),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(hintText: 'Enter Phone Number'.tr(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _FieldLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password'.tr(context),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _FieldLabel('Confirm Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password'.tr(context),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Terms checkbox
              GestureDetector(
                onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                child: Row(
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _acceptedTerms ? AppColors.primary : AppColors.divider, width: 2),
                        color: _acceptedTerms ? AppColors.primary : Colors.transparent,
                      ),
                      child: _acceptedTerms
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Text('Accept The Terms And Conditions.'.tr(context),
                          style: const TextStyle(fontSize: 13, color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSubmit && !_loading ? _signUp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit ? AppColors.primary : const Color(0xFFFFE8E8),
                    foregroundColor: _canSubmit ? Colors.white : AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Sign Up'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.tr(context),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark));
}
