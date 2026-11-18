import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_montemayor/main.dart';
import 'package:capstone_montemayor/models/class_session.dart';
import 'package:capstone_montemayor/providers/schedule_provider.dart';

void main() {
  testWidgets('TimetableApp launches directly into schedule with navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const TimetableApp());
    await tester.pumpAndSettle();

    // Verify app opens directly into timetable
    expect(find.text('BSIT 3-A'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Add Subject'), findsOneWidget);
  });

  test('ScheduleProvider adds, updates, and manages overload classes', () {
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
