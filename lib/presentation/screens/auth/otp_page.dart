import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/core/utils/phone_number_formatter.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/otp_digit_field.dart';
import 'package:auth_profile_example/presentation/screens/main/main_shell_page.dart';
import 'package:auth_profile_example/presentation/widgets/common/app_button.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String countryName;
  final String flagEmoji;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.countryName,
    required this.flagEmoji,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _canResend = true;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      AppConstants.otpLength,
      (_) => TextEditingController(),
    );

    _focusNodes = List.generate(
      AppConstants.otpLength,
      (_) => FocusNode(),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _verify() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainShellPage(
          phoneNumber: widget.phoneNumber,
          countryName: widget.countryName,
          flagEmoji: widget.flagEmoji,
        ),
      ),
    );
  }

  void _onResendPressed() {
    if (!_canResend) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yangi kod qayta yuborildi'),
        duration: Duration(seconds: 3),
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhoneNumber =
        AppPhoneNumberFormatter.tryFormatSupportedInternational(
      widget.phoneNumber,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundStrong, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 30,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          AppConstants.sms,
                          width: 40,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Kodni tasdiqlang',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SMS orqali yuborilgan 4 xonali kodni kiriting.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedPhoneNumber,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          AppConstants.otpLength,
                          (index) => Row(
                            children: [
                              OtpDigitField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                onChanged: (value) => _onChanged(index, value),
                                onBackspace: () {
                                  if (index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                    _controllers[index - 1].clear();
                                  }
                                },
                              ),
                              if (index != AppConstants.otpLength - 1)
                                const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      AppButton(
                        label: 'Tasdiqlash',
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _canResend ? _onResendPressed : null,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: _canResend
                                    ? 'Kodni qayta yuborish'
                                    : 'Kodni qayta yuborish  ',
                                style: TextStyle(
                                    color: _canResend
                                        ? AppColors.primaryDark
                                        : AppColors.textHint,
                                    fontSize: 12),
                              ),
                              if (!_canResend)
                                TextSpan(
                                  text: '($_secondsLeft s)',
                                  style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
