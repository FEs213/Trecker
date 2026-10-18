import 'package:flutter/material.dart';

import 'screens/categories_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/trips_screen.dart';

/// Главный каркас: четыре вкладки с нижней навигацией.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = <Widget>[
    OverviewScreen(),
    ExpensesScreen(),
    TripsScreen(),
    CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Обзор',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Расходы',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Поездки',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Категории',
          ),
        ],
      ),
    );
  }
}
