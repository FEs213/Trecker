import 'package:flutter_test/flutter_test.dart';
import 'package:trati/main.dart';

void main() {
  testWidgets('Приложение запускается и показывает вкладку «Обзор»',
      (tester) async {
    await tester.pumpWidget(const TratiApp());
    await tester.pumpAndSettle();

    expect(find.text('Траты'), findsWidgets);
    expect(find.text('Обзор'), findsWidgets);
  });
}
