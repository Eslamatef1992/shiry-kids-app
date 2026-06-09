import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';
import 'add_address_screen.dart';
import 'map_location_screen.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});
  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  int _selectedIndex = 0;

  final List<_Address> _addresses = [
    _Address(name: 'Dina Rizk', city: 'Kuwait City ,Kuwait', phone: '+9561234567'),
    _Address(name: 'Dina Rizk', city: 'Kuwait City ,Kuwait', phone: '+9561234567'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileBreadcrumb(section: 'My Address'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Add New Address',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Selected Address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AddressCard(
                address: _addresses[i],
                isSelected: _selectedIndex == i,
                onSelect: () => setState(() => _selectedIndex = i),
                onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapLocationScreen())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final _Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  const _AddressCard({required this.address, required this.isSelected, required this.onSelect, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
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
                Text(address.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(address.city, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 2),
                Text(address.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          side: const BorderSide(color: AppColors.divider),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Edit', style: TextStyle(color: AppColors.textDark, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38)),
                        child: const Text('Select', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Address {
  final String name, city, phone;
  const _Address({required this.name, required this.city, required this.phone});
}
