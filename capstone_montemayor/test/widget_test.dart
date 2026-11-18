import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_montemayor/main.dart';
import 'package:capstone_montemayor/models/class_session.dart';
import 'package:capstone_montemayor/providers/schedule_provider.dart';

void main() {
  testWidgets('App loads and displays Today and Weekly navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const TimetableApp());

    // Verify navigation bar destinations exist
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
  });

  test('ScheduleProvider adds, updates, and deletes classes correctly', () {
    final provider = ScheduleProvider();
    final initialCount = provider.classes.length;

    const newClass = ClassSession(
      id: 'test_101',
      courseCode: 'TEST101',
      courseTitle: 'Introduction to Testing',
      dayOfWeek: 'Monday',
      startHour: 8,
      startMinute: 0,
      endHour: 9,
      endMinute: 30,
      room: 'Test Lab',
      instructor: 'Dr. Test',
    );

    // Add
    provider.addClass(newClass);
    expect(provider.classes.length, initialCount + 1);
    expect(provider.classes.any((c) => c.id == 'test_101'), isTrue);

    // Update
    const updatedClass = ClassSession(
      id: 'test_101',
      courseCode: 'TEST101',
      courseTitle: 'Advanced Testing',
      dayOfWeek: 'Monday',
      startHour: 8,
      startMinute: 0,
      endHour: 9,
      endMinute: 30,
      room: 'Test Lab 2',
      instructor: 'Dr. Test',
    );
    provider.updateClass(updatedClass);
    final found = provider.classes.firstWhere((c) => c.id == 'test_101');
    expect(found.courseTitle, 'Advanced Testing');
    expect(found.room, 'Test Lab 2');

    // Delete
    provider.deleteClass('test_101');
    expect(provider.classes.length, initialCount);
    expect(provider.classes.any((c) => c.id == 'test_101'), isFalse);
  });
}
