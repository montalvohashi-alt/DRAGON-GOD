import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../services/fcm_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/notification_sheet.dart';
import 'feed_screen.dart';
import 'network_screen.dart';
import 'messages_screen.dart';
import 'events_screen.dart';
import 'opportunities_screen.dart';
import 'profile_screen.dart';
import 'announcements_screen.dart';

/// Dedicated Alumni Workspace Layout mirroring AlumniWorkspaceLayout.tsx
/// Manages tab and layout transitions for Alumni, Student, and Faculty roles.
class AlumniWorkspaceLayout extends StatelessWidget {
  const AlumniWorkspaceLayout({super.key});

  static const List<String> _tabKeys = [
    'dashboard',
    'network',
    'messages',
    'events',
    'opportunities',
    'profile',
  ];

  static const Map<String, String> _tabTitles = {
    'dashboard': 'Alumni News & Milestones',
    'network': 'Alumni Directory & Network',
    'messages': 'Direct Messages & Mentorship',
    'events': 'Campus Events & Reunions',
    'opportunities': 'Job Board & Careers',
    'profile': 'My Profile & Digital Card',
    'announcements': 'Official Circulars & Bulletins',
  };

  int _tabIndexFor(String tab) {
    final idx = _tabKeys.indexOf(tab);
    return idx >= 0 ? idx : 0;
  }

  Widget _buildBody(String activeTab) {
    switch (activeTab) {
      case 'network':
        return const NetworkScreen();
      case 'messages':
        return const MessagesScreen();
      case 'events':
        return const EventsScreen();
      case 'opportunities':
        return const OpportunitiesScreen();
      case 'profile':
        return const ProfileScreen();
      case 'announcements':
        return const AnnouncementsScreen();
      case 'dashboard':
      default:
        return const FeedScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final themeProvider = context.watch<ThemeProvider>();
    final fcmService = context.watch<FCMService>();
    final currentUser = repo.currentUser;
    final currentRole = currentUser?.role ?? UserRole.alumni;
    final isAdmin = isAdministrativeOrStaffRole(currentRole);
    final isDark = themeProvider.isDarkMode;

    final activeTab = repo.activeTab;
    final currentIndex = _tabIndexFor(activeTab);
    final totalUnreadMsgs = repo.chatThreads.fold<int>(0, (sum, t) => sum + t.unreadCount);

    return Scaffold(
      backgroundColor: themeProvider.canvasColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardColor,
        elevation: 0.5,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/cecilians-seal.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B181B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('SCC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cecilian Alumnet",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimaryColor,
                    ),
                  ),
                  Text(
                    _tabTitles[activeTab] ?? "St. Cecilia's College",
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

          // Admin Mode shortcut button (transitions directly into Admin Workspace)
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF8B181B)),
              tooltip: 'Switch to Admin Workspace',
              onPressed: () {
                repo.setActiveTab('dashboard');
              },
            ),

          // Live Role Switcher Popup Menu
          PopupMenuButton<UserRole>(
            tooltip: 'Switch Portal Role',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

      // Side Navigation Drawer
      drawer: Drawer(
        backgroundColor: themeProvider.cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF8B181B),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentUser?.name.substring(0, 1).toUpperCase() ?? 'S',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
                ),
              ),
              accountName: Text(
                currentUser?.name ?? 'Cecilian Alumnus',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              accountEmail: Text(
                '${currentUser?.role.displayName ?? "Alumni"} • ${currentUser?.email ?? ""}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dynamic_feed_outlined, color: Color(0xFF8B181B)),
              title: Text('News & Social Feed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'dashboard',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: Color(0xFF8B181B)),
              title: Text('Alumni Directory', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'network',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('network');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF8B181B)),
              title: Text('Direct Messages', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'messages',
              trailing: totalUnreadMsgs > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF8B181B), borderRadius: BorderRadius.circular(10)),
                      child: Text('$totalUnreadMsgs', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('messages');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_outlined, color: Color(0xFF8B181B)),
              title: Text('Events & Reunions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'events',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('events');
              },
            ),
            ListTile(
              leading: const Icon(Icons.work_outline, color: Color(0xFF8B181B)),
              title: Text('Career & Job Board', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'opportunities',
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('opportunities');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined, color: Color(0xFF8B181B)),
              title: Text('Official Circulars & Bulletins', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              selected: activeTab == 'announcements',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                child: Text('${repo.announcements.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
              ),
              onTap: () {
                Navigator.pop(context);
                repo.setActiveTab('announcements');
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
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF8B181B)),
              title: Text('Real-time FCM Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              trailing: fcmService.unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF8B181B), borderRadius: BorderRadius.circular(10)),
                      child: Text('${fcmService.unreadCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                NotificationSheet.show(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF8B181B)),
              title: Text('Dark Theme Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textPrimaryColor)),
              subtitle: Text(
                isDark ? 'Active (--background: #121316)' : 'Inactive (--background: #F9FAFB)',
                style: TextStyle(fontSize: 10, color: themeProvider.textMutedColor),
              ),
              trailing: Switch(
                value: isDark,
                activeColor: const Color(0xFF8B181B),
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            if (isAdmin) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.security, color: Color(0xFF8B181B)),
                title: const Text('Administrative Management', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
                subtitle: Text('Roster, Registry, Governance', style: TextStyle(fontSize: 10, color: themeProvider.textMutedColor)),
                onTap: () {
                  Navigator.pop(context);
                  repo.setActiveTab('dashboard');
                },
              ),
            ],
            const Divider(),
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
      body: _buildBody(activeTab),

      // 6-Tab Collegiate Bottom Navigation Bar
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
            if (index < _tabKeys.length) {
              repo.setActiveTab(_tabKeys[index]);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed_outlined),
              activeIcon: Icon(Icons.dynamic_feed),
              label: 'Feed',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: totalUnreadMsgs > 0
                  ? Badge(
                      label: Text('$totalUnreadMsgs'),
                      backgroundColor: const Color(0xFF8B181B),
                      child: const Icon(Icons.chat_bubble_outline),
                    )
                  : const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Careers',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
