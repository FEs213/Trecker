String _groupDigits(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Сумма в копейках -> «2 460 ₽» или «2 460,50 ₽» (с неразрывными пробелами).
String formatKopecks(int kopecks) {
  final negative = kopecks < 0;
  final abs = kopecks.abs();
  final rubles = _groupDigits(abs ~/ 100);
  final cents = abs % 100;
  final tail = cents == 0 ? '' : ',${cents.toString().padLeft(2, '0')}';
  return '${negative ? '−' : ''}$rubles$tail\u00A0₽';
}

/// Сумма в рублях -> «42 860 ₽».
String formatRub(num value) => formatKopecks((value * 100).round());

/// Разбирает введённую сумму («1 250,50», «1250.5») в копейки.
/// Возвращает null, если сумма пустая, не число, не больше нуля или слишком большая.
int? parseAmountToKopecks(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[\s\u00A0]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value <= 0 || value > 1000000000) return null;
  return (value * 100).round();
}

const _monthsGenitive = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

const _monthsNominative = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
];

/// 16 октября 2026
String formatDate(DateTime date) =>
    '${date.day} ${_monthsGenitive[date.month - 1]} ${date.year}';

/// 16 октября
String formatDayMonth(DateTime date) =>
    '${date.day} ${_monthsGenitive[date.month - 1]}';

/// Октябрь 2026
String formatMonthYear(DateTime date) =>
    '${_monthsNominative[date.month - 1]} ${date.year}';
