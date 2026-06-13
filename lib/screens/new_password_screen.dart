import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});
  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _error;
  late Map<String, dynamic> _args;
  bool _argsLoaded = false;

  bool get _canConfirm =>
      _newCtrl.text.isNotEmpty && _confirmCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (_newCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.'.tr(context));
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.'.tr(context));
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final email = _args['email'] as String? ?? '';
      final code = _args['code'] as String? ?? '';
      final res = await ApiService.resetPassword(email, code, _newCtrl.text);
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
  void dispose() { _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _args = args is Map<String, dynamic> ? args : {};
      _argsLoaded = true;
    }
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
              Text('NEW PASSWORD'.tr(context),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 32),

              Text('New Password'.tr(context),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _newCtrl,
                obscureText: !_showNew,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password'.tr(context),
                  suffixIcon: IconButton(
                    icon: Icon(_showNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _showNew = !_showNew),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Confirm New Password'.tr(context),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: !_showConfirm,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password'.tr(context),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
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
                  onPressed: (_canConfirm && !_loading) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canConfirm ? AppColors.primary : const Color(0xFFEEEEEE),
                    foregroundColor: _canConfirm ? Colors.white : AppColors.textMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('Confirm'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
