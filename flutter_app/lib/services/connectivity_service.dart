import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Real-time Connectivity Monitor using connectivity_plus
/// Mirrors the web portal's offline detection and recovery notifications
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  bool _isOnline = true;
  bool _hasInitialCheck = false;
  String? _lastToastMessage;

  bool get isOnline => _isOnline;
  String? get lastToastMessage => _lastToastMessage;

  // Global key for dispatching subtle collegiate toasts anywhere in the app
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  ConnectivityService() {
    _initConnectivity();
    _listenToConnectivity();
  }

  Future<bool> checkConnectivity() async {
    try {
      final dynamic result = await _connectivity.checkConnectivity();
      final bool nowOnline = _evaluateConnectivity(result);
      if (_hasInitialCheck && nowOnline != _isOnline) {
        _isOnline = nowOnline;
        notifyListeners();
        _showConnectivityToast(nowOnline);
      } else {
        _isOnline = nowOnline;
        _hasInitialCheck = true;
        notifyListeners();
      }
      return _isOnline;
    } catch (e) {
      debugPrint('[ConnectivityService] Error checking status: $e');
      return _isOnline;
    }
  }

  Future<void> _initConnectivity() async {
    await checkConnectivity();
  }

  void _listenToConnectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen((dynamic result) {
      final bool nowOnline = _evaluateConnectivity(result);

      // Only dispatch toast if the status actually transitioned after initial check
      if (_hasInitialCheck && nowOnline != _isOnline) {
        _isOnline = nowOnline;
        notifyListeners();
        _showConnectivityToast(nowOnline);
      } else {
        _isOnline = nowOnline;
        _hasInitialCheck = true;
        notifyListeners();
      }
    });
  }

  bool _evaluateConnectivity(dynamic result) {
    if (result is List<ConnectivityResult>) {
      if (result.isEmpty) return false;
      // Online if any connection is NOT 'none'
      return result.any((r) => r != ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return true;
  }

  void _showConnectivityToast(bool online) {
    final state = messengerKey.currentState;
    if (state == null) return;

    state.hideCurrentSnackBar();

    if (!online) {
      _lastToastMessage = 'Offline Mode — Cached data is being used.';
      state.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFFD97706), // Warm Amber
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 76),
          content: Row(
            children: const [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Offline Mode — Cached Cecilian portal data is being used.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      _lastToastMessage = 'Back Online — Alumni network synchronized.';
      state.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF059669), // Emerald
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 76),
          content: Row(
            children: const [
              Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Back Online — Connection restored. Alumni network synchronized.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
