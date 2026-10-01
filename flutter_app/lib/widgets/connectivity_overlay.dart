import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import 'offline_fullscreen_overlay.dart';

/// ConnectivityOverlay wraps the application root or any screen tree to monitor
/// network state in real time using the `connectivity_plus` package.
///
/// Behavior:
/// - When the connection is lost: Displays a full-screen, branded 'Cecilian Alumnet'
///   offline message overlay that protects user state and provides offline resources.
/// - When the connection is restored: Automatically hides the full-screen overlay,
///   clears offline banners, and seamlessly returns the user to their active workspace.
class ConnectivityOverlay extends StatefulWidget {
  final Widget child;

  /// Global controller allowing programmatic override or external triggers if needed.
  static final ValueNotifier<bool> isOfflineOverlayVisible = ValueNotifier<bool>(false);

  /// Programmatically display the offline overlay
  static void show() {
    isOfflineOverlayVisible.value = true;
  }

  /// Programmatically hide the offline overlay
  static void hide() {
    isOfflineOverlayVisible.value = false;
  }

  const ConnectivityOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  bool _isOffline = false;
  bool _overlayDismissed = false;
  bool _isChecking = false;
  bool _showRestoredBanner = false;
  Timer? _restoredBannerTimer;

  @override
  void initState() {
    super.initState();
    ConnectivityOverlay.isOfflineOverlayVisible.addListener(_onGlobalVisibilityChanged);
    _initConnectivityMonitor();
  }

  @override
  void dispose() {
    ConnectivityOverlay.isOfflineOverlayVisible.removeListener(_onGlobalVisibilityChanged);
    _connectivitySubscription?.cancel();
    _restoredBannerTimer?.cancel();
    super.dispose();
  }

  void _onGlobalVisibilityChanged() {
    if (!mounted) return;
    final bool globalVisible = ConnectivityOverlay.isOfflineOverlayVisible.value;
    if (globalVisible && !_isOffline) {
      setState(() {
        _isOffline = true;
        _overlayDismissed = false;
      });
    } else if (!globalVisible && _isOffline) {
      setState(() {
        _isOffline = false;
        _overlayDismissed = false;
      });
    }
  }

  /// Initialize connectivity monitoring via connectivity_plus
  Future<void> _initConnectivityMonitor() async {
    // 1. Initial connectivity check
    try {
      final dynamic initialResult = await _connectivity.checkConnectivity();
      final bool offline = _evaluateIsOffline(initialResult);
      if (mounted) {
        setState(() {
          _isOffline = offline;
          _overlayDismissed = false;
        });
        ConnectivityOverlay.isOfflineOverlayVisible.value = offline;
      }
    } catch (e) {
      debugPrint('[ConnectivityOverlay] Initial check error: $e');
    }

    // 2. Real-time stream listener for network state changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((dynamic result) {
      _handleConnectivityResult(result);
    });
  }

  /// Evaluates whether the connectivity result indicates an offline state.
  /// Handles both List<ConnectivityResult> (connectivity_plus v6+) and single ConnectivityResult.
  bool _evaluateIsOffline(dynamic result) {
    if (result is List<ConnectivityResult>) {
      if (result.isEmpty) return true;
      // Offline if every result is ConnectivityResult.none
      return result.every((r) => r == ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      return result == ConnectivityResult.none;
    }
    return false;
  }

  /// Handles incoming network state changes:
  /// - Automatically displays overlay when connection is lost
  /// - Automatically hides overlay when connection is restored
  void _handleConnectivityResult(dynamic result) {
    if (!mounted) return;
    final bool offlineNow = _evaluateIsOffline(result);

    if (_isOffline != offlineNow) {
      setState(() {
        _isOffline = offlineNow;
        if (offlineNow) {
          // Connection lost: show full-screen branded overlay
          _overlayDismissed = false;
          _showRestoredBanner = false;
        } else {
          // Connection restored: automatically hide overlay & show brief restored toast
          _overlayDismissed = false;
          _showRestoredBanner = true;
        }
      });

      ConnectivityOverlay.isOfflineOverlayVisible.value = offlineNow;

      if (!offlineNow) {
        // Automatically hide restored banner after 3.5 seconds
        _restoredBannerTimer?.cancel();
        _restoredBannerTimer = Timer(const Duration(milliseconds: 3500), () {
          if (mounted) {
            setState(() => _showRestoredBanner = false);
          }
        });
      }
    }
  }

  /// User action: Manual connectivity check/retry
  Future<void> _handleRetry() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final dynamic result = await _connectivity.checkConnectivity();
      _handleConnectivityResult(result);
    } catch (e) {
      debugPrint('[ConnectivityOverlay] Retry check error: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showFullScreen = _isOffline && !_overlayDismissed;
    final bool showTopPill = _isOffline && _overlayDismissed;

    return Stack(
      children: [
        // 1. Root Application Content (preserves form inputs and navigation state)
        widget.child,

        // 2. Ambient Minimized Offline Indicator (when user taps 'Browse Cached Portal')
        if (showTopPill)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1917), // Rich Charcoal
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8B181B).withOpacity(0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B181B).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Color(0xFFFCD34D),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Offline Mode Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              'Browsing cached Cecilian Alumnet data',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _overlayDismissed = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B181B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OPEN HUB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 3. Restored Connection Toast (automatically appears when connection is restored)
        if (_showRestoredBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46), // Deep Emerald
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Back Online — Alumni network synchronized.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showRestoredBanner = false),
                        child: const Icon(Icons.close, color: Colors.white70, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Full-Screen, Branded 'Cecilian Alumnet' Offline Message Overlay
        // Automatically hides once connection is restored
        if (showFullScreen)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Material(
                type: MaterialType.transparency,
                child: OfflineFullscreenOverlay(
                  onDismiss: () {
                    // Allows user to browse cached portal with top banner
                    setState(() => _overlayDismissed = true);
                  },
                  onRetry: _handleRetry,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
