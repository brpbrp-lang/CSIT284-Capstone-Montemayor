enum UserRole {
  student,
  teacher,
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String idNumber; // Student ID or Faculty ID
  final String section;  // e.g. "BSIT 3-A"
  final UserRole role;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.idNumber,
    required this.section,
    required this.role,
  });

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;

  // Preset demo accounts for quick testing and panel defense
  static const UserProfile demoStudent = UserProfile(
    id: 'std_01',
    name: 'Juan Dela Cruz',
    email: 'jdelacruz.student@university.edu.ph',
    idNumber: '2024-03120',
    section: 'BSIT 3-A',
    role: UserRole.student,
  );

  static const UserProfile demoTeacher = UserProfile(
    id: 'tch_01',
    name: 'Prof. Santos',
    email: 'msantos.faculty@university.edu.ph',
    idNumber: 'FAC-9921',
    section: 'BSIT 3-A',
    role: UserRole.teacher,
  );
}
