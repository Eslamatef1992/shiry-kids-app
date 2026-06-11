import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';
import '../../services/api_service.dart';
import '../../widgets/address_method_sheet.dart';
import '../../l10n/app_strings.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});
  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  bool _loading = true;
  String? _name;
  String? _phone;
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getProfile();
      if (!mounted) return;
      if (res['success'] == true) {
        final user = res['user'] as Map<String, dynamic>?;
        if (user != null) {
          setState(() {
            _name = user['name'] as String?;
            _phone = user['phone'] as String?;
            _address = user['address'] as String?;
          });
        }
      }
    } catch (_) {
      // Keep whatever we have; user can still try to add an address.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAddress() async {
    final result = await pickAddress(context);
    if (result == null || !mounted) return;
    final detail = result['detail'] as String?;
    if (detail == null) return;
    final manualName = result['name'] as String?;
    final manualPhone = result['phone'] as String?;

    setState(() => _loading = true);
    try {
      final res = await ApiService.updateProfile(
        address: detail,
        name: (manualName != null && manualName.trim().isNotEmpty) ? manualName : null,
        phone: (manualPhone != null && manualPhone.trim().isNotEmpty) ? manualPhone : null,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        final user = res['user'] as Map<String, dynamic>?;
        setState(() {
          _address = (user?['address'] as String?) ?? detail;
          _name = (user?['name'] as String?) ?? manualName ?? _name;
          _phone = (user?['phone'] as String?) ?? manualPhone ?? _phone;
        });
      } else {
        setState(() {
          _address = detail;
          _name = manualName ?? _name;
          _phone = manualPhone ?? _phone;
        });
      }
    } catch (_) {
      setState(() {
        _address = detail;
        _name = manualName ?? _name;
        _phone = manualPhone ?? _phone;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _hasAddress => _address != null && _address!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileBreadcrumb(section: 'My Address'),
          if (!_hasAddress)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _loading ? null : _pickAddress,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Add New Address'.tr(context),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          if (_hasAddress)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('My Address'.tr(context),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _hasAddress
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _AddressCard(
                            name: _name,
                            address: _address!,
                            phone: _phone,
                            onEdit: _pickAddress,
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_off_outlined, color: AppColors.textLight, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'You haven\'t added an address yet.'.tr(context),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String? name;
  final String address;
  final String? phone;
  final VoidCallback onEdit;
  const _AddressCard({this.name, required this.address, this.phone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null && name!.isNotEmpty)
                  Text(name!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone!, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Edit'.tr(context), style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
