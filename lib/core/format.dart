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

const _weekdays = [
  'понедельник',
  'вторник',
  'среда',
  'четверг',
  'пятница',
  'суббота',
  'воскресенье',
];

/// 16 октября 2026, пятница
String formatFullDate(DateTime date) =>
    '${formatDate(date)}, ${_weekdays[date.weekday - 1]}';

/// Копейки -> строка для поля ввода: 125050 -> «1250,50», 246000 -> «2460».
String kopecksToInput(int kopecks) {
  final rubles = kopecks ~/ 100;
  final cents = kopecks % 100;
  return cents == 0 ? '$rubles' : '$rubles,${cents.toString().padLeft(2, '0')}';
}

/// Выбор формы слова по числу: 1 день, 2 дня, 5 дней.
String pluralRu(int n, String one, String few, String many) {
  final n10 = n % 10;
  final n100 = n % 100;
  if (n10 == 1 && n100 != 11) return one;
  if (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) return few;
  return many;
}

String formatDays(int n) => '$n ${pluralRu(n, 'день', 'дня', 'дней')}';

String formatExpenseCount(int n) =>
    '$n ${pluralRu(n, 'расход', 'расхода', 'расходов')}';

/// 12–15 октября 2026 / 30 октября – 2 ноября 2026 / 12 октября 2026
String formatDateRange(DateTime a, DateTime b) {
  if (a.year == b.year && a.month == b.month) {
    if (a.day == b.day) return formatDate(a);
    return '${a.day}–${b.day} ${_monthsGenitive[a.month - 1]} ${a.year}';
  }
  if (a.year == b.year) {
    return '${formatDayMonth(a)} – ${formatDayMonth(b)} ${a.year}';
  }
  return '${formatDate(a)} – ${formatDate(b)}';
}

const _monthsShort = [
  'Янв',
  'Фев',
  'Мар',
  'Апр',
  'Май',
  'Июн',
  'Июл',
  'Авг',
  'Сен',
  'Окт',
  'Ноя',
  'Дек',
];

/// Окт
String formatMonthShort(DateTime date) => _monthsShort[date.month - 1];
