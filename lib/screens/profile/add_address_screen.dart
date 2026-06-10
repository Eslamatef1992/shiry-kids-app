import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';

/// Manual address entry form. Returns a map shaped like
/// `{'detail': <combined address string>, 'name': <recipient name>, 'phone': <phone>}`
/// — the same shape `LocationPickerScreen` returns (plus optional name/phone),
/// so callers can use it as a drop-in alternative.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _apartmentCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  int _tabIndex = 0;
  final List<String> _tabs = ['The House', 'The Office', 'Other'];
  final String _countryCode = '+965';

  @override
  void dispose() {
    _apartmentCtrl.dispose();
    _buildingCtrl.dispose();
    _streetCtrl.dispose();
    _blockCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final parts = <String>[];
    if (_blockCtrl.text.trim().isNotEmpty) parts.add('Block ${_blockCtrl.text.trim()}');
    if (_streetCtrl.text.trim().isNotEmpty) parts.add(_streetCtrl.text.trim());
    if (_buildingCtrl.text.trim().isNotEmpty) parts.add(_buildingCtrl.text.trim());
    if (_apartmentCtrl.text.trim().isNotEmpty) parts.add(_apartmentCtrl.text.trim());
    parts.add(_tabs[_tabIndex]);

    final detail = parts.join(', ');
    final name = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
    final phone = '$_countryCode${_phoneCtrl.text.trim()}';

    Navigator.pop(context, {
      'detail': detail,
      'name': name,
      'phone': phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Add A New Address'),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Tabs
            Container(
              color: AppColors.white,
              child: Row(
                children: List.generate(_tabs.length, (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: _tabIndex == i ? AppColors.primary : Colors.transparent,
                          width: 2,
                        )),
                      ),
                      child: Text(
                        _tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _tabIndex == i ? AppColors.primary : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  _FormField(label: 'Apartment Number', hint: 'Apartment Number And Floor / Villa Number', controller: _apartmentCtrl, required: true),
                  const SizedBox(height: 16),
                  _FormField(label: 'Name Of Building', hint: 'Name Of Building/Block', controller: _buildingCtrl, required: true),
                  const SizedBox(height: 16),
                  _FormField(label: 'Street Name', hint: 'Street Name / Landmark', controller: _streetCtrl),
                  const SizedBox(height: 16),
                  _FormField(label: 'Block Number', hint: 'Block Number', controller: _blockCtrl),
                  const SizedBox(height: 24),

                  // Recipient Details
                  const Text('Recipient Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  _FormField(label: 'First Name', hint: 'First Name', controller: _firstNameCtrl, required: true),
                  const SizedBox(height: 16),
                  _FormField(label: 'Last Name', hint: 'Last Name', controller: _lastNameCtrl, required: true),
                  const SizedBox(height: 16),

                  // Phone with country code
                  _RequiredLabel('Phone Number'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Text(_countryCode, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: '123455'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A Verification Code Will Be Sent Via WhatsApp To This Mobile Number.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _save, child: const Text('Save Address')),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool required;
  const _FormField({required this.label, required this.hint, required this.controller, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequiredLabel(label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        ),
      ],
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _RequiredLabel(this.text, {this.required = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        if (required) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
