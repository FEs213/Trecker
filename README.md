# Траты — тема Red Velvet

Flutter-проект учёта личных расходов в стиле Aurora OS UI Kit (Red Velvet, Dark).

## Первый запуск

В архиве нет служебных папок платформ (`android/`, `web/` и т.д.), их создаёт Flutter.
Откройте терминал в папке проекта и выполните:

```
flutter create . --project-name trati --org com.example --platforms=android,web
flutter pub get
flutter run
```

Затем откройте папку в Android Studio и выберите эмулятор или Chrome.
Свои файлы в `lib/` команда `flutter create .` не перезаписывает.

## Структура

```
lib/
  main.dart               точка входа, MaterialApp, русская локаль
  app_shell.dart          нижняя навигация, 4 вкладки
  theme/
    app_colors.dart       палитра Red Velvet из спецификации
    app_text.dart         текстовые стили
    app_theme.dart        ThemeData (кнопки, навигация, шторки, диалоги)
  widgets/                общие компоненты
    velvet_background     градиентный фон
    velvet_page           каркас экрана с заголовком и нижней кнопкой
    primary_button        розовая / красная / приглушённая кнопка
    velvet_text_field     поле ввода с подписью
    velvet_choice_chip    «таблетка» выбора
    velvet_card           карточка
    expense_tile          строка расхода
  screens/                экраны (Обзор, Расходы, Поездки, Категории, Новый расход)
  data/demo_data.dart     демо-данные из макета
  core/format.dart        форматирование сумм и дат
assets/images/background.png   обои Red Velvet
```

## Что сделано / что дальше

Сделано: тема, компоненты, навигация, 4 вкладки с демо-данными, рабочая форма «Новый расход».
Дальше: кольцевая диаграмма, детали / редактирование / удаление расхода, фильтры,
импорт CSV, свои категории, командировки, хранилище данных.
