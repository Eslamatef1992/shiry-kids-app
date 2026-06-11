import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'admin/admin_login_screen.dart';
import '../l10n/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _remember   = false;
  bool _loading    = false;

  bool get _canSubmit =>
      _emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty;

  void _login() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Login failed'), backgroundColor: Colors.red),
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
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

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
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Text('LOGIN'.tr(context),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Text(
                'We Provide You With The Latest Products At The Best Price.'.tr(context),
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Email
              _FieldLabel('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: 'Enter Your Email'.tr(context)),
              ),
              const SizedBox(height: 20),

              // Password
              _FieldLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password'.tr(context),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remember Me + Forget Password
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _remember = !_remember),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _remember ? AppColors.primary : AppColors.divider, width: 2),
                            color: _remember ? AppColors.primary : Colors.transparent,
                          ),
                          child: _remember
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text('Remember Me'.tr(context), style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text('Forget Password?'.tr(context),
                        style: const TextStyle(fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Log In button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSubmit && !_loading ? _login : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit ? AppColors.primary : const Color(0xFFEEEEEE),
                    foregroundColor: _canSubmit ? Colors.white : AppColors.textMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Log In'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 32),

              // Super Admin entry (subtle link at bottom)
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                  child: Text('Login as Super Admin'.tr(context),
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textLight)),
                ),
              ),
              const SizedBox(height: 16),
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
