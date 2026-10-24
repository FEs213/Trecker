import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trati/core/format.dart';
import 'package:trati/data/expense_filter.dart';
import 'package:trati/data/expense_repository.dart';
import 'package:trati/data/models.dart';
import 'package:trati/main.dart';
import 'package:trati/widgets/donut_chart.dart';
import 'package:trati/widgets/month_bars.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('сумма разбирается в копейки', () {
    expect(parseAmountToKopecks('1 250,50'), 125050);
    expect(parseAmountToKopecks('1250.5'), 125050);
    expect(parseAmountToKopecks('0'), isNull);
    expect(parseAmountToKopecks(''), isNull);
    expect(parseAmountToKopecks('abc'), isNull);
  });

  test('сумма для поля ввода', () {
    expect(kopecksToInput(125050), '1250,50');
    expect(kopecksToInput(246000), '2460');
    expect(kopecksToInput(5), '0,05');
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

  test('удалённый расход пропадает и не возвращается после перезагрузки',
      () async {
    final repo = ExpenseRepository();
    await repo.load();
    await repo.add(
      Expense(
        id: '1',
        amountKopecks: 10000,
        categoryName: 'Кафе',
        date: DateTime(2026, 10, 1),
        method: 'Карта',
      ),
    );
    await repo.add(
      Expense(
        id: '2',
        amountKopecks: 20000,
        categoryName: 'Кафе',
        date: DateTime(2026, 10, 2),
        method: 'Карта',
      ),
    );

    await repo.remove('1');
    expect(repo.expenses.map((e) => e.id), ['2']);
    expect(repo.totalForMonth(DateTime(2026, 10)), 20000);

    await repo.remove('нет-такого');
    expect(repo.expenses.length, 1);

    final reloaded = ExpenseRepository();
    await reloaded.load();
    expect(reloaded.expenses.map((e) => e.id), ['2']);
  });

  test('изменённый расход заменяется и сохраняется', () async {
    final repo = ExpenseRepository();
    await repo.load();
    await repo.add(
      Expense(
        id: '1',
        amountKopecks: 10000,
        categoryName: 'Кафе',
        date: DateTime(2026, 10, 1),
        method: 'Карта',
      ),
    );

    await repo.update(
      Expense(
        id: '1',
        amountKopecks: 35000,
        categoryName: 'Транспорт',
        date: DateTime(2026, 10, 3),
        method: 'Наличные',
        payee: 'Метро',
      ),
    );

    expect(repo.expenses.length, 1);
    expect(repo.byId('1')?.title, 'Метро');
    expect(repo.totalForMonth(DateTime(2026, 10)), 35000);

    final reloaded = ExpenseRepository();
    await reloaded.load();
    expect(reloaded.byId('1')?.amountKopecks, 35000);
  });

  test('склонения и период поездки', () {
    expect(formatDays(1), '1 день');
    expect(formatDays(3), '3 дня');
    expect(formatDays(11), '11 дней');
    expect(formatExpenseCount(21), '21 расход');
    expect(
      formatDateRange(DateTime(2026, 10, 12), DateTime(2026, 10, 15)),
      '12–15 октября 2026',
    );
    expect(
      formatDateRange(DateTime(2026, 10, 30), DateTime(2026, 11, 2)),
      '30 октября – 2 ноября 2026',
    );
    final trip = Trip(
      id: 't',
      name: 'Казань',
      start: DateTime(2026, 10, 12),
      end: DateTime(2026, 10, 15),
    );
    expect(trip.days, 4);
    expect(trip.statusOn(DateTime(2026, 10, 1)), 'предстоящая поездка');
    expect(trip.statusOn(DateTime(2026, 10, 13)), 'идёт сейчас');
    expect(trip.statusOn(DateTime(2026, 11, 1)), 'завершена');
  });

  test('поездка собирает расходы, а при удалении отвязывает их', () async {
    final repo = ExpenseRepository();
    await repo.load();
    await repo.addTrip(
      Trip(
        id: 'kzn',
        name: 'Казань',
        start: DateTime(2026, 10, 12),
        end: DateTime(2026, 10, 15),
      ),
    );
    await repo.add(
      Expense(
        id: '1',
        amountKopecks: 400000,
        categoryName: 'Транспорт',
        date: DateTime(2026, 10, 12),
        method: 'Карта',
        tripId: 'kzn',
      ),
    );
    await repo.add(
      Expense(
        id: '2',
        amountKopecks: 220000,
        categoryName: 'Кафе',
        date: DateTime(2026, 10, 13),
        method: 'Наличные',
        tripId: 'kzn',
      ),
    );
    await repo.add(
      Expense(
        id: '3',
        amountKopecks: 100000,
        categoryName: 'Продукты',
        date: DateTime(2026, 10, 14),
        method: 'Карта',
      ),
    );

    expect(repo.totalForTrip('kzn'), 620000);
    expect(repo.tripTotalForMonth(DateTime(2026, 10)), 620000);
    expect(repo.totalForMonth(DateTime(2026, 10)), 720000);
    expect(repo.tripsForMonth(DateTime(2026, 10)).length, 1);
    expect(repo.tripsForMonth(DateTime(2026, 9)), isEmpty);

    final reloaded = ExpenseRepository();
    await reloaded.load();
    expect(reloaded.tripById('kzn')?.name, 'Казань');
    expect(reloaded.expensesForTrip('kzn').length, 2);

    await repo.deleteTrip('kzn');
    expect(repo.trips, isEmpty);
    expect(repo.expenses.length, 3);
    expect(repo.expensesForTrip('kzn'), isEmpty);
    expect(repo.byId('1')?.tripId, '');
  });

  test('своя категория: создание, переименование и удаление', () async {
    final repo = ExpenseRepository();
    await repo.load();

    expect(repo.categoryNameTaken('продукты'), isTrue);
    expect(repo.categoryNameTaken('Питомцы'), isFalse);

    await repo.addCategory(
      const ExpenseCategory(
        'Питомцы',
        Icons.pets_outlined,
        id: 'c1',
        iconKey: 'paw',
        color: Color(0xFFA48BC9),
      ),
    );
    expect(repo.allCategories.length, kCategories.length + 1);
    expect(repo.categoryNameTaken('питомцы'), isTrue);
    expect(repo.categoryNameTaken('Питомцы', exceptId: 'c1'), isFalse);

    await repo.add(
      Expense(
        id: '1',
        amountKopecks: 50000,
        categoryName: 'Питомцы',
        date: DateTime(2026, 10, 5),
        method: 'Карта',
      ),
    );

    // Пока в категории есть расходы, удалить её нельзя.
    expect(await repo.deleteCategory('c1'), isFalse);
    expect(repo.expenseCountForCategory('Питомцы'), 1);

    // Переименование меняет название и в расходах.
    await repo.updateCategory(
      const ExpenseCategory(
        'Животные',
        Icons.pets_outlined,
        id: 'c1',
        iconKey: 'paw',
        color: Color(0xFFDDA58C),
      ),
    );
    expect(repo.byId('1')?.categoryName, 'Животные');
    expect(repo.categoryByName('Животные').color, const Color(0xFFDDA58C));
    expect(repo.categoryByName('Нет такой').name, 'Другое');

    final reloaded = ExpenseRepository();
    await reloaded.load();
    expect(reloaded.customCategories.single.name, 'Животные');
    expect(reloaded.customCategories.single.iconKey, 'paw');
    expect(reloaded.byId('1')?.categoryName, 'Животные');

    // После удаления расхода категорию уже можно удалить.
    await repo.remove('1');
    expect(await repo.deleteCategory('c1'), isTrue);
    expect(repo.customCategories, isEmpty);
  });

  testWidgets('Свою категорию можно создать', (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Категории'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Добавить категорию'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Питомцы');
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();

    expect(repo.customCategories.single.name, 'Питомцы');
  });

  testWidgets('Поездку можно создать', (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Поездки'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Новая командировка'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Казань');
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();

    expect(repo.trips.single.name, 'Казань');
  });

  testWidgets('Расход можно изменить', (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);
    final now = DateTime.now();
    await tester.runAsync(
      () => repo.add(
        Expense(
          id: '1',
          amountKopecks: 246000,
          categoryName: 'Продукты',
          date: DateTime(now.year, now.month, 1),
          method: 'Карта',
          payee: 'ВкусВилл',
        ),
      ),
    );

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Расходы'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ВкусВилл'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();
    expect(find.text('Изменить расход'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '3000');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(repo.expenses.single.amountKopecks, 300000);
  });

  testWidgets('Расход можно открыть и удалить', (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);
    final now = DateTime.now();
    await tester.runAsync(
      () => repo.add(
        Expense(
          id: '1',
          amountKopecks: 246000,
          categoryName: 'Продукты',
          date: DateTime(now.year, now.month, 1),
          method: 'Карта',
          payee: 'ВкусВилл',
        ),
      ),
    );

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Расходы'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ВкусВилл'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить расход'), findsOneWidget);

    await tester.tap(find.text('Удалить расход'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить расход?'), findsOneWidget);

    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(repo.expenses, isEmpty);
  });

  test('короткое название месяца', () {
    expect(formatMonthShort(DateTime(2026, 10)), 'Окт');
    expect(formatMonthShort(DateTime(2026, 1)), 'Янв');
  });

  testWidgets('На обзоре есть диаграмма и столбики по месяцам', (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);
    final now = DateTime.now();
    await tester.runAsync(() async {
      await repo.add(
        Expense(
          id: '1',
          amountKopecks: 300000,
          categoryName: 'Продукты',
          date: DateTime(now.year, now.month, 1),
          method: 'Карта',
        ),
      );
      await repo.add(
        Expense(
          id: '2',
          amountKopecks: 100000,
          categoryName: 'Кафе',
          date: DateTime(now.year, now.month, 2),
          method: 'Карта',
        ),
      );
    });

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.byType(DonutChart), findsOneWidget);
    expect(find.text('категории'), findsOneWidget); // 2 категории в центре
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('По месяцам'), findsOneWidget);
    expect(find.byType(MonthBars), findsOneWidget);
  });

  test('фильтр расходов отбирает по всем условиям вместе', () {
    final lunch = Expense(
      id: '1',
      amountKopecks: 150000,
      categoryName: 'Кафе',
      date: DateTime(2026, 10, 10, 14, 30),
      method: 'Карта',
      tripId: 'kzn',
    );
    final taxi = Expense(
      id: '2',
      amountKopecks: 50000,
      categoryName: 'Транспорт',
      date: DateTime(2026, 10, 20),
      method: 'Наличные',
    );

    expect(ExpenseFilter.empty.isActive, isFalse);
    expect(ExpenseFilter.empty.matches(lunch), isTrue);

    expect(const ExpenseFilter(categories: {'Кафе'}).matches(lunch), isTrue);
    expect(const ExpenseFilter(categories: {'Кафе'}).matches(taxi), isFalse);

    // Границы дат включительно, время суток не мешает.
    final range = ExpenseFilter(
      from: DateTime(2026, 10, 10),
      to: DateTime(2026, 10, 10),
    );
    expect(range.matches(lunch), isTrue);
    expect(range.matches(taxi), isFalse);

    const greater = ExpenseFilter(amountKopecks: 100000);
    expect(greater.matches(lunch), isTrue);
    expect(greater.matches(taxi), isFalse);
    const less = ExpenseFilter(
      amountMode: AmountMode.less,
      amountKopecks: 100000,
    );
    expect(less.matches(lunch), isFalse);
    expect(less.matches(taxi), isTrue);

    expect(const ExpenseFilter(methods: {'Наличные'}).matches(taxi), isTrue);
    expect(const ExpenseFilter(tripId: 'kzn').matches(lunch), isTrue);
    expect(const ExpenseFilter(tripId: 'kzn').matches(taxi), isFalse);
    expect(const ExpenseFilter(tripId: kNoTripFilter).matches(taxi), isTrue);
    expect(const ExpenseFilter(tripId: kNoTripFilter).matches(lunch), isFalse);

    const combined = ExpenseFilter(
      categories: {'Кафе'},
      methods: {'Карта'},
      amountKopecks: 100000,
    );
    expect(combined.activeCount, 3);
    expect(combined.matches(lunch), isTrue);
    expect(combined.matches(taxi), isFalse);
  });

  testWidgets('Фильтр по категории скрывает лишние расходы', (tester) async {
    final repo = ExpenseRepository();
    await tester.runAsync(repo.load);
    final now = DateTime.now();
    await tester.runAsync(() async {
      await repo.add(
        Expense(
          id: '1',
          amountKopecks: 246000,
          categoryName: 'Продукты',
          date: DateTime(now.year, now.month, 1),
          method: 'Карта',
          payee: 'ВкусВилл',
        ),
      );
      await repo.add(
        Expense(
          id: '2',
          amountKopecks: 220000,
          categoryName: 'Кафе',
          date: DateTime(now.year, now.month, 2),
          method: 'Наличные',
          payee: 'Дом чая',
        ),
      );
    });

    await tester.pumpWidget(TratiApp(repository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Расходы'));
    await tester.pumpAndSettle();
    expect(find.text('ВкусВилл'), findsOneWidget);
    expect(find.text('Дом чая'), findsOneWidget);

    await tester.tap(find.text('Фильтры'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Кафе'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();

    expect(find.text('Фильтры · 1'), findsOneWidget);
    expect(find.text('ВкусВилл'), findsNothing);
    expect(find.text('Дом чая'), findsOneWidget);
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
