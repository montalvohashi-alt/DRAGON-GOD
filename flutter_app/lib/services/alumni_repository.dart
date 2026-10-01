import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
export '../models/models.dart';

class AlumniRepository extends ChangeNotifier {
  UserModel? _currentUser;
  ThemeMode _themeMode = ThemeMode.light;

  // State-driven routing properties mirroring App.tsx
  AppView _currentView = AppView.portal;
  String _activeTab = 'dashboard';
  AuthMode _authMode = AuthMode.login;
  UserRole _authRole = UserRole.alumni;

  final List<UserModel> _users = [];
  final List<FeedPostModel> _feedPosts = [];
  final List<AnnouncementModel> _announcements = [];
  final List<OpportunityModel> _opportunities = [];
  final List<EventModel> _events = [];
  final List<ChapterModel> _chapters = [];
  final List<MilestoneModel> _milestones = [];
  final List<GalleryItemModel> _galleryItems = [];
  final List<ChatThreadModel> _chatThreads = [];

  AlumniRepository() {
    _initData();
  }

  UserModel? get currentUser => _currentUser;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // View state getters
  AppView get currentView => _currentView;
  String get activeTab => _activeTab;
  AuthMode get authMode => _authMode;
  UserRole get authRole => _authRole;

  List<UserModel> get users => List.unmodifiable(_users);
  List<FeedPostModel> get feedPosts => List.unmodifiable(_feedPosts);
  List<AnnouncementModel> get announcements => List.unmodifiable(_announcements);
  List<OpportunityModel> get opportunities => List.unmodifiable(_opportunities);
  List<EventModel> get events => List.unmodifiable(_events);
  List<ChapterModel> get chapters => List.unmodifiable(_chapters);
  List<MilestoneModel> get milestones => List.unmodifiable(_milestones);
  List<GalleryItemModel> get galleryItems => List.unmodifiable(_galleryItems);
  List<ChatThreadModel> get chatThreads => List.unmodifiable(_chatThreads);

  bool get isLoggedIn => _currentUser != null;

  // Navigation and view switching methods mirroring App.tsx
  void setCurrentView(AppView view) {
    if (_currentView != view) {
      _currentView = view;
      notifyListeners();
    }
  }

  void setActiveTab(String tab) {
    if (_activeTab != tab) {
      _activeTab = tab;
      notifyListeners();
    }
  }

  void setAuthMode(AuthMode mode) {
    if (_authMode != mode) {
      _authMode = mode;
      notifyListeners();
    }
  }

  void setAuthRole(UserRole role) {
    if (_authRole != role) {
      _authRole = role;
      notifyListeners();
    }
  }

  void navigateToAuth({AuthMode mode = AuthMode.login, UserRole role = UserRole.alumni}) {
    _authMode = mode;
    _authRole = role;
    _currentView = AppView.auth;
    notifyListeners();
  }

  void navigateToLanding() {
    _currentView = AppView.landing;
    notifyListeners();
  }

  void navigateToPortal({String tab = 'dashboard'}) {
    _activeTab = tab;
    _currentView = AppView.portal;
    notifyListeners();
  }

