class ClassSession {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String dayOfWeek; // "Monday" .. "Sunday"
  final int startHour;    // 24-hour format (e.g., 13 = 1:00 PM)
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String room;
  final String instructor;
  final bool isOverload;    // True if student added an overload/extra subject
  final String? statusNote; // Teacher announcements (e.g. room change, online)

  const ClassSession({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.dayOfWeek,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.room,
    required this.instructor,
    this.isOverload = false,
    this.statusNote,
  });

  /// Formats 24-hour ints into readable time like "9:00 AM - 10:30 AM"
  String get formattedTime {
    String fmt(int h, int m) {
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      final minStr = m.toString().padLeft(2, '0');
      return '$hour12:$minStr $period';
    }

    return '${fmt(startHour, startMinute)} - ${fmt(endHour, endMinute)}';
  }

  /// Helper values used for sorting classes and checking if a class is "Ongoing"
  int get startTotalMinutes => startHour * 60 + startMinute;
  int get endTotalMinutes => endHour * 60 + endMinute;

  ClassSession copyWith({
    String? id,
    String? courseCode,
    String? courseTitle,
    String? dayOfWeek,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? room,
    String? instructor,
    bool? isOverload,
    String? statusNote,
  }) {
    return ClassSession(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      room: room ?? this.room,
      instructor: instructor ?? this.instructor,
      isOverload: isOverload ?? this.isOverload,
      statusNote: statusNote ?? this.statusNote,
    );
  }

  /// Converts a Firestore document into a ClassSession object
  factory ClassSession.fromMap(String id, Map<String, dynamic> map) {
    return ClassSession(
      id: id,
      courseCode: map['courseCode'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? 'Monday',
      startHour: (map['startHour'] as num?)?.toInt() ?? 8,
      startMinute: (map['startMinute'] as num?)?.toInt() ?? 0,
      endHour: (map['endHour'] as num?)?.toInt() ?? 9,
      endMinute: (map['endMinute'] as num?)?.toInt() ?? 0,
      room: map['room'] ?? 'TBA',
      instructor: map['instructor'] ?? 'TBA',
      isOverload: map['isOverload'] ?? false,
      statusNote: map['statusNote'],
    );
  }

  /// Converts a ClassSession object into a Map for Firestore upload
  Map<String, dynamic> toMap() => {
        'courseCode': courseCode,
        'courseTitle': courseTitle,
        'dayOfWeek': dayOfWeek,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'room': room,
        'instructor': instructor,
        'isOverload': isOverload,
        if (statusNote != null) 'statusNote': statusNote,
      };
}
