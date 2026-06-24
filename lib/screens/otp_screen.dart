import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  bool _hasError = false;
  bool _loading = false;
  int _seconds = 45;
  Timer? _timer;
  late Map<String, dynamic> _args;
  bool _argsLoaded = false;

  String get _code => _ctrls.map((c) => c.text).join();
  bool get _complete => _code.length == 4;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { t.cancel(); return; }
      setState(() => _seconds--);
    });
  }

  void _onDigit(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _nodes[index + 1].requestFocus();
    }
    setState(() => _hasError = false);
    setState(() {});
  }

  Future<void> _confirm() async {
    if (!_complete || _loading) return;
    final mode = _args['mode'] as String? ?? 'signup';

    if (mode == 'forgot') {
      // Forgot-password codes are real, Mailgun-delivered codes verified
      // against the backend.
      final email = _args['email'] as String? ?? '';
      setState(() { _loading = true; _hasError = false; });
      try {
        final res = await ApiService.verifyResetCode(email, _code);
        if (!mounted) return;
        if (res['success'] == true) {
          Navigator.pushReplacementNamed(context, '/new-password', arguments: {
            'email': email,
            'code': _code,
          });
        } else {
          setState(() => _hasError = true);
        }
      } catch (_) {
        if (mounted) setState(() => _hasError = true);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    // Verify OTP via backend API
    final phone = _args['phone'] as String? ?? '';
    setState(() { _loading = true; _hasError = false; });
    try {
      final res = await ApiService.verifyOtp(phone, _code);
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pushReplacementNamed(context, '/location');
      } else {
        setState(() => _hasError = true);
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resend() {
    for (final c in _ctrls) c.clear();
    setState(() => _hasError = false);
    _startTimer();
    _nodes[0].requestFocus();

    final mode = _args['mode'] as String? ?? 'signup';
    if (mode == 'forgot') {
      final email = _args['email'] as String? ?? '';
      if (email.isNotEmpty) ApiService.forgotPassword(email);
    } else {
      final phone = _args['phone'] as String? ?? '';
      if (phone.isNotEmpty) ApiService.sendOtp(phone);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _subtitle {
    final mode = _argsLoaded ? (_args['mode'] as String? ?? 'signup') : 'signup';
    final identifier = _argsLoaded ? (_args['phone'] ?? _args['email'] ?? '') : '';
    if (mode == 'forgot') {
      return 'A 4-Digit Verification Code Has Been Sent To This Phone Number. $identifier';
    }
    return 'A 4-Digit Verification Code Has Been Sent To This Phone Number. $identifier';
  }

  @override
  Widget build(BuildContext context) {
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _args = args;
        _argsLoaded = true;
      } else {
        _args = {'mode': 'signup', 'phone': '+9451234557'};
        _argsLoaded = true;
      }
    }

    final String id = _args['phone'] ?? _args['email'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Text('OTP CODE'.tr(context),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
                  children: [
                    TextSpan(text: 'A 4-Digit Verification Code Has Been Sent To This Phone Number. '.tr(context)),
                    TextSpan(text: id, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text('Enter 4-Digit Code'.tr(context),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),

              // OTP boxes
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _hasError ? Colors.red : AppColors.divider),
                  color: AppColors.white,
                ),
                child: Row(
                  children: List.generate(4, (i) => Expanded(
                    child: TextField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (v) => _onDigit(i, v),
                      onTap: () {
                        _ctrls[i].selection = TextSelection.fromPosition(
                          TextPosition(offset: _ctrls[i].text.length));
                      },
                    ),
                  )),
                ),
              ),

              if (_hasError) ...[
                const SizedBox(height: 6),
                Text('Invalid Verification Code.'.tr(context),
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_hasError)
                    Row(children: [
                      Text('Remaining '.tr(context), style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                      Text(
                        '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')} S',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ])
                  else
                    const SizedBox(),
                  GestureDetector(
                    onTap: _resend,
                    child: Text('Resend Code?'.tr(context),
                        style: const TextStyle(fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_complete && !_loading) ? _confirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _complete ? AppColors.primary : const Color(0xFFEEEEEE),
                    foregroundColor: _complete ? Colors.white : AppColors.textMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('Confirm'.tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
