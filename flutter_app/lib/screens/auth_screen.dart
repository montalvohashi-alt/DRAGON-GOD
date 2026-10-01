import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../theme/theme_provider.dart';

/// Authentication Screen mirroring src/components/auth/AuthPage.tsx and App.tsx
/// Features state-driven login/registration toggling, role selection,
/// academic record verification checks, and post-login redirection to the portal dashboard.
class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;
  final VoidCallback? onBackToApp;

  const AuthScreen({
    super.key,
    this.onAuthenticated,
    this.onBackToApp,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Login Form
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController(text: 'maria.santos@techsolutions.com');
  final _loginPassCtrl = TextEditingController(text: 'password123');

  // Register Form
  final _regFormKey = GlobalKey<FormState>();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController(text: 'password123');
  final _regStudentIdCtrl = TextEditingController(text: 'SC-2024-0582');
  final _regBatchCtrl = TextEditingController(text: 'Class of 2024');
  final _regPositionCtrl = TextEditingController(text: 'Associate Software Engineer');
  final _regCompanyCtrl = TextEditingController(text: 'Accenture Philippines');

  String _regDepartment = 'College of Computer Studies';
  String _regCourse = 'BS Information Technology';

  final List<String> _departments = [
    'College of Computer Studies',
    'College of Engineering',
    'College of Business & Accountancy',
    'College of Education & Liberal Arts',
    'College of Nursing & Health Sciences',
    'Graduate Studies Institute',
  ];

  final List<String> _courses = [
    'BS Information Technology',
    'BS Computer Science',
    'BS Information Systems',
    'BS Civil Engineering',
    'BS Industrial Engineering',
    'BS Accountancy',
    'BS Business Administration',
    'BS Secondary Education',
    'BS Nursing',
  ];

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regStudentIdCtrl.dispose();
    _regBatchCtrl.dispose();
    _regPositionCtrl.dispose();
    _regCompanyCtrl.dispose();
    super.dispose();
  }

  void _handleBack(AlumniRepository repo) {
    if (widget.onBackToApp != null) {
      widget.onBackToApp!();
      return;
    }
    if (repo.currentUser != null) {
      repo.handleLoginSuccess(repo.currentUser!.role);
    } else {
      repo.navigateToLanding();
    }
  }

  void _handleLogin(AlumniRepository repo) {
    if (!_loginFormKey.currentState!.validate()) return;

    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();

    final error = repo.loginWithVerification(email, pass);
    if (error != null) {
      // Show Verification Alert matching App.tsx strict verification enforcement
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Verification Required', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            error,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, ${repo.currentUser?.name}! Directing to portal dashboard...'),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onAuthenticated?.call();
  }

  void _handleRegister(AlumniRepository repo) {
    if (!_regFormKey.currentState!.validate()) return;

    repo.registerUser(
      name: _regNameCtrl.text,
      email: _regEmailCtrl.text,
      role: repo.authRole,
      studentId: _regStudentIdCtrl.text,
      course: _regCourse,
      department: _regDepartment,
      batch: _regBatchCtrl.text,
      currentPosition: _regPositionCtrl.text,
      company: _regCompanyCtrl.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! Welcome to the Cecilian portal dashboard.'),
        backgroundColor: Color(0xFF059669),
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onAuthenticated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final repo = context.watch<AlumniRepository>();
    final isDark = themeProvider.isDarkMode;
    final isLogin = repo.authMode == AuthMode.login;

    return Scaffold(
      backgroundColor: themeProvider.canvasColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardColor,
        elevation: 0.5,
        title: const Text('Collegiate Portal Access', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Heritage',
          onPressed: () => _handleBack(repo),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleBack(repo),
            child: const Text('Campus Tour', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: themeProvider.cardColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: themeProvider.borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Institutional Header
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/cecilians-seal.jpg',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B181B),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('SCC', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "St. Cecilia's College - Cebu, Inc.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Global Alumni Network & Career Tracer Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                    ),
                    const SizedBox(height: 18),

                    // Login vs Register Segmented Control Toggle
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: themeProvider.subsurfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeProvider.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => repo.setAuthMode(AuthMode.login),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: isLogin ? const Color(0xFF8B181B) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isLogin ? Colors.white : themeProvider.textMutedColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => repo.setAuthMode(AuthMode.register),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: !isLogin ? const Color(0xFF8B181B) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Register Account',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: !isLogin ? Colors.white : themeProvider.textMutedColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Animated view transition between Login and Register forms
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isLogin
                          ? _buildSignInView(context, themeProvider, repo)
                          : _buildRegisterView(context, themeProvider, repo),
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

  // 1. Sign In Form
  Widget _buildSignInView(BuildContext context, ThemeProvider themeProvider, AlumniRepository repo) {
    return Column(
      key: const ValueKey('signin-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Institutional Email Address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _loginEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, size: 16),
                  hintText: 'maria.santos@techsolutions.com',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
              ),
              const SizedBox(height: 12),

              Text('Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _loginPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, size: 16),
                  hintText: '••••••••',
                ),
                validator: (v) => (v == null || v.trim().length < 6) ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B181B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('ENTER PORTAL DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _handleLogin(repo),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Toggle to Register mode prompt
        Center(
          child: TextButton(
            onPressed: () => repo.setAuthMode(AuthMode.register),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                children: const [
                  TextSpan(text: 'Don\'t have an alumni account? '),
                  TextSpan(
                    text: 'Register Here',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Quick 1-Tap Demo Credentials Section
        const Divider(),
        const SizedBox(height: 8),
        Text('Quick 1-Tap Demo Accounts:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textMutedColor)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildDemoChip('Maria (Alumni)', () {
              _loginEmailCtrl.text = 'maria.santos@techsolutions.com';
              _handleLogin(repo);
            }),
            _buildDemoChip('Hon. Cecilia (Admin)', () {
              _loginEmailCtrl.text = 'alumni.director@stcecilia.edu';
              _handleLogin(repo);
            }),
            _buildDemoChip('Joshua (Student)', () {
              _loginEmailCtrl.text = 'joshua.ramos@stcecilia.edu';
              _handleLogin(repo);
            }),
            _buildDemoChip('Dr. Fernando (Faculty)', () {
              _loginEmailCtrl.text = 'fernando.gomez@stcecilia.edu';
              _handleLogin(repo);
            }),
            _buildDemoChip('Apex (Employer)', () {
              _loginEmailCtrl.text = 'careers@apexsolutions.ph';
              _handleLogin(repo);
            }),
          ],
        ),
      ],
    );
  }

  // 2. Register Form
  Widget _buildRegisterView(BuildContext context, ThemeProvider themeProvider, AlumniRepository repo) {
    return Form(
      key: _regFormKey,
      child: Column(
        key: const ValueKey('register-form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Selection Toggle
          Text('Account Type / Affiliation *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Alumni Member', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  selected: repo.authRole == UserRole.alumni,
                  selectedColor: const Color(0xFF8B181B).withOpacity(0.15),
                  onSelected: (sel) {
                    if (sel) repo.setAuthRole(UserRole.alumni);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Corporate Partner', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  selected: repo.authRole == UserRole.employer,
                  selectedColor: const Color(0xFF8B181B).withOpacity(0.15),
                  onSelected: (sel) {
                    if (sel) repo.setAuthRole(UserRole.employer);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text('Full Legal Name *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _regNameCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline, size: 16),
              hintText: 'e.g. Christine Joyce Mendoza',
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Full Name is required' : null,
          ),
          const SizedBox(height: 10),

          Text('Email Address *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined, size: 16),
              hintText: 'christine.mendoza@gmail.com',
            ),
            validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
          ),
          const SizedBox(height: 10),

          Text('Student / Registrar ID (SC-YYYY-XXXX) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _regStudentIdCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.badge_outlined, size: 16),
              hintText: 'SC-2024-0582',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Student ID is required';
              if (!RegExp(r'^SC-\d{4}-\d{3,5}$', caseSensitive: false).hasMatch(v.trim())) {
                return 'Format must match: SC-YYYY-XXXX';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          Text('Collegiate Department *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _regDepartment,
            dropdownColor: themeProvider.cardColor,
            items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 11)))).toList(),
            onChanged: (v) => setState(() => _regDepartment = v!),
          ),
          const SizedBox(height: 10),

          Text('Degree Program *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _regCourse,
            dropdownColor: themeProvider.cardColor,
            items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11)))).toList(),
            onChanged: (v) => setState(() => _regCourse = v!),
          ),
          const SizedBox(height: 10),

          Text('Graduation Batch *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _regBatchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today, size: 16),
              hintText: 'Class of 2024',
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Batch is required' : null,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B181B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.verified_user_outlined, size: 18),
              label: const Text('REGISTER & ACCESS DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => _handleRegister(repo),
            ),
          ),
          const SizedBox(height: 12),

          // Toggle back to login
          Center(
            child: TextButton(
              onPressed: () => repo.setAuthMode(AuthMode.login),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                  children: const [
                    TextSpan(text: 'Already verified with an account? '),
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String label, VoidCallback onTap) {
    final themeProvider = context.watch<ThemeProvider>();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: themeProvider.subsurfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
        ),
      ),
    );
  }
}
