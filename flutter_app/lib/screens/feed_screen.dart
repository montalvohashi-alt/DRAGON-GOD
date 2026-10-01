import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/alumni_repository.dart';
import '../theme/app_theme.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedFilter = 'all'; // 'all', 'milestone', 'gallery', 'general'
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _showCreatePostDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final badgeCtrl = TextEditingController();
    String postType = 'general';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share with Cecilian Alumni',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: context.textMutedColor),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Headline / Milestone Title',
                    hintText: 'e.g. Passed the Bar Exam or Promoted to VP',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Story / Update',
                    hintText: 'Share reflections, career news, or campus memories...',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: postType,
                  dropdownColor: context.surfaceColor,
                  decoration: const InputDecoration(
                    labelText: 'Post Type',
                  ),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text('General Social Update', style: TextStyle(color: context.textPrimaryColor))),
                    DropdownMenuItem(value: 'milestone', child: Text('Official Milestone Honor', style: TextStyle(color: context.textPrimaryColor))),
                    DropdownMenuItem(value: 'gallery', child: Text('Campus Heritage Memory', style: TextStyle(color: context.textPrimaryColor))),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => postType = val);
                  },
                ),
                if (postType == 'milestone') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: badgeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Honor Badge Text',
                      hintText: 'e.g. Cum Laude, CPA Passer, Tech Founder',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B181B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                      context.read<AlumniRepository>().createFeedPost(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        postType: postType,
                        milestoneBadge: badgeCtrl.text.trim().isNotEmpty ? badgeCtrl.text.trim() : null,
                        imageUrl: 'assets/landing-building-1.jpg',
                        tags: ['CecilianNetwork', 'Milestone2026'],
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your post is now live across the alumni news feed!'),
                          backgroundColor: Color(0xFF8B181B),
                        ),
                      );
                    },
                    child: const Text('Publish Update', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, FeedPostModel post) {
    final repo = context.read<AlumniRepository>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final currentPost = context.watch<AlumniRepository>().feedPosts.firstWhere(
              (p) => p.id == post.id,
              orElse: () => post,
            );

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${currentPost.comments.length})',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.textMutedColor),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: currentPost.comments.isEmpty
                          ? Center(
                              child: Text(
                                'No comments yet. Start the conversation!',
                                style: TextStyle(color: context.textMutedColor, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: currentPost.comments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) {
                                final c = currentPost.comments[idx];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: context.subsurfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: context.borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            c.authorName,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor),
                                          ),
                                          Text(
                                            DateFormat('MMM d, h:mm a').format(c.createdAt),
                                            style: TextStyle(color: context.textMutedColor, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.content,
                                        style: TextStyle(fontSize: 12, color: context.textPrimaryColor.withOpacity(0.9)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            decoration: InputDecoration(
                              hintText: 'Congratulate or reply...',
                              hintStyle: TextStyle(fontSize: 12, color: context.textMutedColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF8B181B)),
                          icon: const Icon(Icons.send, size: 18, color: Colors.white),
                          onPressed: () {
                            if (_commentCtrl.text.trim().isEmpty) return;
                            repo.addFeedPostComment(post.id, _commentCtrl.text);
                            _commentCtrl.clear();
                            setSheetState(() {});
                          },
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final currentUser = repo.currentUser;
    final allPosts = repo.feedPosts;
    final isDark = context.isDarkMode;

    final filteredPosts = allPosts.where((p) {
      if (_selectedFilter == 'all') return true;
      return p.postType == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: context.canvasColor,
      body: CustomScrollView(
        slivers: [
          // Top Create Post Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              padding: const EdgeInsets.all(12),
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
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                    child: Text(
                      currentUser?.name.substring(0, 1).toUpperCase() ?? 'C',
                      style: const TextStyle(color: Color(0xFF8B181B), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showCreatePostDialog(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: context.subsurfaceColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Share an achievement or campus memory...",
                          style: TextStyle(color: context.textMutedColor, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF8B181B)),
                    onPressed: () => _showCreatePostDialog(context),
                    tooltip: 'Create Post',
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip(context, 'all', 'All Posts (${allPosts.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'milestone', '🏆 Milestones & Honors'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'gallery', '🏛️ Campus Heritage'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'general', '💬 Social & Careers'),
                ],
              ),
            ),
          ),

          // Posts List
          if (filteredPosts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No posts found in this category.', style: TextStyle(color: context.textMutedColor)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, idx) {
                    final post = filteredPosts[idx];
                    final isHearted = currentUser != null && post.hearts.contains(currentUser.uid);

                    return _buildPostCard(context, post, isHearted);
                  },
                  childCount: filteredPosts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF8B181B),
      backgroundColor: context.surfaceColor,
      side: BorderSide(
        color: isSelected ? const Color(0xFF8B181B) : context.borderColor,
      ),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : context.textPrimaryColor,
      ),
      onSelected: (_) => setState(() => _selectedFilter = value),
    );
  }

  Widget _buildPostCard(BuildContext context, FeedPostModel post, bool isHearted) {
    final repo = context.read<AlumniRepository>();
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned indicator if pinned
          if (post.isPinned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x33B45309) : const Color(0xFFFEF3C7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 12, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309)),
                  const SizedBox(width: 4),
                  Text(
                    'Featured Priority Announcement',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF8B181B).withOpacity(0.12),
                  child: Text(
                    post.authorName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B181B)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: Color(0xFF059669)),
                        ],
                      ),
                      Text(
                        '${post.authorRole} • ${DateFormat('MMM d').format(post.createdAt)}',
                        style: TextStyle(fontSize: 10, color: context.textMutedColor),
                      ),
                    ],
                  ),
                ),
                if (post.milestoneBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x22FBBF24) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0x44FBBF24) : const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      post.milestoneBadge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Title & Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  style: TextStyle(fontSize: 12, height: 1.45, color: context.textPrimaryColor.withOpacity(0.85)),
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: post.tags.map((tag) => Text(
                      '#$tag',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFB7185)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Image Attachment with Double-Tap to Heart
          if (post.imageUrl != null)
            GestureDetector(
              onDoubleTap: () {
                repo.toggleHeartFeedPost(post.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(milliseconds: 900),
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Hearted with St. Cecilia\'s spirit!'),
                      ],
                    ),
                    backgroundColor: Color(0xFF8B181B),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                height: 190,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF111827)),
                child: Image.asset(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Center(
                    child: Icon(Icons.school, size: 48, color: Colors.white24),
                  ),
                ),
              ),
            ),

          // Engagement Counters
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.hearts.length} hearts',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                    ),
                  ],
                ),
                Text(
                  '${post.comments.length} comments • ${post.sharesCount} shares',
                  style: TextStyle(fontSize: 11, color: context.textMutedColor),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons: Heart, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                // Heart Reaction Button
                Expanded(
                  child: InkWell(
                    onTap: () => repo.toggleHeartFeedPost(post.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isHearted ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isHearted ? const Color(0xFFE11D48) : context.textMutedColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isHearted ? 'Hearted' : 'Heart',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isHearted ? FontWeight.bold : FontWeight.w500,
                              color: isHearted ? const Color(0xFFE11D48) : context.textMutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Comment Button
                Expanded(
                  child: InkWell(
                    onTap: () => _showCommentsSheet(context, post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 16, color: context.textMutedColor),
                          const SizedBox(width: 6),
                          Text('Comment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.textMutedColor)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Share Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Notice link copied to clipboard!'),
                          backgroundColor: Color(0xFF8B181B),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_outlined, size: 16, color: context.textMutedColor),
                          const SizedBox(width: 6),
                          Text('Share', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.textMutedColor)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
