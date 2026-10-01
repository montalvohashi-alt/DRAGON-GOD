import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/alumni_repository.dart';
import 'services/connectivity_service.dart';
import 'services/fcm_service.dart';
import 'theme/theme_provider.dart';
import 'models/models.dart';
import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/alumni_workspace_layout.dart';
import 'screens/admin_workspace_layout.dart';
import 'widgets/first_time_profile_setup_modal.dart';
import 'widgets/connectivity_overlay.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AlumniRepository()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => FCMService()),
      ],
      child: const CeciliansAlumniApp(),
    ),
  );
}

class CeciliansAlumniApp extends StatefulWidget {
  const CeciliansAlumniApp({super.key});

  @override
  State<CeciliansAlumniApp> createState() => _CeciliansAlumniAppState();
}

class _CeciliansAlumniAppState extends State<CeciliansAlumniApp> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Initialize connectivity_plus stream listener to track network status
    // and trigger the visibility of the offline status overlay across all navigation states.
    _initConnectivityStream();
  }

  void _initConnectivityStream() {
    _connectivity.checkConnectivity().then((result) {
      _handleConnectivityResult(result);
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((dynamic result) {
      _handleConnectivityResult(result);
    });
  }

  void _handleConnectivityResult(dynamic result) {
    bool isOffline = false;
    if (result is List<ConnectivityResult>) {
      isOffline = result.isEmpty || result.every((r) => r == ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      isOffline = result == ConnectivityResult.none;
    }

    if (isOffline) {
      ConnectivityOverlay.show();
    } else {
      ConnectivityOverlay.hide();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: "Cecilian Alumnet",
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ConnectivityService.messengerKey,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return ConnectivityOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const StateDrivenAppShell(),
    );
  }
}

/// State-driven application shell mirroring src/App.tsx
/// Manages high-level view transitions (Landing -> Auth -> Portal)
/// and seamlessly synchronizes workspace layout transitions between Admin and Alumni roles.
class StateDrivenAppShell extends StatefulWidget {
  const StateDrivenAppShell({super.key});

  @override
  State<StateDrivenAppShell> createState() => _StateDrivenAppShellState();
}

class _StateDrivenAppShellState extends State<StateDrivenAppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeSetup();
    });
  }

  void _checkFirstTimeSetup() {
    final repo = context.read<AlumniRepository>();
    final user = repo.currentUser;
    if (user != null &&
        user.role == UserRole.alumni &&
        (!user.isProfileSetupCompleted || user.currentPosition == null || user.company == null)) {
      FirstTimeProfileSetupModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AlumniRepository>();
    final currentView = repo.currentView;
    final currentUser = repo.currentUser;
    final isAdmin = isAdministrativeOrStaffRole(currentUser?.role);

    // Strict Verification Gate Enforcement (mirroring App.tsx lines 95-107)
    if (currentUser != null && !currentUser.isVerified && currentView == AppView.portal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        repo.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Academic record verification required. Please sign in with verified credentials.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      });
    }

    // Determine active view widget mirroring App.tsx
    Widget activeWidget;
    switch (currentView) {
      case AppView.landing:
        activeWidget = const LandingScreen(key: ValueKey('view-landing'));
        break;
      case AppView.auth:
        activeWidget = const AuthScreen(key: ValueKey('view-auth'));
        break;
      case AppView.portal:
      default:
        if (currentUser == null) {
          activeWidget = const AuthScreen(key: ValueKey('view-auth-fallback'));
        } else if (isAdmin) {
          // Administrative Workspace Layout (Admin, Staff, Super Admin, Employer)
          activeWidget = const AdminWorkspaceLayout(key: ValueKey('view-portal-admin'));
        } else {
          // Alumni Workspace Layout (Alumni, Student, Faculty)
          activeWidget = const AlumniWorkspaceLayout(key: ValueKey('view-portal-alumni'));
        }
        break;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: activeWidget,
      ),
    );
  }
}
}

/// Backwards compatibility alias for MainNavigationShell
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const StateDrivenAppShell();
  }
}
