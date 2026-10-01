import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Firebase Cloud Messaging (FCM) Service for St. Cecilia's College Global Alumni Portal
/// Manages real-time push notifications for Event Updates, Direct Messages, and Circulars,
/// mirroring the web portal's notification center and browser push infrastructure.
class FCMService extends ChangeNotifier {
  // FCM Configuration matching firebase-applet-config.json
  static const String fcmProjectId = 'gen-lang-client-0379037546';
  static const String fcmSenderId = '954422776214';
  static const String fcmAppId = '1:954422776214:web:183e42f053667221174db7';

  // Subscribed Topics
  final Set<String> _subscribedTopics = {'events', 'messages', 'announcements'};

  // State
  String? _fcmToken;
  bool _isInitialized = false;
  bool _permissionGranted = true;

  final List<NotificationModel> _notifications = [];
  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  // Getters
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  bool get permissionGranted => _permissionGranted;
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  Stream<NotificationModel> get onNotificationReceived => _notificationStreamController.stream;
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  bool isSubscribedTo(String topic) => _subscribedTopics.contains(topic);

  void subscribeToTopic(String topic) {
    if (_subscribedTopics.add(topic)) {
      notifyListeners();
    }
  }

  void unsubscribeFromTopic(String topic) {
    if (_subscribedTopics.remove(topic)) {
      notifyListeners();
    }
  }

  // Global key to display collegiate banner toasts from any foreground push
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  FCMService() {
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Generate deterministic device registration token
    _fcmToken = 'fcm_token_cecilian_${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    _isInitialized = true;

    // Seed realistic initial notifications matching web portal events & chats
    _seedInitialNotifications();
    notifyListeners();
  }

  void _seedInitialNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: 'notif-1',
        title: 'Grand Alumni Homecoming 2026 Update',
        body: 'Venue finalized: St. Cecilia’s Jubilee Diamond Pavilion. Digital QR Admission Passes are now active.',
        category: NotificationCategory.event,
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        isRead: false,
        data: {'eventId': 'event-1'},
      ),
      NotificationModel(
        id: 'notif-2',
        title: 'Direct Message from Dr. Vicente Alcantara',
        body: 'Dr. Vicente sent: "Warm greetings! We would love to feature your software architecture journey in our CS symposium."',
        category: NotificationCategory.message,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        data: {'threadId': 'thread-2'},
      ),
      NotificationModel(
        id: 'notif-3',
        title: 'Office of the College Registrar Notice',
        body: 'Official Memo: Annual verification window for 2026 Board of Trustees elections is now open.',
        category: NotificationCategory.announcement,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ]);
  }

  /// Dispatches an incoming FCM notification payload to the app in real time
  void dispatchNotification({
    required String title,
    required String body,
    required NotificationCategory category,
    Map<String, dynamic> data = const {},
  }) {
    final notif = NotificationModel(
      id: 'fcm-msg-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      category: category,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
    );

    _notifications.insert(0, notif);
    _notificationStreamController.add(notif);
    notifyListeners();

    // Trigger foreground in-app collegiate notification banner
    _showForegroundNotificationBanner(notif);
  }

  /// Displays foreground notification banner matching collegiate styling
  void _showForegroundNotificationBanner(NotificationModel notif) {
    final state = messengerKey.currentState;
    if (state == null) return;

    Color badgeColor;
    IconData icon;

    switch (notif.category) {
      case NotificationCategory.event:
        badgeColor = const Color(0xFFD97706); // Warm Amber
        icon = Icons.event_available;
        break;
      case NotificationCategory.message:
        badgeColor = const Color(0xFF8B181B); // Brand Crimson
        icon = Icons.chat_bubble_outline;
        break;
      case NotificationCategory.announcement:
        badgeColor = const Color(0xFF059669); // Emerald
        icon = Icons.campaign_outlined;
        break;
      case NotificationCategory.career:
        badgeColor = const Color(0xFF2563EB); // Royal Blue
        icon = Icons.work_outline;
        break;
      case NotificationCategory.system:
        badgeColor = const Color(0xFF4B5563); // Stone Gray
        icon = Icons.notifications_active_outlined;
        break;
    }

    state.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF1C1917), // Stone-900 surface
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: badgeColor.withOpacity(0.5), width: 1.5),
        ),
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: badgeColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      const Text(
                        'JUST NOW',
                        style: TextStyle(fontSize: 8, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action: Simulate Event Update Notification
  void sendTestEventNotification({String? eventTitle}) {
    final title = eventTitle ?? 'Grand Alumni Homecoming 2026';
    dispatchNotification(
      title: '$title Update',
      body: 'Check-in pass verified! Early gate opening begins at 4:30 PM. Please present your Digital QR Code.',
      category: NotificationCategory.event,
      data: {'type': 'event_reminder', 'eventId': 'event-1'},
    );
  }

  // Quick Action: Simulate Incoming Direct Message Notification
  void sendTestMessageNotification({String? senderName, String? messageText}) {
    final sender = senderName ?? 'Engr. Roberto Cruz';
    final text = messageText ?? 'Hello! We reviewed your application for the Tech Lead position at Archipelagic Systems.';
    dispatchNotification(
      title: 'New message from $sender',
      body: text,
      category: NotificationCategory.message,
      data: {'type': 'chat_message', 'sender': sender},
    );
  }

  // Mark single notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Delete notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationStreamController.close();
    super.dispose();
  }
}
