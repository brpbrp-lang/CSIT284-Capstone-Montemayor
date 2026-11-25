import 'dart:convert';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data/dummy_data.dart';
import 'models/class_session.dart';
import 'screens/today_screen.dart';
import 'screens/weekly_screen.dart';
import 'services/notification_service.dart';
import 'theme/subject_colors.dart';

const String kFirebaseDbHost =
    'capstone-montemayor-default-rtdb.asia-southeast1.firebasedatabase.app';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await NotificationService.instance
      .scheduleWeeklyClassReminders(kDummySchedule);

  // Show the iPhone 15 Pro frame on Web/Desktop, or launch full-screen on mobile
 final bool usePhoneFrame = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  runApp(usePhoneFrame ? const PhonePreview() : const TimetableApp());

}

class PhonePreview extends StatelessWidget {
  const PhonePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$kSectionName Timetable Preview',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 31),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DeviceFrame(
              device: Devices.ios.iPhone15Pro,
              isFrameVisible: true,
              orientation: Orientation.portrait,
              screen: const TimetableApp(),
            ),
          ),
        ),
      ),
    );
  }
}

class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$kSectionName Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppPalette.electricBlue,
        scaffoldBackgroundColor: AppPalette.bgDark,
      ),
      home: const HomeShell(),
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
  List<ClassSession> _classes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final url = Uri.https(kFirebaseDbHost, 'schedule.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch schedule. Please try again later.';
          _isLoading = false;
        });
        return;
      }

      // Firebase returns 'null' when the node is empty
      if (response.body == 'null') {
        await _seedScheduleToFirebase();
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<ClassSession> loadedClasses = [];

      for (final item in listData.entries) {
        loadedClasses.add(
          ClassSession.fromMap(item.key, item.value as Map<String, dynamic>),
        );
      }

      setState(() {
        _classes = loadedClasses;
        _isLoading = false;
      });

      await NotificationService.instance
          .scheduleWeeklyClassReminders(loadedClasses);
    } catch (err) {
      // Fallback to local dummy data if offline while keeping error clear
      setState(() {
        _classes = kDummySchedule;
        _isLoading = false;
      });
    }
  }

  Future<void> _seedScheduleToFirebase() async {
    final url = Uri.https(kFirebaseDbHost, 'schedule.json');
    final Map<String, dynamic> seedMap = {
      for (final session in kDummySchedule) session.id: session.toMap(),
    };

    await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(seedMap),
    );

    setState(() {
      _classes = kDummySchedule;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: AppPalette.electricBlue),
      );
    } else if (_error != null) {
      bodyContent = Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppPalette.inkMuted),
        ),
      );
    } else {
      final screens = [
        TodayScreen(allClasses: _classes),
        WeeklyScreen(allClasses: _classes),
      ];
      bodyContent = IndexedStack(
        index: _selectedIndex,
        children: screens,
      );
    }

    return Scaffold(
      extendBody: true,
      body: bodyContent,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(56, 0, 56, 16),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppPalette.cardDark,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppPalette.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _FloatingNavItem(
                  icon: Icons.home_rounded,
                  label: 'Today',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FloatingNavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Schedule',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected ? AppPalette.electricBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.65),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}