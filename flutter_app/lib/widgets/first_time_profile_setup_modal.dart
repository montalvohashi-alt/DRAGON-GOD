import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../theme/theme_provider.dart';

/// Modal for first-time profile completion and academic record verification
/// Uses Flutter Form validation matching the web portal's profile completion gate.
class FirstTimeProfileSetupModal extends StatefulWidget {
  final VoidCallback? onCompleted;
  final VoidCallback? onSkipped;

  const FirstTimeProfileSetupModal({
    super.key,
    this.onCompleted,
    this.onSkipped,
  });

  /// Static helper to display the modal
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const FirstTimeProfileSetupModal(),
    );
  }

  @override
  State<FirstTimeProfileSetupModal> createState() => _FirstTimeProfileSetupModalState();
}

class _FirstTimeProfileSetupModalState extends State<FirstTimeProfileSetupModal> {
  final _formKey = GlobalKey<FormState>();

  static const List<String> _industries = [
    'Information Technology & Software',
    'Education & Academic Research',
    'Healthcare, Medical & Nursing',
    'Engineering & Construction',
    'Banking, Finance & Insurance',
    'Business Process Outsourcing (BPO)',
    'Government & Public Administration',
    'Hospitality, Culinary & Tourism',
    'Media, Arts & Creative Design',
    'Manufacturing & Logistics',
    'Legal & Professional Services',
    'Non-Profit & Community Development',
    'Other Professional Field',
  ];

  static const List<String> _employmentStatuses = [
    'Employed',
    'Self-employed',
    'Unemployed',
    'Student',
    'Retired',
  ];

  late String _employmentStatus;
  late String _selectedIndustry;
  late TextEditingController _positionCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _headlineCtrl;
  late TextEditingController _skillsCtrl;
  late TextEditingController _studentIdCtrl;
  late TextEditingController _websiteCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final repo = context.read<AlumniRepository>();
    final user = repo.currentUser;

