import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_montemayor/main.dart';
import 'package:capstone_montemayor/models/class_session.dart';
import 'package:capstone_montemayor/models/user_profile.dart';
import 'package:capstone_montemayor/providers/auth_provider.dart';
import 'package:capstone_montemayor/providers/schedule_provider.dart';

void main() {
  testWidgets('App displays AuthScreen on launch and allows quick login', (WidgetTester tester) async {
    // Increase test surface size so entire auth card is visible
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const TimetableApp());

    // Verify AuthScreen elements appear on launch
    expect(find.text('BSIT 3-A Portal'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);

    // Tap Quick Login as Student
    final quickLoginFinder = find.text('Student: Juan Dela Cruz (BSIT 3-A)');
    await tester.ensureVisible(quickLoginFinder);
    await tester.tap(quickLoginFinder);
    await tester.pumpAndSettle();

    // Verify user entered the HomeShell with navigation
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Add Overload'), findsOneWidget);
  });

  test('AuthProvider handles login and logout correctly', () {
    final auth = AuthProvider();
    expect(auth.isAuthenticated, isFalse);

    auth.login(UserProfile.demoStudent);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.isStudent, isTrue);
    expect(auth.isTeacher, isFalse);

    auth.login(UserProfile.demoTeacher);
    expect(auth.isTeacher, isTrue);

    auth.logout();
    expect(auth.isAuthenticated, isFalse);
  });

  test('ScheduleProvider adds and manages overload classes', () {
    final provider = ScheduleProvider();
    final initialCount = provider.classes.length;

    const overloadClass = ClassSession(
      id: 'overload_101',
      courseCode: 'IT315',
      courseTitle: 'Cloud Computing (Overload)',
      dayOfWeek: 'Monday',
      startHour: 7,
      startMinute: 0,
      endHour: 8,
      endMinute: 30,
      room: 'Lab 101',
      instructor: 'Prof. Mendoza',
      isOverload: true,
    );

    provider.addClass(overloadClass);
    expect(provider.classes.length, initialCount + 1);
    final added = provider.classes.firstWhere((c) => c.id == 'overload_101');
    expect(added.isOverload, isTrue);

    provider.deleteClass('overload_101');
    expect(provider.classes.length, initialCount);
  });
}
