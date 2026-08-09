import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

/// Flag asset for a language code — used by the picker rows and by the
/// standalone flag button in the home app bar.
String flagAssetFor(String languageCode) =>
    languageCode == 'ar' ? 'assets/icons/flag_kuwait.svg' : 'assets/icons/flag_us.svg';

/// Opens the shared language dialog (profile ▸ Change Language, home ▸ flag).
void showLanguagePicker(BuildContext context) {
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierColor: Colors.black26,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: const LanguagePicker(),
    ),
  );
}

/// Circular flag button showing the active language; tapping it opens the
/// language picker.
class LanguageFlagButton extends StatelessWidget {
  final double size;
  const LanguageFlagButton({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: () => showLanguagePicker(context),
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: SvgPicture.asset(flagAssetFor(code), width: size, height: size),
      ),
    );
  }
}

// ─── Language picker ──────────────────────────────────────────────────────────
// Selecting a language immediately switches the app's locale (and direction
// for Arabic/RTL) via LocaleProvider, then closes the sheet.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = Localizations.localeOf(context).languageCode;

    void selectLanguage(String code) {
      context.read<LocaleProvider>().setLocale(code);
      Navigator.pop(context);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(flag: flagAssetFor('ar'), label: 'Arabic',  value: 'ar', selected: selected, onTap: selectLanguage),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _LangOption(flag: flagAssetFor('en'), label: 'English', value: 'en', selected: selected, onTap: selectLanguage),

          // Cancel — plain text button matching Figma
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF8F8F8),
              ),
              child: Center(
                child: Text('Cancel'.tr(context),
                    style: const TextStyle(fontSize: 16, color: Color(0xff868686), fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag, label, value, selected;
  final ValueChanged<String> onTap;
  const _LangOption({required this.flag, required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onTap(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Circular flag
            SvgPicture.asset(flag, width: 36, height: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label.tr(context), style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              )),
            ),
            // Radio button — gray when unselected, orange bullseye when selected
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? null : const Color(0xFFF8F8F8),
                border: isSelected ? Border.all(color: AppColors.primary) : null,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14, height: 14,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary, // darker orange inner dot
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
