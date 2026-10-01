import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../services/fcm_service.dart';
import '../theme/app_theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _searchQuery = '';
  final TextEditingController _msgInputCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgInputCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openChatThread(BuildContext context, ChatThreadModel thread) {
    final repo = context.read<AlumniRepository>();
    final isDark = context.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final liveThread = context.watch<AlumniRepository>().chatThreads.firstWhere(
            (t) => t.id == thread.id,
            orElse: () => thread,
          );
          final currentUid = repo.currentUser?.uid ?? '';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Chat Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      border: Border(bottom: BorderSide(color: context.borderColor)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                          child: Text(
                            liveThread.participantName.substring(0, 1).toUpperCase(),
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
                                  Text(
                                    liveThread.participantName,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 14, color: Color(0xFF059669)),
                                ],
                              ),
                              Text(
                                '${liveThread.participantRole} • Active Now',
                                style: TextStyle(fontSize: 10, color: context.textMutedColor),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.textMutedColor),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Messages Bubble List
                  Expanded(
                    child: liveThread.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 40, color: context.textMutedColor.withOpacity(0.5)),
                                const SizedBox(height: 8),
                                Text(
                                  'Send a message to start conversation with ${liveThread.participantName}',
                                  style: TextStyle(color: context.textMutedColor, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            itemCount: liveThread.messages.length,
                            itemBuilder: (ctx, idx) {
                              final msg = liveThread.messages[idx];
                              final isMe = msg.senderUid == currentUid;

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.76,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? const Color(0xFF8B181B) : context.subsurfaceColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 16),
                                    ),
                                    border: isMe ? null : Border.all(color: context.borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.35,
                                          color: isMe ? Colors.white : context.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('h:mm a').format(msg.timestamp),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isMe ? Colors.white70 : context.textMutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Input Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      border: Border(top: BorderSide(color: context.borderColor)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgInputCtrl,
                            decoration: InputDecoration(
                              hintText: 'Type a message to ${liveThread.participantName}...',
                              hintStyle: TextStyle(fontSize: 12, color: context.textMutedColor),
                              filled: true,
                              fillColor: context.subsurfaceColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF8B181B)),
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: () {
                            if (_msgInputCtrl.text.trim().isEmpty) return;
                            final sentText = _msgInputCtrl.text.trim();
                            repo.sendMessage(liveThread.id, sentText);
                            _msgInputCtrl.clear();
                            setSheetState(() {});
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                              }
                            });

                            // Simulate real-time FCM incoming message notification
                            Future.delayed(const Duration(seconds: 2), () {
                              if (context.mounted) {
                                context.read<FCMService>().dispatchNotification(
                                  title: 'Reply from ${liveThread.participantName}',
                                  body: 'Got your message: "$sentText". Looking forward to collaborating!',
                                  category: NotificationCategory.message,
                                  data: {'threadId': liveThread.id},
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNewMessageModal(BuildContext context) {
    final repo = context.read<AlumniRepository>();
    final otherUsers = repo.users.where((u) => u.uid != repo.currentUser?.uid).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
            const SizedBox(height: 6),
            Text('Choose an alumnus, student, or faculty member to message:', style: TextStyle(fontSize: 11, color: context.textMutedColor)),
            const SizedBox(height: 14),
            SizedBox(
              height: 240,
              child: ListView.builder(
                itemCount: otherUsers.length,
                itemBuilder: (ctx, idx) {
                  final u = otherUsers[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                      child: Text(u.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
                    ),
                    title: Text(u.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    subtitle: Text('${u.role.displayName} • ${u.batch ?? "Batch"}', style: TextStyle(fontSize: 11, color: context.textMutedColor)),
                    onTap: () {
                      Navigator.pop(ctx);
                      final thread = repo.getOrCreateThread(u);
                      _openChatThread(context, thread);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final threads = repo.chatThreads;
    final isDark = context.isDarkMode;

    final filteredThreads = threads.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.participantName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: context.canvasColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B181B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note, size: 20),
        label: const Text('New Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        onPressed: () => _showNewMessageModal(context),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: context.surfaceColor,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 18, color: context.textMutedColor),
                hintText: 'Search chats or Cecilian graduates...',
                hintStyle: TextStyle(fontSize: 12, color: context.textMutedColor),
                filled: true,
                fillColor: context.subsurfaceColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
              ),
            ),
          ),

          // Conversation List
          Expanded(
            child: filteredThreads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_chat_unread_outlined, size: 48, color: context.textMutedColor.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        Text('No active conversations found.', style: TextStyle(color: context.textMutedColor)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredThreads.length,
                    itemBuilder: (ctx, idx) {
                      final t = filteredThreads[idx];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                                child: Text(
                                  t.participantName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B181B)),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF059669),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: context.surfaceColor, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  t.participantName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                DateFormat('h:mm a').format(t.lastMessageTime),
                                style: TextStyle(fontSize: 10, color: context.textMutedColor),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                t.participantRole,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF8B181B)),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.lastMessage,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: t.unreadCount > 0 ? context.textPrimaryColor : context.textMutedColor,
                                        fontWeight: t.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (t.unreadCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF8B181B),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${t.unreadCount}',
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _openChatThread(context, t),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
