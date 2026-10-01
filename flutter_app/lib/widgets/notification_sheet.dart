import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/fcm_service.dart';
import '../theme/theme_provider.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationSheet(),
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final fcmService = context.watch<FCMService>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final allNotifications = fcmService.notifications;
    final filteredNotifications = _selectedCategory == null
        ? allNotifications
        : allNotifications.where((n) => n.category == _selectedCategory).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: themeProvider.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B181B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active, color: Color(0xFF8B181B), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Alumni Notification Center',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textPrimaryColor,
                            ),
                          ),
                          if (fcmService.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B181B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${fcmService.unreadCount} new',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Real-time alerts for campus events, chats & registrar notices',
                        style: TextStyle(fontSize: 10, color: themeProvider.textMutedColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Real-Time FCM Test Triggers (For testing live pushes)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeProvider.subsurfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.event, size: 14),
                    label: const Text('Simulate Event Alert', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      fcmService.sendTestEventNotification();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B181B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 14),
                    label: const Text('Simulate Message', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      fcmService.sendTestMessageNotification();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All Alerts', null),
                const SizedBox(width: 6),
                _buildFilterChip('Event Updates', NotificationCategory.event),
                const SizedBox(width: 6),
                _buildFilterChip('Direct Messages', NotificationCategory.message),
                const SizedBox(width: 6),
                _buildFilterChip('Circulars', NotificationCategory.announcement),
              ],
            ),
          ),

          // Notification List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 40, color: themeProvider.textMutedColor.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('No notifications found in this category.', style: TextStyle(color: themeProvider.textMutedColor, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (ctx, idx) {
                      final notif = filteredNotifications[idx];
                      return _buildNotificationCard(context, notif, fcmService, themeProvider);
                    },
                  ),
          ),

          // Bottom Bar Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              border: Border(top: BorderSide(color: themeProvider.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Mark all as read', style: TextStyle(fontSize: 11)),
                  onPressed: fcmService.unreadCount > 0 ? () => fcmService.markAllAsRead() : null,
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Clear all', style: TextStyle(fontSize: 11)),
                  onPressed: allNotifications.isNotEmpty ? () => fcmService.clearAll() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory? category) {
    final themeProvider = context.watch<ThemeProvider>();
    final isSelected = _selectedCategory == category;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF8B181B),
      backgroundColor: themeProvider.subsurfaceColor,
      side: BorderSide(color: isSelected ? const Color(0xFF8B181B) : themeProvider.borderColor),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : themeProvider.textPrimaryColor,
      ),
      onSelected: (_) => setState(() => _selectedCategory = category),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notif,
    FCMService fcmService,
    ThemeProvider themeProvider,
  ) {
    Color badgeColor;
    IconData icon;

    switch (notif.category) {
      case NotificationCategory.event:
        badgeColor = const Color(0xFFD97706);
        icon = Icons.event_available;
        break;
      case NotificationCategory.message:
        badgeColor = const Color(0xFF8B181B);
        icon = Icons.chat_bubble_outline;
        break;
      case NotificationCategory.announcement:
        badgeColor = const Color(0xFF059669);
        icon = Icons.campaign_outlined;
        break;
      default:
        badgeColor = const Color(0xFF3B82F6);
        icon = Icons.notifications_active;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => fcmService.deleteNotification(notif.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: const Color(0xFFEF4444),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notif.isRead ? themeProvider.cardColor : badgeColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? themeProvider.borderColor : badgeColor.withOpacity(0.3),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: badgeColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notif.category.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(notif.timestamp),
                        style: TextStyle(fontSize: 10, color: themeProvider.textMutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                      color: themeProvider.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: notif.isRead ? themeProvider.textMutedColor : themeProvider.textPrimaryColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () => fcmService.markAsRead(notif.id),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