    _employmentStatus = user?.employmentStatus ?? 'Employed';
    _selectedIndustry = user?.industry ?? 'Information Technology & Software';
    _positionCtrl = TextEditingController(text: user?.currentPosition ?? '');
    _companyCtrl = TextEditingController(text: user?.company ?? '');
    _locationCtrl = TextEditingController(text: user?.location ?? 'Cebu City, Philippines');
    _headlineCtrl = TextEditingController(
      text: user?.headline ?? (user?.course != null ? '${user!.course} Graduate' : 'Cecilian Alumnus'),
    );
    _skillsCtrl = TextEditingController(
      text: (user?.skills != null && user!.skills.isNotEmpty)
          ? user.skills.join(', ')
          : 'Leadership, Communication, Problem Solving',
    );
    _studentIdCtrl = TextEditingController(text: user?.studentId ?? 'SC-2020-0192');
    _websiteCtrl = TextEditingController(text: user?.website ?? '');
  }

  @override
  void dispose() {
    _positionCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _headlineCtrl.dispose();
    _skillsCtrl.dispose();
    _studentIdCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  void _handleSaveAndComplete() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = context.read<AlumniRepository>();
    final user = repo.currentUser;

    if (user == null) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      return;
    }

    final parsedSkills = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final generatedHeadline = _headlineCtrl.text.trim().isNotEmpty
        ? _headlineCtrl.text.trim()
        : '${_positionCtrl.text.trim()} at ${_companyCtrl.text.trim()}';

    final updated = user.copyWith(
      employmentStatus: _employmentStatus,
      currentPosition: _positionCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      industry: _selectedIndustry,
      location: _locationCtrl.text.trim(),
      headline: generatedHeadline,
      skills: parsedSkills.isNotEmpty ? parsedSkills : ['Leadership', 'Teamwork'],
      studentId: _studentIdCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      isProfileSetupCompleted: true,
      isVerified: true, // Academic record confirmed
    );

    repo.updateCurrentUser(updated);

    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Your alumni profile is now active and published!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF059669), // Emerald
        duration: Duration(seconds: 4),
      ),
    );

    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final repo = context.watch<AlumniRepository>();
    final user = repo.currentUser;
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeProvider.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Collegiate Crimson Accent Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B181B), Color(0xFF721316), Color(0xFF550C0F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome, color: Color(0xFFFDE68A), size: 24),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome, ${user?.name ?? "Alumnus"}!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Please complete your professional details. This data enables alumni career networking, mentor matching, and official graduate tracer records.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        tooltip: 'Skip for now',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSkipped?.call();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Form Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employment Status
                        _buildSectionLabel(context, 'CURRENT EMPLOYMENT STATUS', isRequired: true),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _employmentStatuses.map((st) {
                            final isSelected = _employmentStatus == st;
                            return ChoiceChip(
                              label: Text(st == 'Unemployed' ? 'Seeking Opportunities' : st),
                              selected: isSelected,
                              selectedColor: const Color(0xFF8B181B),
                              backgroundColor: themeProvider.subsurfaceColor,
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF8B181B) : themeProvider.borderColor,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : themeProvider.textPrimaryColor,
                              ),
                              onSelected: (_) => setState(() => _employmentStatus = st),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Job Title & Company in two-column row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(context, 'JOB TITLE / POSITION', isRequired: true),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _positionCtrl,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.work_outline, size: 16, color: themeProvider.textMutedColor),
                                      hintText: 'e.g., Lead Cloud Engineer',
                                      hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Job title is required';
                                      }
                                      if (val.trim().length < 2) {
                                        return 'Minimum 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(context, 'COMPANY / EMPLOYER', isRequired: true),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _companyCtrl,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.business_outlined, size: 16, color: themeProvider.textMutedColor),
                                      hintText: 'e.g., Apex Cloud Systems',
                                      hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Company is required';
                                      }
                                      if (val.trim().length < 2) {
                                        return 'Minimum 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Industry Sector Dropdown
                        _buildSectionLabel(context, 'INDUSTRY SECTOR', isRequired: true),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedIndustry,
                          dropdownColor: themeProvider.cardColor,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.domain, size: 16),
                          ),
                          items: _industries.map((ind) {
                            return DropdownMenuItem<String>(
                              value: ind,
                              child: Text(
                                ind,
                                style: TextStyle(fontSize: 12, color: themeProvider.textPrimaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedIndustry = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Work Location & Student ID row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(context, 'WORK LOCATION / CITY'),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _locationCtrl,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.location_on_outlined, size: 16, color: themeProvider.textMutedColor),
                                      hintText: 'Cebu City or Remote',
                                      hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(context, 'STUDENT / REGISTRAR ID', isRequired: true),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _studentIdCtrl,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF8B181B)),
                                      hintText: 'SC-2020-0192',
                                      hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Student ID is required';
                                      }
                                      // Validate against registrar format SC-YYYY-XXXX
                                      final reg = RegExp(r'^SC-\d{4}-\d{3,5}$', caseSensitive: false);
                                      if (!reg.hasMatch(val.trim())) {
                                        return 'Format: SC-YYYY-XXXX';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Professional Headline / Tagline
                        _buildSectionLabel(context, 'PROFESSIONAL HEADLINE'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _headlineCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g., Senior Cloud Engineer @ Apex | SCC Batch 2020',
                            hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Key Skills & Specializations
                        _buildSectionLabel(context, 'KEY SKILLS & SPECIALIZATIONS (COMMA-SEPARATED)', isRequired: true),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _skillsCtrl,
                          decoration: InputDecoration(
                            hintText: 'Flutter, TypeScript, Cloud Architecture, Project Management',
                            hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please list at least 1 skill';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // LinkedIn Profile or Website URL
                        _buildSectionLabel(context, 'LINKEDIN PROFILE OR PORTFOLIO URL (OPTIONAL)'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _websiteCtrl,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.link, size: 16, color: themeProvider.textMutedColor),
                            hintText: 'https://linkedin.com/in/yourname',
                            hintStyle: TextStyle(fontSize: 11, color: themeProvider.textMutedColor),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (!val.contains('.') || val.trim().length < 4) {
                                return 'Please enter a valid URL';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Data Privacy Notice
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x2210B981) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0x4410B981) : const Color(0xFFA7F3D0),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF059669)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your professional data is safeguarded under the Philippine Data Privacy Act of 2012 and Institutional Zero Disclosure policy. You can update these details anytime in your Profile tab.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1.4,
                                    color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: themeProvider.cardColor,
                  border: Border(top: BorderSide(color: themeProvider.borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: themeProvider.borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onSkipped?.call();
                        },
                        child: Text(
                          'Skip For Now',
                          style: TextStyle(color: themeProvider.textMutedColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B181B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle, size: 18),
                        label: Text(
                          _isSubmitting ? 'SAVING...' : 'SAVE & COMPLETE SETUP',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                        ),
                        onPressed: _isSubmitting ? null : _handleSaveAndComplete,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title, {bool isRequired = false}) {
    final themeProvider = context.watch<ThemeProvider>();
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: themeProvider.textPrimaryColor.withOpacity(0.85),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
