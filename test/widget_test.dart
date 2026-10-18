import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trati/core/format.dart';
import 'package:trati/data/expense_repository.dart';
import 'package:trati/data/models.dart';
import 'package:trati/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('сумма разбирается в копейки', () {
    expect(parseAmountToKopecks('1 250,50'), 125050);
    expect(parseAmountToKopecks('1250.5'), 125050);
    expect(parseAmountToKopecks('0'), isNull);
    expect(parseAmountToKopecks(''), isNull);
    expect(parseAmountToKopecks('abc'), isNull);
  });

  test('копейки форматируются как рубли', () {
    expect(formatKopecks(246000), '2\u00A0460\u00A0₽');
    expect(formatKopecks(125050), '1\u00A0250,50\u00A0₽');
  });

  test('добавленный расход попадает в итоги и сохраняется', () async {
    final repo = ExpenseRepository();
    await repo.load();
    expect(repo.expenses, isEmpty);

    await repo.add(
      Expense(
        id: '1',
        amountKopecks: 246000,
        categoryName: 'Продукты',
        date: DateTime(2026, 10, 16),
        method: 'Карта',
        payee: 'ВкусВилл',
      ),
    );
    await repo.add(
      Expense(
        id: '2',
        amountKopecks: 140050,
        categoryName: 'Транспорт',
        date: DateTime(2026, 10, 15),
        method: 'Карта',
      ),
    );

    expect(repo.totalForMonth(DateTime(2026, 10)), 386050);
    expect(repo.totalForMonth(DateTime(2026, 9)), 0);
    expect(repo.categoryTotalsForMonth(DateTime(2026, 10)).first.key,
        'Продукты');

    final reloaded = ExpenseRepository();
    await reloaded.load();
    expect(reloaded.expenses.length, 2);
    expect(reloaded.expenses.first.title, 'ВкусВилл');
  });

  testWidgets('Приложение запускается и показывает вкладку «Обзор»',
      (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Траты'), findsWidgets);
    expect(find.text('Обзор'), findsWidgets);
  });
}
