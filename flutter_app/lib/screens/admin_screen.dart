import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/alumni_repository.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final users = repo.users;
    final opportunities = repo.opportunities;
    final events = repo.events;
    final chapters = repo.chapters;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        title: Text(
          'Admin Management Workspace',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
        ),
        backgroundColor: context.surfaceColor,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? const Color(0xFFFB7185) : const Color(0xFF8B181B),
          unselectedLabelColor: context.textMutedColor,
          indicatorColor: isDark ? const Color(0xFFFB7185) : const Color(0xFF8B181B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'Registry'),
            Tab(text: 'Metrics'),
            Tab(text: 'Chapters'),
            Tab(text: 'Milestones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Members Registry & Verification
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (ctx, idx) {
              final u = users[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
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
                          Text(u.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor)),
                          Text('${u.role.displayName} • ${u.batch ?? "Batch"}', style: TextStyle(fontSize: 11, color: context.textMutedColor)),
                          Text(u.email, style: TextStyle(fontSize: 10, color: context.textMutedColor.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    Switch(
                      value: u.isVerified,
                      activeColor: const Color(0xFF059669),
                      onChanged: (_) => repo.toggleUserVerification(u.uid),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Metrics & Analytics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institutional Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard(context, 'Total Alumni', '${users.length * 3420}', Icons.people, const Color(0xFF8B181B))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard(context, 'Verified Rate', '94.8%', Icons.verified_user, const Color(0xFF059669))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard(context, 'Active Jobs', '${opportunities.length}', Icons.work, const Color(0xFFD97706))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard(context, 'RSVP Attendees', '${events.fold<int>(0, (sum, e) => sum + e.rsvpCount)}', Icons.event, const Color(0xFF2563EB))),
                  ],
                ),
              ],
            ),
          ),

          // 3. Chapters
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            itemBuilder: (ctx, idx) {
              final ch = chapters[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ch.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor)),
                    const SizedBox(height: 4),
                    Text(ch.region, style: TextStyle(fontSize: 12, color: context.textPrimaryColor.withOpacity(0.8))),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('President: ${ch.president}', style: TextStyle(fontSize: 11, color: context.textMutedColor)),
                        Text('${ch.memberCount} Members', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B181B))),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // 4. Milestones
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: repo.milestones.length,
            itemBuilder: (ctx, idx) {
              final m = repo.milestones[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m.awardTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8B181B))),
                        Text(m.year, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${m.alumnusName} (${m.batch})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    const SizedBox(height: 4),
                    Text(m.citation, style: TextStyle(fontSize: 11, color: context.textMutedColor)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: context.textMutedColor)),
        ],
      ),
    );
  }
}
