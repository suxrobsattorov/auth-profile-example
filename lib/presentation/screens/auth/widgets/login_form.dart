import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/core/utils/phone_number_formatter.dart';
import 'package:auth_profile_example/presentation/screens/auth/widgets/country_option_tile.dart';
import 'package:auth_profile_example/presentation/widgets/common/app_button.dart';

class CountryOption {
  final String name;
  final String flagEmoji;
  final String dialCode;
  final List<int> grouping;
  final String placeholder;

  const CountryOption({
    required this.name,
    required this.flagEmoji,
    required this.dialCode,
    required this.grouping,
    required this.placeholder,
  });

  int get maxDigits => grouping.fold(0, (sum, item) => sum + item);

  String formatLocalNumber(String digits) {
    return AppPhoneNumberFormatter.formatNational(
      digits: digits,
      grouping: grouping,
    );
  }

  String composePhone(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    return '$dialCode$clean';
  }
}

class LoginForm extends StatefulWidget {
  final void Function(String phoneNumber, CountryOption country) onContinue;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onContinue,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  static const List<CountryOption> _countries = [
    CountryOption(
      name: 'Uzbekistan',
      flagEmoji: '🇺🇿',
      dialCode: '+998',
      grouping: [2, 3, 2, 2],
      placeholder: '(90) 123-45-67',
    ),
    CountryOption(
      name: 'Kazakhstan',
      flagEmoji: '🇰🇿',
      dialCode: '+7',
      grouping: [3, 3, 2, 2],
      placeholder: '(701) 123-45-67',
    ),
    CountryOption(
      name: 'Kyrgyzstan',
      flagEmoji: '🇰🇬',
      dialCode: '+996',
      grouping: [3, 3, 3],
      placeholder: '(555) 123-456',
    ),
    CountryOption(
      name: 'Turkey',
      flagEmoji: '🇹🇷',
      dialCode: '+90',
      grouping: [3, 3, 2, 2],
      placeholder: '(530) 123-45-67',
    ),
    CountryOption(
      name: 'United States',
      flagEmoji: '🇺🇸',
      dialCode: '+1',
      grouping: [3, 3, 4],
      placeholder: '(555) 123-4567',
    ),
  ];

  final _phoneController = TextEditingController();
  late CountryOption _selectedCountry;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String? _errorText;

  String get _rawDigits => _phoneController.text.replaceAll(RegExp(r'\D'), '');
  bool get _isEmpty => _rawDigits.isEmpty;
  bool get _isIncomplete =>
      _rawDigits.isNotEmpty && _rawDigits.length < _selectedCountry.maxDigits;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
    _phoneController.addListener(_onPhoneChanged);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    } else {
      setState(() {});
    }
  }

  void _shake(String error) {
    setState(() => _errorText = error);
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }

  Future<void> _pickCountry() async {
    final country = await showModalBottomSheet<CountryOption>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Davlat', style: AppTextStyles.titleLarge),
                  ),
                ),
                const SizedBox(height: 8),
                ..._countries.map(
                  (country) => CountryOptionTile(
                    name: country.name,
                    flagEmoji: country.flagEmoji,
                    dialCode: country.dialCode,
                    isSelected: country == _selectedCountry,
                    onTap: () => Navigator.of(context).pop(country),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (country != null && mounted) {
      setState(() {
        _selectedCountry = country;
        _errorText = null;
        final truncatedDigits = _rawDigits.substring(
          0,
          math.min(_rawDigits.length, country.maxDigits),
        );
        final formatted = country.formatLocalNumber(truncatedDigits);
        _phoneController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_isEmpty) {
      _shake('Telefon raqamini kiriting');
      return;
    }
    if (_isIncomplete) {
      _shake(
        '${_selectedCountry.name} uchun ${_selectedCountry.maxDigits} ta raqam kiriting',
      );
      return;
    }
    setState(() => _errorText = null);
    widget.onContinue(
      _selectedCountry.composePhone(_rawDigits),
      _selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Telefon raqami', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final dx = math.sin(_shakeAnimation.value * math.pi * 6) * 8;
            return Transform.translate(
              offset: Offset(dx, 0),
              child: child,
            );
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError ? Colors.red.shade400 : AppColors.divider,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: _pickCountry,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedCountry.dialCode,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.divider),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                        _selectedCountry.maxDigits,
                      ),
                      _PhoneNumberFormatter(_selectedCountry.grouping),
                    ],
                    decoration: InputDecoration(
                      hintText: _selectedCountry.placeholder,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Kodni olish',
          icon: Icons.arrow_forward_rounded,
          isLoading: widget.isLoading,
          onPressed: widget.isLoading ? null : _submit,
        ),
      ],
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  final List<int> grouping;

  const _PhoneNumberFormatter(this.grouping);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = AppPhoneNumberFormatter.formatNational(
      digits: newValue.text,
      grouping: grouping,
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
