import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
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
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    var index = 0;

    for (final group in grouping) {
      if (index >= clean.length) break;
      final end = math.min(index + group, clean.length);
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(clean.substring(index, end));
      index = end;
    }

    return buffer.toString();
  }

  String composePhone(String digits) {
    final formatted = formatLocalNumber(digits);
    return formatted.isEmpty ? dialCode : '$dialCode $formatted';
  }
}

class LoginForm extends StatefulWidget {
  final void Function(String phoneNumber, CountryOption country) onContinue;

  const LoginForm({
    super.key,
    required this.onContinue,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const List<CountryOption> _countries = [
    CountryOption(
      name: 'Uzbekistan',
      flagEmoji: '🇺🇿',
      dialCode: '+998',
      grouping: [2, 3, 2, 2],
      placeholder: '90 123 45 67',
    ),
    CountryOption(
      name: 'Kazakhstan',
      flagEmoji: '🇰🇿',
      dialCode: '+7',
      grouping: [3, 3, 2, 2],
      placeholder: '701 123 45 67',
    ),
    CountryOption(
      name: 'Kyrgyzstan',
      flagEmoji: '🇰🇬',
      dialCode: '+996',
      grouping: [3, 3, 3],
      placeholder: '555 123 456',
    ),
    CountryOption(
      name: 'Turkey',
      flagEmoji: '🇹🇷',
      dialCode: '+90',
      grouping: [3, 3, 2, 2],
      placeholder: '530 123 45 67',
    ),
    CountryOption(
      name: 'United States',
      flagEmoji: '🇺🇸',
      dialCode: '+1',
      grouping: [3, 3, 4],
      placeholder: '555 123 4567',
    ),
  ];

  final _phoneController = TextEditingController();
  late CountryOption _selectedCountry;

  String get _rawDigits => _phoneController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    setState(() {});
  }

  Future<void> _pickCountry() async {
    final country = await showModalBottomSheet<CountryOption>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
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
                    child: Text(
                      'Davlat',
                      style: AppTextStyles.titleLarge,
                    ),
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
    widget.onContinue(
      _selectedCountry.composePhone(_rawDigits),
      _selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Telefon raqami',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
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
              Container(
                width: 1,
                height: 28,
                color: AppColors.divider,
              ),
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
                      fontSize: 16,
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
        const SizedBox(height: 32),
        AppButton(
          label: 'Kodni olish',
          icon: Icons.arrow_forward_rounded,
          onPressed: _submit,
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
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    var index = 0;

    for (final group in grouping) {
      if (index >= digits.length) break;
      final end = math.min(index + group, digits.length);
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(digits.substring(index, end));
      index = end;
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
