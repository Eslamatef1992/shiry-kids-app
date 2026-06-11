import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';
import '../../services/api_service.dart';
import '../../l10n/app_strings.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldCtrl     = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showOld = false, _showNew = false, _showConfirm = false;
  bool _saving = false;

  Future<void> _changePassword() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New passwords do not match'.tr(context))));
      return;
    }
    setState(() => _saving = true);
    try {
      final res = await ApiService.changePassword(_oldCtrl.text, _newCtrl.text);
      if (mounted) {
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password updated'.tr(context)), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message'] ?? 'Failed')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _canUpdate =>
      _oldCtrl.text.isNotEmpty && _newCtrl.text.isNotEmpty && _confirmCtrl.text.isNotEmpty;

  @override
  void dispose() { _oldCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileBreadcrumb(section: 'Change Password'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _PassField(label: 'Old Password'.tr(context),         ctrl: _oldCtrl,     show: _showOld,     onToggle: () => setState(() => _showOld = !_showOld)),
                  const SizedBox(height: 20),
                  _PassField(label: 'New Password'.tr(context),         ctrl: _newCtrl,     show: _showNew,     onToggle: () => setState(() => _showNew = !_showNew)),
                  const SizedBox(height: 20),
                  _PassField(label: 'Confirm New Password'.tr(context), ctrl: _confirmCtrl, show: _showConfirm, onToggle: () => setState(() => _showConfirm = !_showConfirm),
                    onChanged: (_) => setState(() {})),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canUpdate && !_saving ? _changePassword : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Update Password'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool show;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  const _PassField({required this.label, required this.ctrl, required this.show, required this.onToggle, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: !show,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter Password'.tr(context),
            suffixIcon: IconButton(
              icon: Icon(show ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
