import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../theme/app_theme.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  String _searchQuery = '';
  String _selectedDept = 'all';

  final List<String> _departments = [
    'all',
    'College of Computer Studies',
    'College of Engineering',
    'College of Business and Accountancy',
  ];

  void _showAlumniProfileSheet(BuildContext context, UserModel user) {
    final repo = context.read<AlumniRepository>();
    final isConnected = repo.currentUser?.connections.contains(user.uid) ?? false;
    final isMe = repo.currentUser?.uid == user.uid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
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
                        user.currentPosition ?? 'Cecilian Graduate',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimaryColor.withOpacity(0.85)),
                      ),
                      Text(
                        user.company ?? 'St. Cecilia\'s College Alumni',
                        style: TextStyle(fontSize: 12, color: context.textMutedColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Academic Background
            Row(
              children: [
                const Icon(Icons.school_outlined, size: 16, color: Color(0xFF8B181B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${user.course ?? "Undergraduate Degree"} • ${user.batch ?? "Class"}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.textPrimaryColor),
                  ),
                ),
              ],
            ),
            if (user.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8B181B)),
                  const SizedBox(width: 8),
                  Text(
                    user.location!,
                    style: TextStyle(fontSize: 12, color: context.textMutedColor),
                  ),
                ],
              ),
            ],

            if (user.bio != null) ...[
              const SizedBox(height: 14),
              Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor)),
              const SizedBox(height: 4),
              Text(
                user.bio!,
                style: TextStyle(fontSize: 12, height: 1.4, color: context.textPrimaryColor.withOpacity(0.85)),
              ),
            ],

            if (user.skills.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Skills & Focus Areas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: user.skills.map((skill) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.subsurfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Text(skill, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.textPrimaryColor)),
                )).toList(),
              ),
            ],

            const SizedBox(height: 20),
            if (!isMe)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected ? context.subsurfaceColor : const Color(0xFF8B181B),
                        foregroundColor: isConnected ? context.textPrimaryColor : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(isConnected ? Icons.check : Icons.person_add_alt_1, size: 16),
                      label: Text(isConnected ? 'Connected' : 'Connect with Cecilian'),
                      onPressed: () {
                        repo.toggleConnectUser(user.uid);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(isConnected ? 'Disconnected from ${user.name}' : 'Connected with ${user.name}!'),
                            backgroundColor: const Color(0xFF8B181B),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF8B181B)),
                    label: const Text('Message', style: TextStyle(color: Color(0xFF8B181B), fontWeight: FontWeight.bold)),
                    onPressed: () {
                      repo.getOrCreateThread(user);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Conversation opened with ${user.name} in Chats tab!'),
                          backgroundColor: const Color(0xFF8B181B),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final users = repo.users;
    final currentUser = repo.currentUser;
    final isDark = context.isDarkMode;

    final filteredUsers = users.where((u) {
      final matchesQuery = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (u.course ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (u.company ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (u.currentPosition ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDept = _selectedDept == 'all' || u.department == _selectedDept;

      return matchesQuery && matchesDept;
    }).toList();

    return Scaffold(
      backgroundColor: context.canvasColor,
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: context.surfaceColor,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, size: 18, color: context.textMutedColor),
                    hintText: 'Search alumni by name, company, or degree...',
                    hintStyle: TextStyle(fontSize: 12, color: context.textMutedColor),
                    filled: true,
                    fillColor: context.subsurfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.borderColor),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _departments.map((dept) {
                      final isSelected = _selectedDept == dept;
                      final label = dept == 'all'
                          ? 'All Colleges (${users.length})'
                          : dept.replaceAll('College of ', '');
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: const Color(0xFF8B181B),
                          backgroundColor: context.subsurfaceColor,
                          side: BorderSide(color: isSelected ? const Color(0xFF8B181B) : context.borderColor),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : context.textPrimaryColor,
                          ),
                          onSelected: (_) => setState(() => _selectedDept = dept),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Alumni Cards Roster
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Text('No alumni found matching your search.', style: TextStyle(color: context.textMutedColor)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filteredUsers.length,
                    itemBuilder: (ctx, idx) {
                      final user = filteredUsers[idx];
                      final isMe = user.uid == currentUser?.uid;
                      final isConnected = currentUser?.connections.contains(user.uid) ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _showAlumniProfileSheet(context, user),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                                child: Text(
                                  user.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B181B)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showAlumniProfileSheet(context, user),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.textPrimaryColor),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (user.isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, size: 14, color: Color(0xFF059669)),
                                        ],
                                        if (isMe) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: context.subsurfaceColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textMutedColor)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.currentPosition ?? user.course ?? 'Alumni Member',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.textPrimaryColor.withOpacity(0.9)),
                                    ),
                                    Text(
                                      '${user.company ?? "St. Cecilia's College"} • ${user.batch ?? "Batch"}',
                                      style: TextStyle(fontSize: 11, color: context.textMutedColor),
                                    ),
                                    if (user.skills.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: user.skills.take(3).map((s) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: context.subsurfaceColor,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: context.borderColor),
                                          ),
                                          child: Text(s, style: TextStyle(fontSize: 10, color: context.textMutedColor)),
                                        )).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isMe)
                              IconButton(
                                icon: Icon(
                                  isConnected ? Icons.person_remove_outlined : Icons.person_add_alt_1_outlined,
                                  color: isConnected ? context.textMutedColor : const Color(0xFF8B181B),
                                  size: 20,
                                ),
                                tooltip: isConnected ? 'Disconnect' : 'Connect',
                                onPressed: () {
                                  repo.toggleConnectUser(user.uid);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(isConnected ? 'Disconnected' : 'Connected with ${user.name}!'),
                                      backgroundColor: const Color(0xFF8B181B),
                                    ),
                                  );
                                },
                              ),
                          ],
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