  /// Mirrors App.tsx handleLoginSuccess:
  /// Directs user to home/portal dashboard on login
  void handleLoginSuccess([UserRole? role]) {
    _activeTab = 'dashboard';
    _currentView = AppView.portal;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void _initData() {
    // 1. Seed Sample Users
    _users.addAll([
      UserModel(
        uid: 'user-alumni-1',
        name: 'Maria Elena Santos',
        email: 'maria.santos@techsolutions.com',
        role: UserRole.alumni,
        batch: 'Class of 2020',
        course: 'BS Information Technology',
        department: 'College of Computer Studies',
        currentPosition: 'Senior Mobile & Cloud Engineer',
        company: 'Apex Cloud Systems',
        location: 'Cebu City, Philippines',
        bio: 'Passionate full-stack & mobile developer proud of my Cecilian roots. Mentoring students and organizing campus tech circles.',
        skills: ['Flutter', 'React', 'Cloud Architecture', 'TypeScript', 'Node.js'],
        isVerified: true,
        phone: '+63 917 555 0192',
        connections: ['user-student-1', 'user-faculty-1'],
      ),
      UserModel(
        uid: 'user-alumni-2',
        name: 'Engr. Daniel Christian Navarro',
        email: 'daniel.navarro@solarpower.ph',
        role: UserRole.alumni,
        batch: 'Class of 2018',
        course: 'BS Civil Engineering',
        department: 'College of Engineering',
        currentPosition: 'Infrastructure Project Manager',
        company: 'Visayas Sustainable Infrastructure',
        location: 'Minglanilla, Cebu',
        bio: 'Leading clean energy and civic infrastructure development across Central Visayas.',
        skills: ['Project Management', 'Structural Design', 'AutoCAD', 'Urban Planning'],
        isVerified: true,
        phone: '+63 920 888 1234',
        connections: ['user-alumni-1'],
      ),
      UserModel(
        uid: 'user-alumni-3',
        name: 'Katherine Rose Lim, CPA',
        email: 'katherine.lim@sgv.ph',
        role: UserRole.alumni,
        batch: 'Class of 2021',
        course: 'BS Accountancy',
        department: 'College of Business and Accountancy',
        currentPosition: 'Senior Audit Associate',
        company: 'SGV & Co. / Ernst & Young',
        location: 'Cebu Business Park',
        bio: 'Passed the CPA Licensure Exam on first take. Dedicated to financial integrity and student mentoring.',
        skills: ['Auditing', 'Financial Modeling', 'Taxation', 'Corporate Law'],
        isVerified: true,
        phone: '+63 918 333 4455',
        connections: ['user-alumni-1'],
      ),
      UserModel(
        uid: 'user-student-1',
        name: 'Joshua David Ramos',
        email: 'joshua.ramos@stcecilia.edu',
        role: UserRole.student,
        batch: 'Class of 2026',
        course: 'BS Computer Science',
        department: 'College of Computer Studies',
        location: 'Minglanilla, Cebu',
        bio: 'Senior undergraduate exploring Flutter, Machine Learning, and collegiate hackathons.',
        skills: ['Dart', 'Python', 'Machine Learning', 'Git'],
        isVerified: true,
        phone: '+63 929 111 2233',
        connections: ['user-alumni-1'],
      ),
      UserModel(
        uid: 'user-faculty-1',
        name: 'Dr. Fernando Gomez, PhD',
        email: 'fernando.gomez@stcecilia.edu',
        role: UserRole.faculty,
        department: 'College of Computer Studies',
        currentPosition: 'Associate Professor & Research Chair',
        location: 'Minglanilla, Cebu',
        bio: 'Guiding generations of Cecilian computer scientists, system designers, and innovators.',
        skills: ['Software Engineering', 'Research', 'Curriculum Design', 'Data Ethics'],
        isVerified: true,
        connections: ['user-alumni-1'],
      ),
      UserModel(
        uid: 'user-admin-1',
        name: 'Hon. Cecilia Carreon-Velasco',
        email: 'alumni.director@stcecilia.edu',
        role: UserRole.admin,
        currentPosition: 'Director of Alumni Relations',
        department: 'Alumni Affairs & Institutional Advancement',
        location: 'Minglanilla, Cebu',
        bio: 'Connecting over 25,000 alumni worldwide and preserving the sacred legacy of St. Cecilia\'s College.',
        skills: ['Institutional Leadership', 'Fundraising', 'Community Organizing'],
        isVerified: true,
        connections: ['user-alumni-1', 'user-alumni-2'],
      ),
      UserModel(
        uid: 'user-superadmin-1',
        name: 'System Super Administrator',
        email: 'superadmin@stcecilia.edu',
        role: UserRole.superadmin,
        currentPosition: 'Chief Information Officer',
        location: 'Minglanilla, Cebu',
        bio: 'Institutional IT governance and security oversight.',
        skills: ['Enterprise Systems', 'Cybersecurity', 'Database Administration'],
        isVerified: true,
      ),
      UserModel(
        uid: 'user-employer-1',
        name: 'Apex Human Capital Solutions',
        email: 'careers@apexsolutions.ph',
        role: UserRole.employer,
        company: 'Apex Cloud & Enterprise Systems',
        currentPosition: 'Senior Talent Acquisition Lead',
        location: 'Cebu IT Park, Lahug',
        bio: 'Official Corporate Industry Partner recruiting top Cecilian computer science, engineering, and business graduates.',
        skills: ['Talent Sourcing', 'Enterprise Recruiting', 'Internships', 'Industry Partnerships'],
        isVerified: true,
      ),
    ]);

    // Current user starts as Alumni (or can switch roles directly)
    _currentUser = _users[0];
    _currentView = AppView.portal;

    // 2. Seed Interactive News Feed Posts
    _feedPosts.addAll([
      FeedPostModel(
        id: 'post-1',
        authorId: 'user-admin-1',
        authorName: 'Hon. Cecilia Carreon-Velasco',
        authorRole: 'Director of Alumni Relations',
        title: 'Welcome to the Global Cecilian Alumni Network 2026',
        content: 'To all our cherished Cecilian graduates across the archipelago and overseas: Welcome home! Our digital association portal is officially live to connect our global community, empower career pathways, and celebrate institutional milestones.\n\nPlease update your profile, browse job opportunities from fellow Cecilians, and register for the Grand Homecoming Reunion.',
        imageUrl: 'assets/landing-building-1.jpg',
        postType: 'milestone',
        milestoneBadge: 'Institutional Milestone',
        tags: ['CecilianPride', 'GlobalAlumni', 'Homecoming2026'],
        hearts: ['user-alumni-1', 'user-alumni-2', 'user-student-1'],
        sharesCount: 14,
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        comments: [
          FeedCommentModel(
            id: 'c-1',
            authorName: 'Maria Elena Santos',
            authorRole: 'Alumni 2020',
            content: 'So proud to see St. Cecilia\'s leading in modern collegiate connectivity! Congratulations Office of Alumni Affairs.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          FeedCommentModel(
            id: 'c-2',
            authorName: 'Engr. Daniel Christian Navarro',
            authorRole: 'Alumni 2018',
            content: 'Looking forward to our batch reunion at the Main Quadrangle!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          ),
        ],
      ),
      FeedPostModel(
        id: 'post-2',
        authorId: 'user-alumni-1',
        authorName: 'Maria Elena Santos',
        authorRole: 'Alumni • Senior Engineer',
        title: 'Hiring Cecilian IT & CS Interns and Juniors at Apex Cloud Systems!',
        content: 'Excited to announce that our engineering team is sponsoring 5 paid internships and 2 junior developer slots exclusively for graduating students and recent Cecilian batchmates.\n\nDouble tap the photo to heart this post, or visit the Job Board tab to apply directly with your portfolio!',
        imageUrl: 'assets/landing-building-2.jpg',
        postType: 'general',
        tags: ['TechCareers', 'Hiring', 'Mentorship', 'CebuTech'],
        hearts: ['user-alumni-2', 'user-student-1'],
        sharesCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        comments: [
          FeedCommentModel(
            id: 'c-3',
            authorName: 'Joshua David Ramos',
            authorRole: 'Student 2026',
            content: 'Submitted my CV through the portal! Thank you Ma\'am Maria for giving back to Cecilians.',
            createdAt: DateTime.now().subtract(const Duration(hours: 18)),
          ),
        ],
      ),
      FeedPostModel(
        id: 'post-3',
        authorId: 'user-alumni-3',
        authorName: 'Katherine Rose Lim, CPA',
        authorRole: 'Alumni • Audit Associate',
        title: 'Celebration: 100% Passing Rate for Cecilian CPA Examinees!',
        content: 'Heartfelt congratulations to our newest Certified Public Accountants who successfully conquered the recent board examinations! Your dedication in the halls of St. Cecilia\'s has borne exemplary fruit.',
        imageUrl: 'assets/landing-building-3.jpg',
        postType: 'milestone',
        milestoneBadge: 'Board Exam Excellence',
        tags: ['CPAExcellence', 'CecilianTriumph', 'CollegeOfBusiness'],
        hearts: ['user-alumni-1', 'user-admin-1', 'user-alumni-2'],
        sharesCount: 22,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        comments: [],
      ),
    ]);

    // 3. Seed Official Announcements & Circulars
    _announcements.addAll([
      AnnouncementModel(
        id: 'ann-1',
        title: 'Official Circular: Guidelines for Grand Alumni Homecoming 2026',
        content: 'The Office of Alumni Affairs hereby releases the official advisory regarding vehicle passes, registration desks, and batch assembly areas for the upcoming Grand Homecoming on November 28, 2026. All attendees are required to present their digital QR pass generated inside the Events tab.',
        category: 'Institutional',
        priority: 'urgent',
        authorName: 'Office of the College Registrar & Alumni Affairs',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        hearts: ['user-alumni-1', 'user-alumni-2'],
        acknowledgedByUids: ['user-alumni-1'],
      ),
      AnnouncementModel(
        id: 'ann-2',
        title: 'Academic Notice: Online Diploma & Transcript Verification Portal',
        content: 'Alumni requiring certified true copies of transcripts, English translation certificates, or diploma authentication can now submit inquiries directly through their verified digital alumni ID.',
        category: 'Registrar',
        priority: 'important',
        authorName: 'Office of the College Registrar',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        hearts: ['user-alumni-1'],
        acknowledgedByUids: [],
      ),
      AnnouncementModel(
        id: 'ann-3',
        title: 'Cecilian Legacy Endowment Fund: Call for Scholarship Sponsors',
        content: 'Join fellow alumni benefactors in sponsoring deserving underprivileged students for the upcoming academic year. A full semester scholarship can change an entire family\'s trajectory.',
        category: 'Community',
        priority: 'general',
        authorName: 'Institutional Advancement Board',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        hearts: ['user-alumni-1', 'user-alumni-3'],
        acknowledgedByUids: ['user-alumni-1'],
      ),
    ]);

    // 4. Seed Opportunities
    _opportunities.addAll([
      OpportunityModel(
        id: 'opp-1',
        title: 'Junior Mobile Application Developer (Flutter / iOS)',
        company: 'Apex Cloud Systems',
        location: 'Cebu City / Hybrid',
        type: 'full-time',
        description: 'Building next-generation mobile applications for global fintech clients. Open to Cecilian graduates with strong Dart/Flutter skills.',
        salaryOrStipend: '₱35,000 - ₱55,000 / mo',
        skills: ['Flutter', 'Dart', 'REST APIs', 'Git'],
        contactEmail: 'maria.santos@techsolutions.com',
        postedByUid: 'user-alumni-1',
        postedByName: 'Maria Elena Santos',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OpportunityModel(
        id: 'opp-2',
        title: 'Alumni Tech Industry Mentorship Program',
        company: 'Cecilian Tech Founders Circle',
        location: 'Virtual / Remote',
        type: 'mentorship',
        description: 'Get paired 1-on-1 with industry veterans for resume reviews, mock interviews, and career guidance.',
        salaryOrStipend: 'Pro-Bono Mentorship',
        skills: ['Career Guidance', 'Mock Interviews', 'Portfolio Review'],
        contactEmail: 'alumni.director@stcecilia.edu',
        postedByUid: 'user-admin-1',
        postedByName: 'Hon. Cecilia Carreon-Velasco',
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      OpportunityModel(
        id: 'opp-3',
        title: 'Software Quality Assurance Intern',
        company: 'Visayas Digital Labs',
        location: 'Minglanilla / On-site',
        type: 'internship',
        description: 'Exciting paid internship opportunity for graduating students to learn automated and manual testing.',
        salaryOrStipend: '₱12,000 allowance',
        skills: ['Testing', 'Documentation', 'Attention to Detail'],
        contactEmail: 'careers@visayasdigitallabs.com',
        postedByUid: 'user-alumni-1',
        postedByName: 'Maria Elena Santos',
        postedDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);

    // 5. Seed Events
    _events.addAll([
      EventModel(
        id: 'evt-1',
        title: 'Grand Annual Alumni Homecoming 2026',
        description: 'Celebrate our shared Cecilian heritage, reunite with classmates, and honor jubilarian batches at the Main Quadrangle. Enjoy collegiate banquet, live orchestral performances, and alumni achievement recognitions.',
        startDate: DateTime.now().add(const Duration(days: 24)),
        location: 'St. Cecilia’s College Main Quadrangle & Auditorium',
        category: 'Homecoming',
        rsvpCount: 428,
        isOnline: false,
        hearts: ['user-alumni-1', 'user-alumni-2'],
        isReservedByMe: true,
        imageUrl: 'assets/landing-building-1.jpg',
      ),
      EventModel(
        id: 'evt-2',
        title: 'Global Cecilian Tech & Innovation Summit',
        description: 'Virtual keynote panels featuring Cecilian alumni founders across North America, Singapore, and Europe discussing AI, software entrepreneurship, and global engineering.',
        startDate: DateTime.now().add(const Duration(days: 12)),
        location: 'Virtual Broadcast (Zoom & Livestream)',
        category: 'Professional',
        rsvpCount: 195,
        isOnline: true,
        hearts: ['user-alumni-1'],
        isReservedByMe: false,
        imageUrl: 'assets/landing-building-2.jpg',
      ),
      EventModel(
        id: 'evt-3',
        title: 'Alumni Charity Run & Campus Tree Planting',
        description: 'Annual scholarship fundraiser run through Minglanilla followed by campus arbor preservation and tree dedication.',
        startDate: DateTime.now().add(const Duration(days: 35)),
        location: 'Minglanilla Sports Complex & SCC Grounds',
        category: 'Community',
        rsvpCount: 310,
        isOnline: false,
        hearts: [],
        isReservedByMe: false,
        imageUrl: 'assets/landing-building-3.jpg',
      ),
    ]);

    // 6. Seed Chapters
    _chapters.addAll([
      ChapterModel(
        id: 'ch-1',
        name: 'Metro Cebu Central Chapter',
        region: 'Central Visayas, Philippines',
        president: 'Engr. Roberto Mendoza',
        memberCount: 1840,
        contactEmail: 'cebu.chapter@stcecilia.edu',
      ),
      ChapterModel(
        id: 'ch-2',
        name: 'North America Cecilians Alliance',
        region: 'California, United States',
        president: 'Dr. Clarissa Uy-Tan',
        memberCount: 650,
        contactEmail: 'northamerica@stcecilia.edu',
      ),
      ChapterModel(
        id: 'ch-3',
        name: 'Middle East & Gulf Chapter',
        region: 'Dubai, UAE',
        president: 'Architect Noel Santos',
        memberCount: 420,
        contactEmail: 'middleeast@stcecilia.edu',
      ),
    ]);

    // 7. Seed Milestones
    _milestones.addAll([
      MilestoneModel(
        id: 'ms-1',
        alumnusName: 'Justice Rafael Alvarez',
        batch: 'Class of 1998',
        awardTitle: 'Distinguished Cecilian Jurist Award',
        citation: 'For exemplary service in judicial integrity and constitutional governance.',
        year: '2025',
      ),
      MilestoneModel(
        id: 'ms-2',
        alumnusName: 'Engr. Katrina Yap',
        batch: 'Class of 2012',
        awardTitle: 'Global Engineering Pioneer',
        citation: 'Leading high-capacity renewable solar infrastructure across Southeast Asia.',
        year: '2024',
      ),
    ]);

    // 8. Seed Campus Heritage Gallery
    _galleryItems.addAll([
      GalleryItemModel(
        id: 'gal-1',
        title: 'Main Academic Pavilion & St. Cecilia’s Quadrangle',
        category: 'Campus & Facilities',
        year: '2026',
        imageUrl: 'assets/landing-building-1.jpg',
        description: 'The historic academic heart of St. Cecilia’s College, Minglanilla, Cebu.',
      ),
      GalleryItemModel(
        id: 'gal-2',
        title: 'Centennial Heritage Arbor & Campus Grounds',
        category: 'Campus & Facilities',
        year: '2026',
        imageUrl: 'assets/landing-building-2.jpg',
        description: 'Shaded walkways connecting the collegiate libraries and laboratories.',
      ),
      GalleryItemModel(
        id: 'gal-3',
        title: 'Collegiate Façade & Main Entrance Gates',
        category: 'Campus & Facilities',
        year: '2026',
        imageUrl: 'assets/landing-building-3.jpg',
        description: 'Welcoming Cecilians and future leaders for decades.',
      ),
    ]);

    // 9. Seed Direct Messaging Threads
    _chatThreads.addAll([
      ChatThreadModel(
        id: 'thread-student-1',
        participantUid: 'user-student-1',
        participantName: 'Joshua David Ramos',
        participantRole: 'Student • Class of 2026',
        participantBatch: '2026',
        participantCourse: 'BS Computer Science',
        lastMessage: 'Thank you Ma\'am Maria! I submitted my CV and GitHub portfolio for the Flutter role.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 18)),
        unreadCount: 1,
        messages: [
          ChatMessageModel(
            id: 'm-1',
            senderUid: 'user-student-1',
            senderName: 'Joshua David Ramos',
            text: 'Good day Ma\'am Maria! I saw your announcement on the Cecilian news feed regarding Flutter interns.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessageModel(
            id: 'm-2',
            senderUid: 'user-alumni-1',
            senderName: 'Maria Elena Santos',
            text: 'Hello Joshua! Yes, we have open slots for hardworking Cecilians. Make sure to highlight your mobile projects.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          ),
          ChatMessageModel(
            id: 'm-3',
            senderUid: 'user-student-1',
            senderName: 'Joshua David Ramos',
            text: 'Thank you Ma\'am Maria! I submitted my CV and GitHub portfolio for the Flutter role.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
            isRead: false,
          ),
        ],
      ),
      ChatThreadModel(
        id: 'thread-admin-1',
        participantUid: 'user-admin-1',
        participantName: 'Hon. Cecilia Carreon-Velasco',
        participantRole: 'Director of Alumni Relations',
        participantBatch: '1995',
        participantCourse: 'College Leadership',
        lastMessage: 'Your batch table has been confirmed in Row A for the Grand Homecoming banquet.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        unreadCount: 0,
        messages: [
          ChatMessageModel(
            id: 'm-4',
            senderUid: 'user-alumni-1',
            senderName: 'Maria Elena Santos',
            text: 'Director Cecilia, our Batch 2020 reunion committee has 25 confirmed attendees so far!',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          ),
          ChatMessageModel(
            id: 'm-5',
            senderUid: 'user-admin-1',
            senderName: 'Hon. Cecilia Carreon-Velasco',
            text: 'Your batch table has been confirmed in Row A for the Grand Homecoming banquet.',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ],
      ),
    ]);
  }

  // Live Role Switcher (Alumni, Student, Faculty, Admin, Staff, Super Admin, Employer)
  // Synchronizes the tab and workspace layout transitions between Admin and Alumni roles
  void switchRole(UserRole role) {
    final prevWasAdmin = isAdministrativeOrStaffRole(_currentUser?.role);
    final newIsAdmin = isAdministrativeOrStaffRole(role);

    final matchedUser = _users.firstWhere(
      (u) => u.role == role,
      orElse: () => _users[0],
    );
    _currentUser = matchedUser;

    // Synchronize workspace tabs intelligently during role transition
    if (!prevWasAdmin && newIsAdmin) {
      // Transitioning from Alumni to Admin workspace
      if (_activeTab == 'network') {
        _activeTab = 'users';
      }
    } else if (prevWasAdmin && !newIsAdmin) {
      // Transitioning from Admin to Alumni workspace
      if (_activeTab == 'users' || _activeTab == 'registry') {
        _activeTab = 'network';
      }
    }

    notifyListeners();
  }

  void loginAs(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Authenticate user credentials with verification checks mirroring App.tsx
  String? loginWithVerification(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final matched = _users.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () => _users.firstWhere((u) => u.email.toLowerCase().contains(cleanEmail), orElse: () => _users[0]),
    );

    // Verification Enforcement (mirroring App.tsx lines 97-107)
    if (!matched.isVerified) {
      return 'Academic record verification required. Please contact the Registrar\'s Office or complete registrar verification.';
    }

    _currentUser = matched;
    handleLoginSuccess(matched.role);
    return null;
  }

  void registerUser({
    required String name,
    required String email,
    required UserRole role,
    required String studentId,
    String? course,
    String? department,
    String? batch,
    String? currentPosition,
    String? company,
  }) {
    final isVerifiedFormat = RegExp(r'^SC-\d{4}-\d{3,5}$', caseSensitive: false).hasMatch(studentId.trim());
    final newUser = UserModel(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: role,
      studentId: studentId.trim(),
      course: course?.trim() ?? 'BS Information Technology',
      department: department?.trim() ?? 'College of Computer Studies',
      batch: batch?.trim() ?? 'Class of ${DateTime.now().year}',
      currentPosition: currentPosition?.trim() ?? 'Graduate Alumnus',
      company: company?.trim() ?? 'St. Cecilia\'s College Alumni Network',
      isVerified: isVerifiedFormat,
      isProfileSetupCompleted: true,
    );
    _users.insert(0, newUser);
    _currentUser = newUser;
    handleLoginSuccess(newUser.role);
  }

  void logout() {
    _currentUser = null;
    _currentView = AppView.auth;
    _authMode = AuthMode.login;
    notifyListeners();
  }

  // Feed Actions
  void toggleHeartFeedPost(String postId) {
    final index = _feedPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _feedPosts[index];
      final currentUid = _currentUser?.uid ?? 'guest-user';
      final updatedHearts = List<String>.from(post.hearts);
      if (updatedHearts.contains(currentUid)) {
        updatedHearts.remove(currentUid);
      } else {
        updatedHearts.add(currentUid);
      }
      _feedPosts[index] = post.copyWith(hearts: updatedHearts);
      notifyListeners();
    }
  }

  void addFeedPostComment(String postId, String text) {
    if (text.trim().isEmpty) return;
    final index = _feedPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _feedPosts[index];
      final updatedComments = List<FeedCommentModel>.from(post.comments);
      updatedComments.add(
        FeedCommentModel(
          id: 'c-${DateTime.now().millisecondsSinceEpoch}',
          authorName: _currentUser?.name ?? 'Cecilian Alumnus',
          authorRole: _currentUser?.role.shortName ?? 'Alumni',
          content: text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      _feedPosts[index] = post.copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  void createFeedPost({
    required String title,
    required String content,
    String? imageUrl,
    String postType = 'general',
    String? milestoneBadge,
    List<String> tags = const [],
  }) {
    final newPost = FeedPostModel(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: _currentUser?.uid ?? 'user-alumni-1',
      authorName: _currentUser?.name ?? 'Maria Elena Santos',
      authorRole: _currentUser?.role.displayName ?? 'Alumni Member',
      title: title,
      content: content,
      imageUrl: imageUrl,
      postType: postType,
      milestoneBadge: milestoneBadge,
      tags: tags,
      createdAt: DateTime.now(),
    );
    _feedPosts.insert(0, newPost);
    notifyListeners();
  }

  // Announcements Actions
  void toggleHeartAnnouncement(String annId) {
    final index = _announcements.indexWhere((a) => a.id == annId);
    if (index != -1) {
      final ann = _announcements[index];
      final currentUid = _currentUser?.uid ?? 'guest-user';
      final updatedHearts = List<String>.from(ann.hearts);
      if (updatedHearts.contains(currentUid)) {
        updatedHearts.remove(currentUid);
      } else {
        updatedHearts.add(currentUid);
      }
      _announcements[index] = ann.copyWith(hearts: updatedHearts);
      notifyListeners();
    }
  }

  void acknowledgeAnnouncement(String annId) {
    final index = _announcements.indexWhere((a) => a.id == annId);
    if (index != -1) {
      final ann = _announcements[index];
      final currentUid = _currentUser?.uid ?? 'guest-user';
      final updatedAcks = List<String>.from(ann.acknowledgedByUids);
      if (!updatedAcks.contains(currentUid)) {
        updatedAcks.add(currentUid);
        _announcements[index] = ann.copyWith(acknowledgedByUids: updatedAcks);
        notifyListeners();
      }
    }
  }

  // Event Actions
  void toggleRsvpEvent(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final evt = _events[index];
      final isNowReserved = !evt.isReservedByMe;
      final newCount = isNowReserved ? evt.rsvpCount + 1 : (evt.rsvpCount > 0 ? evt.rsvpCount - 1 : 0);
      _events[index] = evt.copyWith(
        isReservedByMe: isNowReserved,
        rsvpCount: newCount,
      );
      notifyListeners();
    }
  }

  void toggleHeartEvent(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final evt = _events[index];
      final currentUid = _currentUser?.uid ?? 'guest-user';
      final updatedHearts = List<String>.from(evt.hearts);
      if (updatedHearts.contains(currentUid)) {
        updatedHearts.remove(currentUid);
      } else {
        updatedHearts.add(currentUid);
      }
      _events[index] = evt.copyWith(hearts: updatedHearts);
      notifyListeners();
    }
  }

  // Network / Connections Actions
  void toggleConnectUser(String targetUid) {
    if (_currentUser == null) return;
    final updatedConnections = List<String>.from(_currentUser!.connections);
    if (updatedConnections.contains(targetUid)) {
      updatedConnections.remove(targetUid);
    } else {
      updatedConnections.add(targetUid);
    }
    _currentUser = _currentUser!.copyWith(connections: updatedConnections);
    
    // Also update in _users list
    final idx = _users.indexWhere((u) => u.uid == _currentUser!.uid);
    if (idx != -1) {
      _users[idx] = _currentUser!;
    }
    notifyListeners();
  }

  void updateCurrentUser(UserModel updated) {
    _currentUser = updated;
    final idx = _users.indexWhere((u) => u.uid == updated.uid);
    if (idx != -1) {
      _users[idx] = updated;
    }
    notifyListeners();
  }

  void addOpportunity(OpportunityModel opp) {
    _opportunities.insert(0, opp);
    notifyListeners();
  }

  void addMilestone(MilestoneModel milestone) {
    _milestones.insert(0, milestone);
    notifyListeners();
  }

  void addChapter(ChapterModel chapter) {
    _chapters.add(chapter);
    notifyListeners();
  }

  void addGalleryItem(GalleryItemModel item) {
    _galleryItems.insert(0, item);
    notifyListeners();
  }

  void toggleUserVerification(String uid) {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      final user = _users[index];
      _users[index] = user.copyWith(isVerified: !user.isVerified);
      if (_currentUser?.uid == uid) {
        _currentUser = _users[index];
      }
      notifyListeners();
    }
  }

  // Messaging Actions
  void sendMessage(String threadId, String text) {
    if (text.trim().isEmpty) return;
    final index = _chatThreads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _chatThreads[index];
      final newMsg = ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        senderUid: _currentUser?.uid ?? 'cecilian-member',
        senderName: _currentUser?.name ?? 'Maria Elena Santos',
        text: text.trim(),
        timestamp: DateTime.now(),
        isRead: true,
      );
      final updatedMsgs = List<ChatMessageModel>.from(thread.messages)..add(newMsg);
      _chatThreads[index] = thread.copyWith(
        messages: updatedMsgs,
        lastMessage: text.trim(),
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );
      notifyListeners();
    }
  }

  ChatThreadModel getOrCreateThread(UserModel targetUser) {
    final existingIndex = _chatThreads.indexWhere((t) => t.participantUid == targetUser.uid);
    if (existingIndex != -1) {
      return _chatThreads[existingIndex];
    }
    final newThread = ChatThreadModel(
      id: 'thread-${DateTime.now().millisecondsSinceEpoch}',
      participantUid: targetUser.uid,
      participantName: targetUser.name,
      participantRole: targetUser.role.displayName,
      participantBatch: targetUser.batch,
      participantCourse: targetUser.course,
      lastMessage: 'Started a new conversation',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      messages: [],
    );
    _chatThreads.insert(0, newThread);
    notifyListeners();
    return newThread;
  }
}

