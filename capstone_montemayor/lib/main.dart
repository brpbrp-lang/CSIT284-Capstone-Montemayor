import 'package:flutter/material.dart';
import 'data/dummy_data.dart';
import 'providers/auth_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/today_screen.dart';
import 'screens/weekly_screen.dart';
import 'widgets/add_edit_class_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimetableApp());
}

class TimetableApp extends StatefulWidget {
  const TimetableApp({super.key});

  @override
  State<TimetableApp> createState() => _TimetableAppState();
}

class _TimetableAppState extends State<TimetableApp> {
  final AuthProvider _authProvider = AuthProvider();

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: _authProvider,
      child: MaterialApp(
        title: 'BSIT 3-A Portal',
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
        home: const RootGate(),
      ),
    );
  }
}

/// Gate that routes to AuthScreen or HomeShell based on authentication status
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }
    return const HomeShell();
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of the portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthScope.of(context).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.currentUser;
    final isStudent = auth.isStudent;

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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$kSectionName Timetable',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    user != null
                        ? '${user.isStudent ? "Student" : "Faculty"}: ${user.name}'
                        : kSectionName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Sign Out',
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
            body: screens[_selectedIndex],
            // Only students can add overload units to their section schedule
            floatingActionButton: isStudent
                ? FloatingActionButton.extended(
                    onPressed: () => AddEditClassSheet.show(context),
                    tooltip: 'Add Overload Subject',
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add Overload'),
                  )
                : null,
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
