import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../services/fcm_service.dart';
import '../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _filter = 'all'; // 'all', 'upcoming', 'rsvp'

  void _showPassDialog(BuildContext context, EventModel evt) {
    final repo = context.read<AlumniRepository>();
    final user = repo.currentUser;
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ticket Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B181B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'OFFICIAL DIGITAL PASS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                evt.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textPrimaryColor),
              ),
              const SizedBox(height: 6),
              Text(
                '${DateFormat('EEEE, MMMM d, y').format(evt.startDate)} • ${DateFormat('h:mm a').format(evt.startDate)}',
                style: TextStyle(fontSize: 12, color: context.textMutedColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Mock QR Code Box
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242220) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 100, color: context.textPrimaryColor),
                    Text(
                      'PASS #${evt.id.toUpperCase()}',
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Attendee info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x228B181B) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0x448B181B) : const Color(0xFFFECACA)),
                ),
                child: Column(
                  children: [
                    Text(
                      user?.name ?? 'Verified Cecilian Attendee',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFB7185)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user?.course ?? "Alumni"} • ${user?.batch ?? "Class of 2020"}',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: context.borderColor),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Close', style: TextStyle(color: context.textPrimaryColor)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final currentUser = repo.currentUser;
    final allEvents = repo.events;

    final filteredEvents = allEvents.where((e) {
      if (_filter == 'rsvp') return e.isReservedByMe;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.canvasColor,
      body: CustomScrollView(
        slivers: [
          // Filter Row
          SliverToBoxAdapter(
            child: Container(
              color: context.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All Events (${allEvents.length})'),
                    selected: _filter == 'all',
                    selectedColor: const Color(0xFF8B181B),
                    backgroundColor: context.subsurfaceColor,
                    side: BorderSide(color: _filter == 'all' ? const Color(0xFF8B181B) : context.borderColor),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _filter == 'all' ? Colors.white : context.textPrimaryColor,
                    ),
                    onSelected: (_) => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('My Registered Passes (${allEvents.where((e) => e.isReservedByMe).length})'),
                    selected: _filter == 'rsvp',
                    selectedColor: const Color(0xFF8B181B),
                    backgroundColor: context.subsurfaceColor,
                    side: BorderSide(color: _filter == 'rsvp' ? const Color(0xFF8B181B) : context.borderColor),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _filter == 'rsvp' ? Colors.white : context.textPrimaryColor,
                    ),
                    onSelected: (_) => setState(() => _filter = 'rsvp'),
                  ),
                ],
              ),
            ),
          ),

          // Events list
          if (filteredEvents.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No events found in this view.', style: TextStyle(color: context.textMutedColor)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, idx) {
                    final evt = filteredEvents[idx];
                    final isHearted = currentUser != null && evt.hearts.contains(currentUser.uid);

                    return _buildEventCard(context, evt, isHearted);
                  },
                  childCount: filteredEvents.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel evt, bool isHearted) {
    final repo = context.read<AlumniRepository>();
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: evt.isReservedByMe ? const Color(0xFF8B181B).withOpacity(0.5) : context.borderColor,
          width: evt.isReservedByMe ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image if available
          if (evt.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.asset(
                  evt.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: const Color(0xFF8B181B),
                    child: const Center(child: Icon(Icons.event, color: Colors.white24, size: 40)),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Date Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x33B45309) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        evt.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(
                          '${evt.rsvpCount} Registered',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  evt.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                ),
                const SizedBox(height: 6),

                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF8B181B)),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEE, MMM d, y • h:mm a').format(evt.startDate),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimaryColor.withOpacity(0.9)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: context.textMutedColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        evt.location,
                        style: TextStyle(fontSize: 11, color: context.textMutedColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  evt.description,
                  style: TextStyle(fontSize: 12, height: 1.4, color: context.textPrimaryColor.withOpacity(0.85)),
                ),
                const SizedBox(height: 12),

                // Actions: RSVP, View Pass, Heart
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: evt.isReservedByMe ? const Color(0xFF059669) : const Color(0xFF8B181B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: Icon(evt.isReservedByMe ? Icons.check_circle_outline : Icons.bookmark_add_outlined, size: 16),
                        label: Text(
                          evt.isReservedByMe ? 'Pass Reserved (Attending)' : 'RSVP Attendance',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final wasReserved = evt.isReservedByMe;
                          repo.toggleRsvpEvent(evt.id);
                          if (!wasReserved) {
                            context.read<FCMService>().dispatchNotification(
                              title: '${evt.title} RSVP Confirmed',
                              body: 'Your admission pass and Digital QR Code have been issued. Early check-in opens 1 hour before start time.',
                              category: NotificationCategory.event,
                              data: {'eventId': evt.id},
                            );
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(wasReserved ? 'Cancelled attendance for ${evt.title}' : 'Reserved ticket for ${evt.title}!'),
                              backgroundColor: const Color(0xFF8B181B),
                            ),
                          );
                        },
                      ),
                    ),
                    if (evt.isReservedByMe) ...[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.qr_code, size: 18),
                        tooltip: 'View Admission QR Pass',
                        onPressed: () => _showPassDialog(context, evt),
                      ),
                    ],
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isHearted ? Icons.favorite : Icons.favorite_border,
                        color: isHearted ? const Color(0xFFE11D48) : context.textMutedColor,
                        size: 20,
                      ),
                      tooltip: 'Interested',
                      onPressed: () => repo.toggleHeartEvent(evt.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
