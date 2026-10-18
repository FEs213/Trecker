/// Форматирует сумму в рублях: 42860 -> «42 860 ₽» (с неразрывными пробелами).
String formatRub(num value) {
  final negative = value < 0;
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(digits[i]);
  }
  return '${negative ? '−' : ''}$buffer\u00A0₽';
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

/// 16 октября 2026
String formatDate(DateTime date) =>
    '${date.day} ${_monthsGenitive[date.month - 1]} ${date.year}';

/// 16 октября
String formatDayMonth(DateTime date) =>
    '${date.day} ${_monthsGenitive[date.month - 1]}';
