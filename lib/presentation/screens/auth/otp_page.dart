import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_profile_example/application/auth/auth_bloc.dart';
import 'package:auth_profile_example/application/auth/auth_event.dart';
import 'package:auth_profile_example/application/auth/auth_state.dart';
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
  static const _totalSeconds = 120;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _canResend = false;
  int _secondsLeft = _totalSeconds;
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
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

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  void _verify() {
    FocusScope.of(context).unfocus();
    if (!_isOtpComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, 4 xonali kodni to\'liq kiriting'),
        ),
      );
      return;
    }
    final code = _controllers.map((c) => c.text.trim()).join();
    context
        .read<AuthBloc>()
        .add(AuthVerifyOtp(phone: widget.phoneNumber, code: code));
  }

  void _onResendPressed() {
    if (!_canResend) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yangi kod qayta yuborildi'),
        duration: Duration(seconds: 3),
      ),
    );
    context.read<AuthBloc>().add(AuthRequestOtp(widget.phoneNumber));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _totalSeconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhoneNumber =
        AppPhoneNumberFormatter.tryFormatSupportedInternational(
      widget.phoneNumber,
    );

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainShellPage(
                phoneNumber: widget.phoneNumber,
                countryName: widget.countryName,
                flagEmoji: widget.flagEmoji,
              ),
            ),
          );
        } else if (state is AuthOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yangi kod yuborildi ✓')),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final progress = _secondsLeft / _totalSeconds;

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
                          const SizedBox(height: 24),
                          _OtpTimerIndicator(
                            progress: progress,
                            formattedTime: _formattedTime,
                            isExpired: _canResend,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              AppConstants.otpLength,
                              (index) => Row(
                                children: [
                                  OtpDigitField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    onChanged: (value) =>
                                        _onChanged(index, value),
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
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _verify,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: (_canResend && !isLoading)
                                ? _onResendPressed
                                : null,
                            child: Text(
                              _canResend
                                  ? 'Kodni qayta yuborish'
                                  : 'Qayta yuborish uchun kuting...',
                              style: TextStyle(
                                color: _canResend
                                    ? AppColors.primaryDark
                                    : AppColors.textHint,
                                fontSize: 13,
                                fontWeight: _canResend
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
      },
    );
  }
}

class _OtpTimerIndicator extends StatelessWidget {
  final double progress;
  final String formattedTime;
  final bool isExpired;

  const _OtpTimerIndicator({
    required this.progress,
    required this.formattedTime,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isExpired ? AppColors.textHint : AppColors.primaryDark;

    return Row(
      children: [
        Icon(
          isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
          size: 15,
          color: activeColor,
        ),
        const SizedBox(width: 6),
        Text(
          formattedTime,
          style: TextStyle(
            color: activeColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.textHint.withAlpha(50),
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
        ),
      ],
    );
  }
}
