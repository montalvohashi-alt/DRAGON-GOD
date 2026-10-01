import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/alumni_repository.dart';
import '../theme/app_theme.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final announcements = repo.announcements;
    final currentUser = repo.currentUser;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        title: Text(
          'Official Circulars & Bulletins',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
        ),
        backgroundColor: context.surfaceColor,
        elevation: 0.5,
      ),
      body: announcements.isEmpty
          ? Center(
              child: Text('No active circulars at this time.', style: TextStyle(color: context.textMutedColor)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (ctx, idx) {
                final ann = announcements[idx];
                final isHearted = currentUser != null && ann.hearts.contains(currentUser.uid);
                final isAcked = currentUser != null && ann.acknowledgedByUids.contains(currentUser.uid);
                final isUrgent = ann.priority == 'urgent';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUrgent
                          ? (isDark ? const Color(0x44E11D48) : const Color(0xFFFECACA))
                          : context.borderColor,
                      width: isUrgent ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUrgent
                            ? const Color(0xFF8B181B).withOpacity(0.08)
                            : Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header badge strip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? (isDark ? const Color(0x28E11D48) : const Color(0xFFFEF2F2))
                              : context.subsurfaceColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          border: Border(
                            bottom: BorderSide(
                              color: isUrgent
                                  ? (isDark ? const Color(0x44E11D48) : const Color(0xFFFEE2E2))
                                  : context.borderColor,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isUrgent ? Icons.campaign : Icons.article_outlined,
                                  size: 16,
                                  color: isUrgent ? const Color(0xFFFB7185) : context.textMutedColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isUrgent ? 'URGENT CIRCULAR' : ann.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isUrgent ? const Color(0xFFFB7185) : context.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('MMM d, y').format(ann.publishedAt),
                              style: TextStyle(fontSize: 10, color: context.textMutedColor),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ann.title,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ann.content,
                              style: TextStyle(fontSize: 12, height: 1.45, color: context.textPrimaryColor.withOpacity(0.85)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.school, size: 13, color: Color(0xFF8B181B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ann.authorName,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.textMutedColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Actions Bar: Acknowledge & Heart
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isAcked
                                          ? (isDark ? const Color(0x2210B981) : const Color(0xFFECFDF5))
                                          : context.surfaceColor,
                                      side: BorderSide(
                                        color: isAcked ? const Color(0xFF10B981) : context.borderColor,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    icon: Icon(
                                      isAcked ? Icons.check_circle : Icons.check_circle_outline,
                                      size: 15,
                                      color: isAcked ? const Color(0xFF059669) : context.textPrimaryColor,
                                    ),
                                    label: Text(
                                      isAcked ? 'Acknowledged' : 'Acknowledge Circular',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isAcked ? const Color(0xFF059669) : context.textPrimaryColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      repo.acknowledgeAnnouncement(ann.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text('Circular acknowledged.'),
                                          backgroundColor: Color(0xFF059669),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => repo.toggleHeartAnnouncement(ann.id),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isHearted
                                          ? (isDark ? const Color(0x33E11D48) : const Color(0xFFFFF1F2))
                                          : context.subsurfaceColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isHearted ? const Color(0xFFFDA4AF) : context.borderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isHearted ? Icons.favorite : Icons.favorite_border,
                                          size: 15,
                                          color: isHearted ? const Color(0xFFE11D48) : context.textMutedColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${ann.hearts.length}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isHearted ? const Color(0xFFE11D48) : context.textPrimaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
