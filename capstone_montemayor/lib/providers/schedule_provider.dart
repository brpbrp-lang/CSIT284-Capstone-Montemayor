import 'dart:collection';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/class_session.dart';

class ScheduleProvider extends ChangeNotifier {
  final List<ClassSession> _classes = List.from(kDummySchedule);

  UnmodifiableListView<ClassSession> get classes => UnmodifiableListView(_classes);

  List<ClassSession> getClassesForDay(String day) {
    return _classes
        .where((c) => c.dayOfWeek.toLowerCase() == day.toLowerCase())
        .toList()
      ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));
  }

  void addClass(ClassSession session) {
    _classes.add(session);
    notifyListeners();
  }

  void updateClass(ClassSession updatedSession) {
    final index = _classes.indexWhere((c) => c.id == updatedSession.id);
    if (index != -1) {
      _classes[index] = updatedSession;
      notifyListeners();
    }
  }

  void deleteClass(String id) {
    _classes.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void resetToDefault() {
    _classes.clear();
    _classes.addAll(kDummySchedule);
    notifyListeners();
  }
}

/// An InheritedNotifier that allows any child widget to access the ScheduleProvider
class ScheduleScope extends InheritedNotifier<ScheduleProvider> {
  const ScheduleScope({
    super.key,
    required ScheduleProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ScheduleProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScheduleScope>();
    assert(scope != null, 'No ScheduleScope found in context');
    return scope!.notifier!;
  }
}
