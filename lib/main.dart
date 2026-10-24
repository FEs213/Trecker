import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_shell.dart';
import 'data/expense_repository.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/velvet_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.navBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final repository = ExpenseRepository();
  await repository.load();

  runApp(TratiApp(repository: repository));
}

class TratiApp extends StatelessWidget {
  const TratiApp({super.key, required this.repository});

  final ExpenseRepository repository;

  @override
  Widget build(BuildContext context) {
    return ExpenseScope(
      repository: repository,
      child: MaterialApp(
        title: 'Trecker',
        debugShowCheckedModeBanner: false,
        theme: buildVelvetTheme(),
        themeMode: ThemeMode.dark,
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) =>
            VelvetBackground(child: child ?? const SizedBox.shrink()),
        home: const AppShell(),
      ),
    );
  }
}
