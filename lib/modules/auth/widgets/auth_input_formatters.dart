import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 11 ? digits.substring(0, 11) : digits;
    final digitsBeforeCursor = newValue.text
        .substring(
          0,
          newValue.selection.extentOffset.clamp(0, newValue.text.length),
        )
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, limitedDigits.length);
    final formatted = _formatCpf(limitedDigits);
    final cursorOffset = _formatCpf(
      limitedDigits.substring(0, digitsBeforeCursor),
    ).length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _formatCpf(String digits) {
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index == 3 || index == 6) buffer.write('.');
      if (index == 9) buffer.write('-');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 11 ? digits.substring(0, 11) : digits;
    final digitsBeforeCursor = newValue.text
        .substring(
          0,
          newValue.selection.extentOffset.clamp(0, newValue.text.length),
        )
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, limitedDigits.length);
    final formatted = _formatPhone(limitedDigits);
    final cursorOffset = _formatPhone(
      limitedDigits.substring(0, digitsBeforeCursor),
    ).length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _formatPhone(String digits) {
    if (digits.length <= 2) return digits;

    final areaCode = digits.substring(0, 2);
    final subscriber = digits.substring(2);
    final buffer = StringBuffer('($areaCode) ');
    if (subscriber.length > 4) {
      buffer
        ..write(subscriber.substring(0, subscriber.length - 4))
        ..write('-')
        ..write(subscriber.substring(subscriber.length - 4));
    } else {
      buffer.write(subscriber);
    }
    return buffer.toString();
  }
}
