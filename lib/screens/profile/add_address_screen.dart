import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['The House', 'The Office', 'Other'];
  String _countryCode = '+965';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'Add A New Address'),
      body: Column(
        children: [
          // Location header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kuwait', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                        Text('Kuwait City ,Kuwait', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textLight),
                ],
              ),
            ),
          ),

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
                _FormField(label: 'Apartment Number', hint: 'Apartment Number And Floor / Villa Number', required: true),
                const SizedBox(height: 16),
                _FormField(label: 'Name Of Building', hint: 'Name Of Building/Block', required: true),
                const SizedBox(height: 16),
                _FormField(label: 'Street Name', hint: 'Street Name / Landmark'),
                const SizedBox(height: 16),
                _FormField(label: 'Build Number', hint: 'Build Number'),
                const SizedBox(height: 16),
                _FormField(label: 'Short Name', hint: 'Short Name'),
                const SizedBox(height: 24),

                // Recipient Details
                const Text('Recipient Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 16),
                _FormField(label: 'First Name', hint: 'First Name', required: true),
                const SizedBox(height: 16),
                _FormField(label: 'Last Name', hint: 'Last Name', required: true),
                const SizedBox(height: 16),

                // Phone with country code
                _RequiredLabel('Phone Number'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
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
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more, size: 18, color: AppColors.textMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '123455'),
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
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Address')),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final bool required;
  const _FormField({required this.label, required this.hint, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequiredLabel(label, required: required),
        const SizedBox(height: 8),
        TextField(decoration: InputDecoration(hintText: hint)),
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
