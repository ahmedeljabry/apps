class PhoneNumberHelper {
  static const String countryDialCode = '+213';

  static final RegExp _localMobilePattern = RegExp(r'^0[567]\d{8}$');

  static String normalizeLocal(String? value) {
    if (value == null) return '';

    String digits = _toWesternDigits(value).replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00213')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('213')) {
      digits = digits.substring(3);
    }

    if (digits.length == 9 && RegExp(r'^[567]').hasMatch(digits)) {
      digits = '0$digits';
    }
    return digits;
  }

  static bool isValidLocalMobile(String? value) {
    return _localMobilePattern.hasMatch(normalizeLocal(value));
  }

  static String toInternational(String? value) {
    final String local = normalizeLocal(value);
    if (!isValidLocalMobile(local)) return '';
    return '$countryDialCode${local.substring(1)}';
  }

  static String _toWesternDigits(String value) {
    const String arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    const String easternArabicIndic = '۰۱۲۳۴۵۶۷۸۹';
    final StringBuffer result = StringBuffer();
    for (final int rune in value.runes) {
      final String character = String.fromCharCode(rune);
      final int arabicIndex = arabicIndic.indexOf(character);
      final int easternIndex = easternArabicIndic.indexOf(character);
      if (arabicIndex >= 0) {
        result.write(arabicIndex);
      } else if (easternIndex >= 0) {
        result.write(easternIndex);
      } else {
        result.write(character);
      }
    }
    return result.toString();
  }
}
