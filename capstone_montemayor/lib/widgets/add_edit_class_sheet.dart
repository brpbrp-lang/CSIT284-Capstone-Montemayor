import 'package:flutter/material.dart';
import '../models/class_session.dart';
import '../providers/schedule_provider.dart';

class AddEditClassSheet extends StatefulWidget {
  final ClassSession? existingSession;

  const AddEditClassSheet({super.key, this.existingSession});

  static Future<void> show(BuildContext context, {ClassSession? session}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ScheduleScope(
        notifier: ScheduleScope.of(context),
        child: AddEditClassSheet(existingSession: session),
      ),
    );
  }

  @override
  State<AddEditClassSheet> createState() => _AddEditClassSheetState();
}

class _AddEditClassSheetState extends State<AddEditClassSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _roomController;
  late TextEditingController _instructorController;

  late String _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existingSession;
    _codeController = TextEditingController(text: s?.courseCode ?? '');
    _titleController = TextEditingController(text: s?.courseTitle ?? '');
    _roomController = TextEditingController(text: s?.room ?? '');
    _instructorController = TextEditingController(text: s?.instructor ?? '');

    _selectedDay = s?.dayOfWeek ?? 'Monday';
    _startTime = s != null
        ? TimeOfDay(hour: s.startHour, minute: s.startMinute)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = s != null
        ? TimeOfDay(hour: s.endHour, minute: s.endMinute)
        : const TimeOfDay(hour: 10, minute: 30);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _roomController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final period = tod.period == DayPeriod.pm ? 'PM' : 'AM';
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final min = tod.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = ScheduleScope.of(context);
    final isEditing = widget.existingSession != null;

    final session = ClassSession(
      id: isEditing
          ? widget.existingSession!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      courseCode: _codeController.text.trim().toUpperCase(),
      courseTitle: _titleController.text.trim(),
      dayOfWeek: _selectedDay,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
      room: _roomController.text.trim(),
      instructor: _instructorController.text.trim(),
    );

    if (isEditing) {
      provider.updateClass(session);
    } else {
      provider.addClass(session);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Class updated!' : 'Class added to schedule!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSession != null;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Class' : 'Add New Class',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Course Code & Day of Week
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Course Code *',
                        hintText: 'e.g. CSIT284',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _days
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDay = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Course Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title *',
                  hintText: 'e.g. Mobile Application Development',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Time Pickers Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time, size: 20),
                          isDense: true,
                        ),
                        child: Text(_formatTimeOfDay(_startTime)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time_filled, size: 20),
                          isDense: true,
                        ),
                        child: Text(_formatTimeOfDay(_endTime)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Room & Instructor
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(
                        labelText: 'Room / Venue *',
                        hintText: 'e.g. Lab 302',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _instructorController,
                      decoration: const InputDecoration(
                        labelText: 'Instructor *',
                        hintText: 'e.g. Prof. Santos',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Changes' : 'Add Class'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
