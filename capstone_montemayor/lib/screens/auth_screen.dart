import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.student;

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _applyPresetForRole(_selectedRole);
  }

  void _applyPresetForRole(UserRole role) {
    if (role == UserRole.student) {
      _idController.text = '2024-03120';
      _nameController.text = 'Juan Dela Cruz';
    } else {
      _idController.text = 'FAC-9921';
      _nameController.text = 'Prof. Santos';
    }
    _passwordController.text = 'password123';
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.of(context);
    final user = UserProfile(
      id: _selectedRole == UserRole.student ? 'std_01' : 'tch_01',
      name: _nameController.text.trim(),
      email: '${_idController.text.trim().toLowerCase()}@university.edu.ph',
      idNumber: _idController.text.trim(),
      section: 'BSIT 3-A',
      role: _selectedRole,
    );

    auth.login(user);
  }

  void _quickLogin(UserProfile preset) {
    AuthScope.of(context).login(preset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo & Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BSIT 3-A Portal',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Official Section Timetable & Overload Manager',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role Selector
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.student,
                          label: Text('Student'),
                          icon: Icon(Icons.school_outlined),
                        ),
                        ButtonSegment(
                          value: UserRole.teacher,
                          label: Text('Teacher'),
                          icon: Icon(Icons.person_outline),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                          _applyPresetForRole(_selectedRole);
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == UserRole.student
                            ? 'Student Full Name'
                            : 'Faculty Full Name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    // ID Field
                    TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == UserRole.student
                            ? 'Student ID (e.g. 2024-03120)'
                            : 'Faculty ID (e.g. FAC-9921)',
                        prefixIcon: const Icon(Icons.fingerprint),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (v) =>
                          v == null || v.length < 6 ? 'Minimum 6 chars' : null,
                    ),
                    const SizedBox(height: 20),

                    // Sign In Button
                    FilledButton(
                      onPressed: _submitLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _selectedRole == UserRole.student
                            ? 'Enter as Student'
                            : 'Enter as Teacher',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Demo Section for Presentations/Defense
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Quick Demo Login',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _quickLogin(UserProfile.demoStudent),
                      icon: const Icon(Icons.person, size: 18),
                      label: const Text('Student: Juan Dela Cruz (BSIT 3-A)'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _quickLogin(UserProfile.demoTeacher),
                      icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                      label: const Text('Teacher: Prof. Santos (BSIT 3-A)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
