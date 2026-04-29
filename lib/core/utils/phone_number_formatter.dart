import 'dart:math' as math;

class PhoneNumberPattern {
  final String dialCode;
  final List<int> grouping;

  const PhoneNumberPattern({
    required this.dialCode,
    required this.grouping,
  });
}

class AppPhoneNumberFormatter {
  AppPhoneNumberFormatter._();

  static const List<PhoneNumberPattern> supportedPatterns = [
    PhoneNumberPattern(dialCode: '+998', grouping: [2, 3, 2, 2]),
    PhoneNumberPattern(dialCode: '+996', grouping: [3, 3, 3]),
    PhoneNumberPattern(dialCode: '+90', grouping: [3, 3, 2, 2]),
    PhoneNumberPattern(dialCode: '+7', grouping: [3, 3, 2, 2]),
    PhoneNumberPattern(dialCode: '+1', grouping: [3, 3, 4]),
  ];

  static String formatNational({
    required String digits,
    required List<int> grouping,
  }) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty || grouping.isEmpty) {
      return '';
    }

    final segments = _splitIntoGroups(clean, grouping);
    if (segments.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('(')..write(segments.first);
    if (segments.length > 1) {
      buffer.write(')');
    }

    for (var index = 1; index < segments.length; index++) {
      buffer.write(index == 1 ? ' ' : '-');
      buffer.write(segments[index]);
    }

    return buffer.toString();
  }

  static String formatInternational({
    required String phoneNumber,
    required String dialCode,
    required List<int> grouping,
  }) {
    final clean = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final dialDigits = dialCode.replaceAll(RegExp(r'\D'), '');
    final maxDigits = grouping.fold<int>(0, (sum, group) => sum + group);

    final localDigits = clean.startsWith(dialDigits)
        ? clean.substring(dialDigits.length)
        : clean;
    final truncatedLocalDigits = localDigits.substring(
      0,
      math.min(localDigits.length, maxDigits),
    );
    final formattedLocal = formatNational(
      digits: truncatedLocalDigits,
      grouping: grouping,
    );

    return formattedLocal.isEmpty ? dialCode : '$dialCode $formattedLocal';
  }

  static String tryFormatSupportedInternational(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return phoneNumber;
    }

    for (final pattern in supportedPatterns) {
      final dialDigits = pattern.dialCode.replaceAll(RegExp(r'\D'), '');
      if (clean.startsWith(dialDigits)) {
        return formatInternational(
          phoneNumber: clean,
          dialCode: pattern.dialCode,
          grouping: pattern.grouping,
        );
      }
    }

    return phoneNumber;
  }

  static List<String> _splitIntoGroups(String digits, List<int> grouping) {
    final segments = <String>[];
    var start = 0;

    for (final group in grouping) {
      if (start >= digits.length) {
        break;
      }

      final end = math.min(start + group, digits.length);
      segments.add(digits.substring(start, end));
      start = end;
    }

    return segments;
  }
}
