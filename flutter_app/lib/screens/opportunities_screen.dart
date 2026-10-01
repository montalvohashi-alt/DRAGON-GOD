import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../theme/app_theme.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  String _searchQuery = '';
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();

    final filtered = repo.opportunities.where((opp) {
      final matchesSearch = opp.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opp.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == 'all' || opp.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      backgroundColor: context.canvasColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B181B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Opportunity', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showPostModal(context, repo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Box
            TextField(
              decoration: InputDecoration(
                hintText: 'Search roles, companies, or cities...',
                prefixIcon: Icon(Icons.search, size: 20, color: context.textMutedColor),
                filled: true,
                fillColor: context.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),

            // Type Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, 'All Types', 'all'),
                  _buildFilterChip(context, 'Full-Time', 'full-time'),
                  _buildFilterChip(context, 'Internship', 'internship'),
                  _buildFilterChip(context, 'Mentorship', 'mentorship'),
                  _buildFilterChip(context, 'Part-Time', 'part-time'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Opportunity List
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text('No opportunities match your filter.', style: TextStyle(color: context.textMutedColor)))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final opp = filtered[index];
                        return _buildOpportunityCard(context, opp);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final isSelected = _selectedType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF8B181B),
        backgroundColor: context.surfaceColor,
        side: BorderSide(color: isSelected ? const Color(0xFF8B181B) : context.borderColor),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : context.textPrimaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _selectedType = value),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, OpportunityModel opp) {
    final isDark = context.isDarkMode;

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x331D4ED8) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    opp.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                    ),
                  ),
                ),
                if (opp.salaryOrStipend != null)
                  Text(
                    opp.salaryOrStipend!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              opp.title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: context.textMutedColor),
                const SizedBox(width: 4),
                Text(opp.company, style: TextStyle(fontSize: 12, color: context.textMutedColor, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Icon(Icons.location_on, size: 14, color: context.textMutedColor),
                const SizedBox(width: 4),
                Text(opp.location, style: TextStyle(fontSize: 12, color: context.textMutedColor)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              opp.description,
              style: TextStyle(fontSize: 12, color: context.textPrimaryColor.withOpacity(0.85), height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: opp.skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.subsurfaceColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Text(s, style: TextStyle(fontSize: 10, color: context.textPrimaryColor)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted by ${opp.postedByName}',
                  style: TextStyle(fontSize: 11, color: context.textMutedColor),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B181B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contact info copied: ${opp.contactEmail}'),
                        backgroundColor: const Color(0xFF8B181B),
                      ),
                    );
                  },
                  child: const Text('Connect / Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPostModal(BuildContext context, AlumniRepository repo) {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final descController = TextEditingController();
    final salaryController = TextEditingController();
    final skillsController = TextEditingController();
    String selectedType = 'full-time';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Post New Opportunity',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.textMutedColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Job / Mentorship Title'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: companyController,
                            decoration: const InputDecoration(labelText: 'Company / Organization'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: locationController,
                            decoration: const InputDecoration(labelText: 'Location / Remote'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: context.surfaceColor,
                      decoration: const InputDecoration(labelText: 'Opportunity Type'),
                      items: [
                        DropdownMenuItem(value: 'full-time', child: Text('Full-Time Role', style: TextStyle(color: context.textPrimaryColor))),
                        DropdownMenuItem(value: 'internship', child: Text('Student Internship', style: TextStyle(color: context.textPrimaryColor))),
                        DropdownMenuItem(value: 'mentorship', child: Text('Alumni Mentorship', style: TextStyle(color: context.textPrimaryColor))),
                        DropdownMenuItem(value: 'part-time', child: Text('Part-Time / Project', style: TextStyle(color: context.textPrimaryColor))),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: salaryController,
                      decoration: const InputDecoration(labelText: 'Salary / Stipend (Optional)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: skillsController,
                      decoration: const InputDecoration(labelText: 'Key Skills (comma separated)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description & Requirements'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B181B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          final skills = skillsController.text
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();

                          final newOpp = OpportunityModel(
                            id: 'opp-${DateTime.now().millisecondsSinceEpoch}',
                            title: titleController.text.trim(),
                            company: companyController.text.trim(),
                            location: locationController.text.trim(),
                            type: selectedType,
                            description: descController.text.trim(),
                            salaryOrStipend: salaryController.text.trim().isNotEmpty
                                ? salaryController.text.trim()
                                : null,
                            skills: skills,
                            contactEmail: repo.currentUser?.email ?? 'alumni@stcecilia.edu',
                            postedByUid: repo.currentUser?.uid ?? 'cecilian',
                            postedByName: repo.currentUser?.name ?? 'Cecilian Alumni',
                            postedDate: DateTime.now(),
                          );

                          repo.addOpportunity(newOpp);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opportunity successfully posted!'),
                              backgroundColor: Color(0xFF8B181B),
                            ),
                          );
                        },
                        child: const Text('Publish Opportunity', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
