import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:capstone_montemayor/data/dummy_data.dart';
import 'package:capstone_montemayor/main.dart';
import 'package:capstone_montemayor/models/class_session.dart';
import 'package:capstone_montemayor/screens/today_screen.dart';
import 'package:capstone_montemayor/screens/weekly_screen.dart';

void main() {
  testWidgets(
    'TimetableApp displays BSIT 3 - G1 navigation and switches to Schedule',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const TimetableApp(
          initialClasses: kDummySchedule,
          enableNotifications: false,
        ),
      );
      await tester.pump();

      expect(find.text('BSIT 3 - G1'), findsWidgets);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Schedule'), findsWidgets);

      await tester.tap(find.text('Schedule').last);
      await tester.pumpAndSettle();

      expect(find.text('Weekly Overview'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeShell seeds Firebase when schedule node is null',
    (WidgetTester tester) async {
      var putCalled = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response('null', 200);
        }
        if (request.method == 'PUT') {
          putCalled = true;
          final body = json.decode(request.body) as Map<String, dynamic>;
          expect(body.length, kDummySchedule.length);
          return http.Response(request.body, 200);
        }
        return http.Response('Method not allowed', 405);
      });

      await tester.pumpWidget(
        TimetableApp(
          httpClient: mockClient,
          enableNotifications: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(putCalled, isTrue);
      expect(find.text('Daily Goal'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeShell shows retry and offline fallback on HTTP error',
    (WidgetTester tester) async {
      final mockClient = MockClient(
        (_) async => http.Response('Server Error', 500),
      );

      await tester.pumpWidget(
        TimetableApp(
          httpClient: mockClient,
          enableNotifications: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Use Offline Schedule'), findsOneWidget);

      await tester.tap(find.text('Use Offline Schedule'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Goal'), findsOneWidget);
    },
  );

  testWidgets(
    'TodayScreen tracks live ongoing class, end-minute transition, and search',
    (WidgetTester tester) async {
      // Monday, Nov 23, 2026 at 11:00 AM (during CSIT321 10:30 AM - 1:30 PM)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayScreen(
              allClasses: kDummySchedule,
              nowProvider: () => DateTime(2026, 11, 23, 11, 0),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Remaining · CSIT321'), findsOneWidget);
      expect(find.text('ONGOING'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);

      // Search filters to RIZAL031
      await tester.enterText(find.byType(TextField), 'Rizal');
      await tester.pump();

      expect(find.text('Life and Works of Rizal'), findsOneWidget);
      expect(find.text('Application Development'), findsNothing);

      // At exact end minute (1:30 PM), CSIT321 should be DONE, focus moves to RIZAL031
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodayScreen(
              allClasses: kDummySchedule,
              nowProvider: () => DateTime(2026, 11, 23, 13, 30),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Starts in · RIZAL031'), findsOneWidget);
    },
  );

  testWidgets(
    'WeeklyScreen filters classes case-insensitively and omits cls counts',
    (WidgetTester tester) async {
      const lowercaseDayClasses = [
        ClassSession(
          id: 'mon_lower',
          courseCode: 'CSIT321',
          courseTitle: 'Application Development',
          dayOfWeek: 'monday',
          startHour: 10,
          startMinute: 30,
          endHour: 12,
          endMinute: 0,
          room: 'NGE204',
          instructor: 'CIT-U Faculty',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyScreen(
              allClasses: lowercaseDayClasses,
              nowProvider: () => DateTime(2026, 11, 23, 9, 0), // Monday
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Application Development'), findsOneWidget);
      expect(find.text('1h 30m'), findsOneWidget);
      expect(find.textContaining('cls'), findsNothing);
      expect(find.text('1 class'), findsNothing);
    },
  );

  test('ClassSession serializes to/from Map and formats 12-hour time', () {
    const session = ClassSession(
      id: 'test_1',
      courseCode: 'IT317',
      courseTitle: 'Project Management',
      dayOfWeek: 'Tuesday',
      startHour: 13,
      startMinute: 0,
      endHour: 15,
      endMinute: 5,
      room: 'GLE202',
      instructor: 'CIT-U Faculty',
    );

    expect(session.formattedTime, '1:00 PM - 3:05 PM');
    final roundTrip = ClassSession.fromMap('test_1', session.toMap());
    expect(roundTrip.courseCode, 'IT317');
    expect(roundTrip.startTotalMinutes, 780);
    expect(roundTrip.endTotalMinutes, 905);
  });

  testWidgets(
    'TodayScreen and WeeklyScreen render without overflow on 320px width',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const TimetableApp(
          initialClasses: kDummySchedule,
          enableNotifications: false,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Schedule').last);
      await tester.pumpAndSettle();

      expect(find.text('Weekly Overview'), findsOneWidget);
    },
  );
}
