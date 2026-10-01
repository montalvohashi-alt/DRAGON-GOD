import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/first_time_profile_setup_modal.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final posCtrl = TextEditingController(text: user.currentPosition);
    final compCtrl = TextEditingController(text: user.company);
    final locCtrl = TextEditingController(text: user.location);
    final bioCtrl = TextEditingController(text: user.bio);
    final skillsCtrl = TextEditingController(text: user.skills.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Edit Alumni Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textPrimaryColor),
        ),
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: posCtrl,
                decoration: const InputDecoration(labelText: 'Current Role / Job Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: compCtrl,
                decoration: const InputDecoration(labelText: 'Company / Employer'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'City / Location'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Professional Bio'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: skillsCtrl,
                decoration: const InputDecoration(labelText: 'Skills (comma separated)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textMutedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B181B),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final updated = user.copyWith(
                name: nameCtrl.text.trim(),
                currentPosition: posCtrl.text.trim(),
                company: compCtrl.text.trim(),
                location: locCtrl.text.trim(),
                bio: bioCtrl.text.trim(),
                skills: skillsCtrl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList(),
              );
              context.read<AlumniRepository>().updateCurrentUser(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Color(0xFF8B181B),
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = repo.currentUser;
    final isDark = themeProvider.isDarkMode;

    if (user == null) {
      return Scaffold(
        backgroundColor: context.canvasColor,
        body: const Center(child: Text('Please log in')),
      );
    }

    final isCompleted = user.isProfileSetupCompleted;
    final completionPercentage = isCompleted ? 100 : 75;

    return Scaffold(
      backgroundColor: context.canvasColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.name,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                                  ),
                                ),
                                if (user.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 16, color: Color(0xFF059669)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.headline ?? user.currentPosition ?? 'Alumni Member',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimaryColor.withOpacity(0.85)),
                            ),
                            Text(
                              '${user.company ?? "St. Cecilia's College"} • ${user.location ?? "Cebu City"}',
                              style: TextStyle(fontSize: 12, color: context.textMutedColor),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0x228B181B) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? const Color(0x448B181B) : const Color(0xFFFECACA)),
                              ),
                              child: Text(
                                user.role.displayName.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFB7185)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Quick Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(context, 'Connections', '${user.connections.length}'),
                      _buildStatColumn(context, 'Batch', user.batch ?? '2020'),
                      _buildStatColumn(context, 'Registrar', user.isVerified ? 'Verified' : 'Pending'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: context.borderColor),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text('Edit Profile', style: TextStyle(color: context.textPrimaryColor)),
                          onPressed: () => _showEditProfileDialog(context, user),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.auto_awesome, color: Color(0xFF8B181B), size: 18),
                        tooltip: 'Launch Setup Wizard',
                        onPressed: () => FirstTimeProfileSetupModal.show(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Completion Progress Indicator & Gate
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCompleted ? const Color(0xFF059669).withOpacity(0.4) : context.borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.pending_actions,
                            size: 16,
                            color: isCompleted ? const Color(0xFF059669) : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Profile Completion & Tracer Gate',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                          ),
                        ],
                      ),
                      Text(
                        '$completionPercentage%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100.0,
                      backgroundColor: isDark ? const Color(0xFF242220) : const Color(0xFFF3F4F6),
                      color: isCompleted ? const Color(0xFF059669) : const Color(0xFFD97706),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCompleted
                        ? 'Your alumni profile is 100% verified and active for global alumni networking and career opportunities.'
                        : 'Complete your graduate tracer details to unlock full career networking, mentor matching, and official event passes.',
                    style: TextStyle(fontSize: 11, color: context.textMutedColor, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? context.subsurfaceColor : const Color(0xFF8B181B),
                        foregroundColor: isCompleted ? context.textPrimaryColor : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: Icon(isCompleted ? Icons.refresh : Icons.auto_awesome, size: 15),
                      label: Text(
                        isCompleted ? 'Review / Update Tracer Info' : 'Complete Setup Wizard Now',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => FirstTimeProfileSetupModal.show(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Shared Dark Mode / Theme Settings Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF8B181B), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Appearance & Theme Mode',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                          ),
                        ],
                      ),
                      Switch(
                        value: isDark,
                        activeColor: const Color(0xFF8B181B),
                        onChanged: (_) => themeProvider.toggleTheme(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDark
                        ? 'Using shared dark mode palette: Charcoal (#121316), Stone-900 (#1C1917), and luminous crimson accents.'
                        : 'Using shared light mode palette: Soft white (#F9FAFB), crisp cards (#FFFFFF), and collegiate borders (#E5E7EB).',
                    style: TextStyle(fontSize: 11, color: context.textMutedColor, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Role Switcher for Testing (Alumni, Student, Faculty, Admin, Staff, Superadmin)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multi-Role System Switcher',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Switch roles to experience the portal as an Alumni, Student, Faculty, or Administrator:',
                    style: TextStyle(fontSize: 11, color: context.textMutedColor),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UserRole.values.map((role) {
                      final isSelected = user.role == role;
                      return ChoiceChip(
                        label: Text(role.displayName),
                        selected: isSelected,
                        selectedColor: const Color(0xFF8B181B),
                        backgroundColor: context.subsurfaceColor,
                        side: BorderSide(color: isSelected ? const Color(0xFF8B181B) : context.borderColor),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : context.textPrimaryColor,
                        ),
                        onSelected: (_) => repo.switchRole(role),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Academic & Professional Credentials Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Academic & Professional Records', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                      if (user.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x2210B981) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isDark ? const Color(0x4410B981) : const Color(0xFFA7F3D0)),
                          ),
                          child: const Text('VERIFIED RECORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(context, Icons.badge_outlined, 'Student / Registrar ID', user.studentId ?? 'SC-2020-0192'),
                  _buildDetailRow(context, Icons.work_outline, 'Employment Status', user.employmentStatus ?? 'Employed'),
                  _buildDetailRow(context, Icons.domain, 'Industry Sector', user.industry ?? 'Information Technology & Software'),
                  _buildDetailRow(context, Icons.school, 'Degree Program', user.course ?? 'BS Information Technology'),
                  _buildDetailRow(context, Icons.account_balance, 'Collegiate Department', user.department ?? 'College of Computer Studies'),
                  _buildDetailRow(context, Icons.calendar_today, 'Class Batch', user.batch ?? 'Class of 2020'),
                  if (user.website != null && user.website!.isNotEmpty)
                    _buildDetailRow(context, Icons.link, 'Portfolio / LinkedIn', user.website!),
                  if (user.phone != null) _buildDetailRow(context, Icons.phone, 'Contact Mobile', user.phone!),
                  _buildDetailRow(context, Icons.email_outlined, 'Institutional Email', user.email),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: context.textMutedColor)),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8B181B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 10, color: context.textMutedColor, fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.textPrimaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
