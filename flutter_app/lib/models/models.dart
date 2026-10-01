// Dart models for St. Cecilia's College Global Alumni Association

enum UserRole {
  alumni,
  student,
  faculty,
  admin,
  staff,
  superadmin,
  employer,
}

enum AppView {
  landing,
  auth,
  portal,
}

enum AuthMode {
  login,
  register,
}

/// Role-Based Categorization mirroring src/types.ts isAdministrativeOrStaffRole:
/// Returns true if the user role is an administrative, management, or corporate partner role.
bool isAdministrativeOrStaffRole(UserRole? role) {
  if (role == null) return false;
  return role == UserRole.admin ||
      role == UserRole.staff ||
      role == UserRole.superadmin ||
      role == UserRole.employer;
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.alumni:
        return 'Alumni Member';
      case UserRole.student:
        return 'Undergraduate Student';
      case UserRole.faculty:
        return 'Faculty / Academic';
      case UserRole.admin:
        return 'Alumni Association Admin';
      case UserRole.staff:
        return 'Institutional Staff';
      case UserRole.superadmin:
        return 'Super Administrator';
      case UserRole.employer:
        return 'Corporate Employer / Partner';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.alumni:
        return 'Alumni';
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
      case UserRole.superadmin:
        return 'SuperAdmin';
      case UserRole.employer:
        return 'Employer';
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? batch;
  final String? course;
  final String? department;
  final String? currentPosition;
  final String? company;
  final String? location;
  final String? bio;
  final String? avatarUrl;
  final bool isVerified;
  final List<String> skills;
  final String? phone;
  final List<String> connections;
  final String? employmentStatus;
  final String? industry;
  final String? headline;
  final String? website;
  final String? studentId;
  final bool isProfileSetupCompleted;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.batch,
    this.course,
    this.department,
    this.currentPosition,
    this.company,
    this.location,
    this.bio,
    this.avatarUrl,
    this.isVerified = true,
    this.skills = const [],
    this.phone,
    this.connections = const [],
    this.employmentStatus = 'Employed',
    this.industry = 'Information Technology & Software',
    this.headline,
    this.website,
    this.studentId,
    this.isProfileSetupCompleted = false,
  });

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? batch,
    String? course,
    String? department,
    String? currentPosition,
    String? company,
    String? location,
    String? bio,
    String? avatarUrl,
    bool? isVerified,
    List<String>? skills,
    String? phone,
    List<String>? connections,
    String? employmentStatus,
    String? industry,
    String? headline,
    String? website,
    String? studentId,
    bool? isProfileSetupCompleted,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      batch: batch ?? this.batch,
      course: course ?? this.course,
      department: department ?? this.department,
      currentPosition: currentPosition ?? this.currentPosition,
      company: company ?? this.company,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      skills: skills ?? this.skills,
      phone: phone ?? this.phone,
      connections: connections ?? this.connections,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      industry: industry ?? this.industry,
      headline: headline ?? this.headline,
      website: website ?? this.website,
      studentId: studentId ?? this.studentId,
      isProfileSetupCompleted: isProfileSetupCompleted ?? this.isProfileSetupCompleted,
    );
  }
}

class FeedCommentModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String content;
  final DateTime createdAt;

  FeedCommentModel({
    required this.id,
    required this.authorName,
    this.authorRole = 'Alumni',
    required this.content,
    required this.createdAt,
  });
}

class FeedPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final String title;
  final String content;
  final String? imageUrl;
  final String postType; // 'general', 'milestone', 'gallery', 'academic'
  final String? milestoneBadge;
  final List<String> tags;
  final List<String> hearts;
  final int sharesCount;
  final List<FeedCommentModel> comments;
  final DateTime createdAt;
  final bool isPinned;

  FeedPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorRole = 'Alumni',
    this.authorAvatar,
    required this.title,
    required this.content,
    this.imageUrl,
    this.postType = 'general',
    this.milestoneBadge,
    this.tags = const [],
    this.hearts = const [],
    this.sharesCount = 0,
    this.comments = const [],
    required this.createdAt,
    this.isPinned = false,
  });

  FeedPostModel copyWith({
    String? title,
    String? content,
    String? imageUrl,
    String? postType,
    String? milestoneBadge,
    List<String>? tags,
    List<String>? hearts,
    int? sharesCount,
    List<FeedCommentModel>? comments,
    bool? isPinned,
  }) {
    return FeedPostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      postType: postType ?? this.postType,
      milestoneBadge: milestoneBadge ?? this.milestoneBadge,
      tags: tags ?? this.tags,
      hearts: hearts ?? this.hearts,
      sharesCount: sharesCount ?? this.sharesCount,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String priority; // 'urgent', 'important', 'general'
  final String authorName;
  final String authorRole;
  final DateTime publishedAt;
  final List<String> hearts;
  final List<String> acknowledgedByUids;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Institutional',
    this.priority = 'general',
    required this.authorName,
    this.authorRole = 'Office of Alumni Affairs',
    required this.publishedAt,
    this.hearts = const [],
    this.acknowledgedByUids = const [],
  });

  AnnouncementModel copyWith({
    String? title,
    String? content,
    String? category,
    String? priority,
    List<String>? hearts,
    List<String>? acknowledgedByUids,
  }) {
    return AnnouncementModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      authorName: authorName,
      authorRole: authorRole,
      publishedAt: publishedAt,
      hearts: hearts ?? this.hearts,
      acknowledgedByUids: acknowledgedByUids ?? this.acknowledgedByUids,
    );
  }
}

class OpportunityModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // full-time, internship, mentorship, part-time
  final String description;
  final String? salaryOrStipend;
  final List<String> skills;
  final String contactEmail;
  final String postedByUid;
  final String postedByName;
  final DateTime postedDate;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    this.salaryOrStipend,
    this.skills = const [],
    required this.contactEmail,
    required this.postedByUid,
    required this.postedByName,
    required this.postedDate,
  });
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String category;
  final int rsvpCount;
  final bool isOnline;
  final List<String> hearts;
  final bool isReservedByMe;
  final String? imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.category,
    this.rsvpCount = 0,
    this.isOnline = false,
    this.hearts = const [],
    this.isReservedByMe = false,
    this.imageUrl,
  });

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? category,
    int? rsvpCount,
    bool? isOnline,
    List<String>? hearts,
    bool? isReservedByMe,
    String? imageUrl,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      category: category ?? this.category,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      isOnline: isOnline ?? this.isOnline,
      hearts: hearts ?? this.hearts,
      isReservedByMe: isReservedByMe ?? this.isReservedByMe,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ChapterModel {
  final String id;
  final String name;
  final String region;
  final String president;
  final int memberCount;
  final String contactEmail;

  ChapterModel({
    required this.id,
    required this.name,
    required this.region,
    required this.president,
    required this.memberCount,
    required this.contactEmail,
  });
}

class MilestoneModel {
  final String id;
  final String alumnusName;
  final String batch;
  final String awardTitle;
  final String citation;
  final String year;

  MilestoneModel({
    required this.id,
    required this.alumnusName,
    required this.batch,
    required this.awardTitle,
    required this.citation,
    required this.year,
  });
}

class GalleryItemModel {
  final String id;
  final String title;
  final String category;
  final String year;
  final String imageUrl;
  final String description;

  GalleryItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.year,
    required this.imageUrl,
    required this.description,
  });
}

class ChatMessageModel {
  final String id;
  final String senderUid;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = true,
  });
}

class ChatThreadModel {
  final String id;
  final String participantUid;
  final String participantName;
  final String participantRole;
  final String? participantBatch;
  final String? participantCourse;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessageModel> messages;

  ChatThreadModel({
    required this.id,
    required this.participantUid,
    required this.participantName,
    required this.participantRole,
    this.participantBatch,
    this.participantCourse,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.messages,
  });

  ChatThreadModel copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<ChatMessageModel>? messages,
  }) {
    return ChatThreadModel(
      id: id,
      participantUid: participantUid,
      participantName: participantName,
      participantRole: participantRole,
      participantBatch: participantBatch,
      participantCourse: participantCourse,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }
}

enum NotificationCategory {
  event,
  message,
  announcement,
  career,
  system,
}

extension NotificationCategoryExtension on NotificationCategory {
  String get displayName {
    switch (this) {
      case NotificationCategory.event:
        return 'Event Update';
      case NotificationCategory.message:
        return 'Direct Message';
      case NotificationCategory.announcement:
        return 'Official Circular';
      case NotificationCategory.career:
        return 'Career Alert';
      case NotificationCategory.system:
        return 'Institutional Alert';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.data = const {},
  });

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      category: category,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}


