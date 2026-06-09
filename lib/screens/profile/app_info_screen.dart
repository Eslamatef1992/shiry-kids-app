import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wavy_app_bar.dart';

class AppInfoScreen extends StatelessWidget {
  final String title;
  const AppInfoScreen({super.key, required this.title});

  static const _body = [
    _Section(heading: 'Overview:', points: [
      'Shiry Kids is a fun e-commerce platform dedicated to bringing the best toys, books, art kits, and more to children across Kuwait.',
      'Our platform allows parents to discover curated collections, apply exclusive coupons, and enjoy fast, safe delivery right to their door.',
      'We partner with trusted local and international brands to ensure every product meets our safety and quality standards.',
    ]),
    _Section(heading: 'Agreement:', points: [
      'By using Shiry Kids, you agree to our terms of service and privacy policy.',
      'All purchases are subject to availability and our return policy. Items may be returned within 14 days of delivery.',
      'We reserve the right to update our terms at any time. Continued use of the app constitutes acceptance of the updated terms.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WavyAppBar(title: 'My Profile'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBreadcrumb(section: title),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _body.map((s) => _SectionWidget(section: s)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget({super.key, required this.section});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.heading,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 10),
          ...section.points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.textDark, fontSize: 14)),
                Expanded(child: Text(p, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.6))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Section {
  final String heading;
  final List<String> points;
  const _Section({required this.heading, required this.points});
}
