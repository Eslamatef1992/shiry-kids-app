import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

  bool get _canConfirm =>
      _newCtrl.text.isNotEmpty && _confirmCtrl.text.isNotEmpty;

  @override
  void dispose() { _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

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
              const Text('NEW PASSWORD',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 32),

              const Text('New Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _newCtrl,
                obscureText: !_showNew,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _showNew = !_showNew),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Confirm New Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: !_showConfirm,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canConfirm
                      ? () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canConfirm ? AppColors.primary : const Color(0xFFEEEEEE),
                    foregroundColor: _canConfirm ? Colors.white : AppColors.textMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
