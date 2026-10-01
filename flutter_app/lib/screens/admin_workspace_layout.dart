import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../services/fcm_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/notification_sheet.dart';
import 'announcements_screen.dart';
import 'events_screen.dart';
import 'messages_screen.dart';
import 'opportunities_screen.dart';
import 'profile_screen.dart';

/// Dedicated Admin Workspace Layout mirroring AdminWorkspaceLayout.tsx
/// Manages tab and workspace transitions for Admin, Staff, Super Admin, and Employer roles.
class AdminWorkspaceLayout extends StatelessWidget {
  const AdminWorkspaceLayout({super.key});

  static const List<String> _adminTabKeys = [
    'dashboard',
    'users',
    'events',
    'opportunities',
    'announcements',
    'chapters',
  ];

  static const Map<String, String> _adminTabTitles = {
    'dashboard': 'Institutional Overview & KPIs',
    'users': 'Alumni Registry & Verification',
    'events': 'Events & Attendance Rosters',
    'opportunities': 'Job Postings & Employer Moderation',
    'announcements': 'Circulars & Official Bulletins',
    'chapters': 'Regional Chapters & Milestones',
    'messages': 'Direct Inquiries & Messages',
    'profile': 'Administrator Profile & Governance',
  };

  int _tabIndexFor(String tab) {
    if (tab == 'network' || tab == 'registry') return 1;
    final idx = _adminTabKeys.indexOf(tab);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final themeProvider = context.watch<ThemeProvider>();
    final fcmService = context.watch<FCMService>();
    final currentUser = repo.currentUser;
    final currentRole = currentUser?.role ?? UserRole.admin;
    final isDark = themeProvider.isDarkMode;

    final activeTab = repo.activeTab;
    final currentIndex = _tabIndexFor(activeTab);

    return Scaffold(
      backgroundColor: themeProvider.canvasColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardColor,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B181B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Cecilian Alumnet Admin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF8B181B).withOpacity(0.3)),
                        ),
                        child: Text(
                          currentRole.shortName.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF8B181B),
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _adminTabTitles[activeTab] ?? 'Administrative Controls',
                    style: TextStyle(
                      fontSize: 10,
                      color: themeProvider.textMutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Switch to Alumni View Action Button
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              foregroundColor: const Color(0xFF8B181B),
            ),
            icon: const Icon(Icons.school_outlined, size: 15),
            label: const Text('Alumni View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () {
              repo.switchRole(UserRole.alumni);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Switched to Alumni Member Portal view'),
                  backgroundColor: Color(0xFF8B181B),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          // Dynamic Theme Switcher Icon
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF4B5563),
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),

          // Real-time FCM Notification Center Action
          IconButton(
            icon: Badge(
              isLabelVisible: fcmService.unreadCount > 0,
              label: Text('${fcmService.unreadCount}'),
              backgroundColor: const Color(0xFF8B181B),
              child: const Icon(Icons.notifications_none, size: 22),
            ),
            tooltip: 'Alumni Notification Center (FCM)',
            onPressed: () => NotificationSheet.show(context),
          ),

          // Role Switcher Popup Menu
          PopupMenuButton<UserRole>(
            tooltip: 'Switch Admin / Staff Role',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242220) : const Color(0xFF8B181B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0x22FFFFFF) : const Color(0xFF8B181B).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, size: 14, color: Color(0xFF8B181B)),
                  const SizedBox(width: 4),
                  Text(
                    currentRole.shortName,
                    style: const TextStyle(
                      color: Color(0xFF8B181B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onSelected: (role) {
              repo.switchRole(role);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text('Switched view to ${role.displayName}'),
                  backgroundColor: const Color(0xFF8B181B),
                ),
              );
            },
            itemBuilder: (ctx) => UserRole.values.map((role) {
              return PopupMenuItem<UserRole>(
                value: role,
                child: Row(
                  children: [
                    Icon(
                      role == currentRole ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 16,
                      color: role == currentRole ? const Color(0xFF8B181B) : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 10),
                    Text(role.displayName, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // Side Navigation Drawer for Administrative Tools
      drawer: Drawer(
        backgroundColor: themeProvider.cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 18),
              color: const Color(0xFF8B181B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Color(0xFF8B181B), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Administrative Suite',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currentUser?.name ?? 'Director of Alumni Relations',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: Color(0xFF8B181B)),
              title: Text('Overview & Analytics', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'dashboard',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Color(0xFF8B181B)),
              title: Text('Member Registry & Verifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'users' || activeTab == 'network',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                child: Text('${repo.users.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
              ),
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined, color: Color(0xFF8B181B)),
              title: Text('Events & Attendance Rosters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'events',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('events');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center_outlined, color: Color(0xFF8B181B)),
              title: Text('Job Board & Employer Moderation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'opportunities',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('opportunities');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined, color: Color(0xFF8B181B)),
              title: Text('Circulars & Official Bulletins', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'announcements',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('announcements');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city_outlined, color: Color(0xFF8B181B)),
              title: Text('Regional Chapters & Milestones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'chapters',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('chapters');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF8B181B)),
              title: Text('Direct Communications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'messages',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('messages');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.school, color: Color(0xFF8B181B)),
              title: const Text('Switch to Alumni Member Portal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
              subtitle: Text('Preview directory and member feed', style: TextStyle(fontSize: 10, color: themeProvider.textMutedColor)),
              onTap: () {
                Navigator.pop(context);
                repo.switchRole(UserRole.alumni);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF8B181B)),
              title: Text('Campus Heritage Tour', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              onTap: () {
                Navigator.pop(context);
                repo.navigateToLanding();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF8B181B)),
              title: Text('Dark Theme Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              trailing: Switch(
                value: isDark,
                activeColor: const Color(0xFF8B181B),
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFDC2626)),
              title: const Text('Sign Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
              onTap: () {
                Navigator.pop(context);
                repo.logout();
              },
            ),
          ],
        ),
      ),

      // Screen Body
      body: _buildAdminBody(context, repo, themeProvider, activeTab),

      // Administrative Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          border: Border(top: BorderSide(color: themeProvider.borderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: isDark ? const Color(0xFFFB7185) : const Color(0xFF8B181B),
          unselectedItemColor: themeProvider.textMutedColor,
          backgroundColor: themeProvider.cardColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          onTap: (index) {
            if (index < _adminTabKeys.length) {
              repo.setActiveTab(_adminTabKeys[index]);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'KPIs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined),
              activeIcon: Icon(Icons.badge),
              label: 'Registry',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined),
              activeIcon: Icon(Icons.business_center),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Circulars',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_city_outlined),
              activeIcon: Icon(Icons.location_city),
              label: 'Chapters',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBody(BuildContext context, AlumniRepository repo, ThemeProvider themeProvider, String activeTab) {
    switch (activeTab) {
      case 'users':
      case 'network':
        return _buildRegistryView(context, repo, themeProvider);
      case 'events':
        return const EventsScreen();
      case 'opportunities':
        return const OpportunitiesScreen();
      case 'announcements':
        return const AnnouncementsScreen();
      case 'chapters':
        return _buildChaptersAndMilestonesView(context, repo, themeProvider);
      case 'messages':
        return const MessagesScreen();
      case 'profile':
        return const ProfileScreen();
      case 'dashboard':
      default:
        return _buildOverviewDashboard(context, repo, themeProvider);
    }
  }

  // 1. Institutional KPI & Analytics Dashboard
  Widget _buildOverviewDashboard(BuildContext context, AlumniRepository repo, ThemeProvider themeProvider) {
    final users = repo.users;
    final verifiedCount = users.where((u) => u.isVerified).length;
    final verifiedRate = users.isEmpty ? 100.0 : ((verifiedCount / users.length) * 100).toStringAsFixed(1);
    final totalRsvps = repo.events.fold<int>(0, (sum, e) => sum + e.rsvpCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Institutional Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B181B), Color(0xFF721316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified, color: Color(0xFFFCD34D), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'OFFICE OF ALUMNI & STUDENT AFFAIRS',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Global Alumni Governance & Executive Metrics',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time academic tracer synchronization, member registry compliance, and institutional event rosters.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 Metric KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  themeProvider,
                  'Total Cecilian Alumni',
                  '${users.length * 3420}',
                  Icons.people,
                  const Color(0xFF8B181B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  themeProvider,
                  'Registrar Verified',
                  '$verifiedRate%',
                  Icons.verified_user,
                  const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  themeProvider,
                  'Active Opportunities',
                  '${repo.opportunities.length}',
                  Icons.work_outline,
                  const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  themeProvider,
                  'Event RSVPs Reserved',
                  '$totalRsvps',
                  Icons.event,
                  const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Action Bar
          Text(
            'Executive Management Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: themeProvider.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 16, color: Color(0xFF8B181B)),
                  label: Text('Registry Roster', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
                  onPressed: () => repo.setActiveTab('users'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: themeProvider.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.post_add, size: 16, color: Color(0xFF8B181B)),
                  label: Text('Post Circular', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
                  onPressed: () => repo.setActiveTab('announcements'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Members Registry & Verification Module
  Widget _buildRegistryView(BuildContext context, AlumniRepository repo, ThemeProvider themeProvider) {
    final users = repo.users;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (ctx, idx) {
        final u = users[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                child: Text(
                  u.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeProvider.textPrimaryColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (u.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF059669), size: 14),
                        ],
                      ],
                    ),
                    Text('${u.role.displayName} • ${u.batch ?? "Batch"}', style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor)),
                    Text(u.email, style: TextStyle(fontSize: 10, color: themeProvider.textMutedColor.withOpacity(0.8))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    u.isVerified ? 'VERIFIED' : 'UNVERIFIED',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: u.isVerified ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                  Switch(
                    value: u.isVerified,
                    activeColor: const Color(0xFF059669),
                    onChanged: (_) => repo.toggleUserVerification(u.uid),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. Chapters & Milestones Module
  Widget _buildChaptersAndMilestonesView(BuildContext context, AlumniRepository repo, ThemeProvider themeProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Regional & Global Alumni Chapters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
        const SizedBox(height: 10),
        ...repo.chapters.map((ch) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ch.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeProvider.textPrimaryColor)),
                    Text('${ch.memberCount} Members', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Region: ${ch.region}', style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor)),
                Text('President: ${ch.president}', style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor)),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        Text('Distinguished Cecilian Milestones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
        const SizedBox(height: 10),
        ...repo.milestones.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.awardTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8B181B))),
                    Text(m.year, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFD97706))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${m.alumnusName} (${m.batch})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
                const SizedBox(height: 4),
                Text(m.citation, style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricCard(ThemeProvider themeProvider, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeProvider.textPrimaryColor)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: themeProvider.textMutedColor)),
        ],
      ),
    );
  }
}
