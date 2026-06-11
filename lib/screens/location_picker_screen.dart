import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Default camera position (Kuwait City) until we get the user's location.
  static const LatLng _defaultCenter = LatLng(29.3759, 47.9774);

  GoogleMapController? _mapController;
  LatLng _center = _defaultCenter;
  String _address = 'Kuwait City, Kuwait';
  bool _loading = true;
  bool _resolvingAddress = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      _center = LatLng(pos.latitude, pos.longitude);
      await _resolveAddress(_center);
    } catch (_) {
      // Fall back to the default center silently.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolveAddress(LatLng position) async {
    setState(() => _resolvingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.subLocality, p.locality, p.country]
            .where((e) => e != null && e.isNotEmpty)
            .toList();
        if (mounted) {
          setState(() => _address = parts.isNotEmpty ? parts.join(', ') : 'Selected location');
        }
      }
    } catch (_) {
      // Keep the previous address if reverse geocoding fails.
    } finally {
      if (mounted) setState(() => _resolvingAddress = false);
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final target = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLng(target));
        setState(() => _center = target);
        await _resolveAddress(target);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address not found'.tr(context))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // ── Google Map ────────────────────────────────────────
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _center, zoom: 15),
          onMapCreated: (controller) => _mapController = controller,
          onCameraMove: (position) => _center = position.target,
          onCameraIdle: () => _resolveAddress(_center),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        if (_loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white54,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          ),

        // ── Search bar ────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16, right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _searchAddress,
              decoration: const InputDecoration(
                hintText: 'Search Your Address',
                hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Color(0xFFAAAAAA), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // ── My location button ─────────────────────────────────
        Positioned(
          bottom: 180, right: 16,
          child: FloatingActionButton(
            heroTag: 'my-location',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () async {
              setState(() => _loading = true);
              await _detectCurrentLocation();
              _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
            },
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),

        // ── Center pin (fixed, map moves underneath) ───────────
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_on, color: AppColors.primary, size: 40),
          ),
        ),

        // ── Bottom sheet ──────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _resolvingAddress ? 'Locating...' : _address,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    'lat': _center.latitude,
                    'lng': _center.longitude,
                    'detail': _address,
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEDED),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 9, height: 9,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                          child: const Icon(Icons.add, size: 7, color: Colors.white),
                        ),
                      ),
                    ]),
                    const SizedBox(width: 8),
                    Text('Set Your Location'.tr(context),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
