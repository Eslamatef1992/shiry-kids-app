import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/location_picker_screen.dart';
import '../screens/profile/add_address_screen.dart';

/// Shows a bottom sheet letting the user choose between picking an address on
/// the map or entering one manually, then pushes the corresponding screen and
/// returns its result (`{'detail': ..., 'name': ..., 'phone': ...}` — name and
/// phone are only present when entered manually).
Future<Map<String, dynamic>?> pickAddress(BuildContext context) async {
  final method = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Add New Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined, color: AppColors.primary),
            title: const Text('Pick On Map', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(ctx, 'map'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.edit_location_alt_outlined, color: AppColors.primary),
            title: const Text('Enter Manually', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(ctx, 'manual'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (method == null || !context.mounted) return null;

  if (method == 'map') {
    return Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
  }

  return Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(builder: (_) => const AddAddressScreen()),
  );
}
