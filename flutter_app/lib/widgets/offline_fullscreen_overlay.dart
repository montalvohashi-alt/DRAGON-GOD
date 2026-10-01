import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/alumni_repository.dart';
import '../services/connectivity_service.dart';

class OfflineFullscreenOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final Future<void> Function() onRetry;

  const OfflineFullscreenOverlay({
    super.key,
    required this.onDismiss,
    required this.onRetry,
  });

  @override
  State<OfflineFullscreenOverlay> createState() => _OfflineFullscreenOverlayState();
}

class _OfflineFullscreenOverlayState extends State<OfflineFullscreenOverlay> {
  int _activeTabIndex = 0;
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);
    await widget.onRetry();
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AlumniRepository? repo;
    try {
      repo = context.watch<AlumniRepository>();
    } catch (_) {
      repo = null;
    }
    final user = repo?.currentUser;

    return Container(
      color: const Color(0xFF121316).withOpacity(0.97),
      child: SafeArea(
        child: Column(
          children: [
            // Top Status Alert Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF8B181B),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.wifi_off_rounded, color: Color(0xFFFCD34D), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offline Mode Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Disconnected from cloud network. Using cached Cecilian data.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B181B),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isChecking ? null : _handleRetry,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B181B)),
                          )
                        : const Icon(Icons.refresh, size: 14),
                    label: Text(
                      _isChecking ? 'Checking...' : 'Retry',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Header Brand Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/cecilians-seal.jpg',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        width: 42,
                        height: 42,
                        color: const Color(0xFF8B181B),
                        child: const Center(
                          child: Text('SCC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cecilian Alumnet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'OFFLINE',
                              style: TextStyle(
                                color: Color(0xFFFCD34D),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "St. Cecilia's College - Cebu, Inc. • Global Alumni Network",
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close, color: Colors.white70),
                    tooltip: 'Dismiss Overlay',
                  ),
                ],
              ),
            ),

            // Navigation Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton(0, 'Overview', Icons.info_outline),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Directory', Icons.apartment_outlined),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Alma Mater', Icons.menu_book_outlined),
                  const SizedBox(width: 8),
                  _buildTabButton(3, 'Digital Pass', Icons.badge_outlined),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),

            // Tab Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildActiveTabContent(user),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF181615),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: widget.onDismiss,
                      child: const Text('Browse Cached Portal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B181B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isChecking ? null : _handleRetry,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.wifi_find_rounded, size: 16),
                      label: Text(_isChecking ? 'Checking...' : 'Check Connection', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B181B) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF8B181B) : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(dynamic user) {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildDirectoryTab();
      case 2:
        return _buildAlmaMaterTab();
      case 3:
      default:
        return _buildDigitalPassTab(user);
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LOCAL REPOSITORIES READY',
                style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              const Text(
                'Full Offline Resilience Active',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cecilian Alumnet caches essential alumni directories, campus emergency numbers, identity credentials, and collegiate records locally on your device.',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard('Network Monitor', 'connectivity_plus', Icons.network_check),
                  const SizedBox(width: 10),
                  _buildStatCard('Offline Storage', 'Cached & Ready', Icons.save_outlined),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF8B181B).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B181B).withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.autorenew_rounded, color: Color(0xFFFCA5A5), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Auto-Restore Enabled — This overlay will automatically dismiss and synchronize your workspace the moment internet connection is detected.',
                  style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 11.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CACHED CAMPUS DIRECTORY',
          style: TextStyle(color: Color(0xFFFCD34D), fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        _buildDirectoryCard(
          title: "St. Cecilia's College - Cebu, Inc.",
          role: 'Main Institutional Campus',
          phone: '+63 (032) 272-8989',
          address: 'Poblacion Ward II, Minglanilla, Cebu 6046',
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 10),
        _buildDirectoryCard(
          title: 'Alumni Affairs & Registrar',
          role: 'Transcript & Records Hotline',
          phone: '+63 (032) 272-8990 (Ext. 104)',
          address: 'Ground Floor, Administration Building',
          icon: Icons.history_edu_outlined,
        ),
        const SizedBox(height: 10),
        _buildDirectoryCard(
          title: 'Campus Safety & Gate Security',
          role: '24/7 Gate & Alumni Visitor Access',
          phone: '+63 (032) 272-8991 (24/7 Desk)',
          address: 'Main Entrance Canopy',
          icon: Icons.shield_outlined,
        ),
      ],
    );
  }

  Widget _buildDirectoryCard({
    required String title,
    required String role,
    required String phone,
    required String address,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B181B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFCA5A5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(role, style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 10.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white54, size: 12),
                    const SizedBox(width: 6),
                    Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white54, size: 12),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(address, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
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

  Widget _buildAlmaMaterTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              const Text(
                'THE CECILIAN HYMN',
                style: TextStyle(color: Color(0xFFFCD34D), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hail to thee, our Alma Mater,\nBeacon light upon our way.\nGuiding youth with truth and honor,\nLeading into brighter day.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6, fontStyle: FontStyle.italic),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(width: 40, child: Divider(color: Colors.white24)),
              ),
              const Text(
                'In your halls we learned to cherish,\nVirtue, Wisdom, Love profound.\nThough in distant lands we flourish,\nHere our proudest roots are found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6, fontStyle: FontStyle.italic),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(width: 40, child: Divider(color: Colors.white24)),
              ),
              const Text(
                'Chorus:\nSt. Cecilia, beloved Mother,\nWe will keep your banner high!\nCecilians one and all forever,\nLoyal till the end of time!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 13, height: 1.6, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalPassTab(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B181B), Color(0xFF600F12), Color(0xFF181615)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B181B).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/cecilians-seal.jpg', width: 34, height: 34, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cecilian Alumnet', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('OFFLINE DIGITAL PASS', style: TextStyle(color: Color(0xFFFCD34D), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.emerald.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.emerald.withOpacity(0.4)),
                ),
                child: const Text('OFFLINE VALID', style: TextStyle(color: Colors.emeraldAccent, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('ALUMNI MEMBER', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 2),
          Text(
            user != null ? '${user.firstName} ${user.lastName}' : 'Cecilian Alumni Member',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MEMBER ID', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(
                      user?.alumniId ?? 'SCC-ALUM-2024-OFFLINE',
                      style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BATCH / YEAR', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(
                      user?.batchYear != null ? 'Batch ${user.batchYear}' : 'Distinguished Alumni',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Present at Campus Gate for Verification', style: TextStyle(color: Colors.white60, fontSize: 10)),
              Text('OFFLINE ID', style: TextStyle(color: Color(0xFFFCD34D), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
