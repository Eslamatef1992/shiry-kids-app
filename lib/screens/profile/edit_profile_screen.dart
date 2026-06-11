import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';
import '../../services/api_service.dart';
import '../../l10n/app_strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final res = await ApiService.getUser();
      if (mounted && res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>? ?? {};
        _nameCtrl.text  = data['name']?.toString() ?? '';
        _emailCtrl.text = data['email']?.toString() ?? '';
        _phoneCtrl.text = data['phone']?.toString() ?? '';
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final res = await ApiService.updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (mounted) {
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated'.tr(context)), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Failed to update'.tr(context))));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _hasChanges => _nameCtrl.text.isNotEmpty;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileBreadcrumb(section: 'Edit Name & Email'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _FieldLabel('Full Name'),
                        const SizedBox(height: 8),
                        TextField(controller: _nameCtrl, onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(hintText: 'Enter Full Name'.tr(context))),
                        const SizedBox(height: 20),
                        _FieldLabel('Email'),
                        const SizedBox(height: 8),
                        TextField(controller: _emailCtrl, enabled: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(hintText: 'Email cannot be changed'.tr(context))),
                        const SizedBox(height: 20),
                        _FieldLabel('Phone'),
                        const SizedBox(height: 8),
                        TextField(controller: _phoneCtrl, onChanged: (_) => setState(() {}),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(hintText: 'Enter Phone Number'.tr(context))),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _hasChanges && !_saving ? _save : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: _saving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('Update'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.tr(context),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark));
}
