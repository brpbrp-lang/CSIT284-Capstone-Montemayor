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
      title: 'Timetable: BSIT 3-A Schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5), // Indigo Accent
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      builder: (context, child) => PhoneFrame(child: child!),
      home: const HomeShell(),
    );
  }
}

/// Wraps the application in an iOS/Android phone mockup frame when viewed on Web or Desktop
class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Scaffold(
            backgroundColor: const Color(0xFF0B0F19),
            body: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 880,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: const Color(0xFF1E293B), width: 8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 32,
                      offset: Offset(0, 14),
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
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      kSectionName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Class Schedule',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
            ),
            body: screens[_selectedIndex],
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => AddEditClassSheet.show(context),
              tooltip: 'Add Subject',
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_task_rounded, size: 19),
              label: const Text('Add Subject', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              height: 64,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today_rounded),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_view_week_outlined),
                  selectedIcon: Icon(Icons.calendar_view_week_rounded),
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
