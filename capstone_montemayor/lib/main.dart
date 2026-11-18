import 'package:flutter/material.dart';
import 'data/dummy_data.dart';
import 'providers/schedule_provider.dart';
import 'screens/today_screen.dart';
import 'screens/weekly_screen.dart';
import 'widgets/add_edit_class_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimetableApp());
}

class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSIT284 Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      builder: (context, child) => PhoneFrame(child: child!),
      home: const HomeShell(),
    );
  }
}

/// Wraps the application in a phone-sized mockup frame when viewed on Web or Desktop
class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Only wrap in phone frame on wider screens (Web / Desktop)
        if (constraints.maxWidth > 500) {
          return Scaffold(
            backgroundColor: const Color(0xFF1E1E24),
            body: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 880,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: const Color(0xFF2C2C35), width: 8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  final ScheduleProvider _scheduleProvider = ScheduleProvider();

  @override
  void dispose() {
    _scheduleProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const screens = [
      TodayScreen(),
      WeeklyScreen(),
    ];

    return ScheduleScope(
      notifier: _scheduleProvider,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('$kSectionName Schedule'),
              centerTitle: false,
            ),
            body: screens[_selectedIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () => AddEditClassSheet.show(context),
              tooltip: 'Add Class',
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_view_week_outlined),
                  selectedIcon: Icon(Icons.calendar_view_week),
                  label: 'Weekly',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
