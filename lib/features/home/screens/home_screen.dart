import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_gradient_container.dart';
import '../../sos/screens/sos_screen.dart';
import '../../gps/screens/gps_screen.dart';
import '../../incident/screens/incident_screen.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<Offset>> _slideAnims;
  late Animation<double> _fadeAnim;

  String _userName = 'User';
  String _userPhone = '';
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _slideAnims = List.generate(4, (i) {
      final start = (0.2 + i * 0.12).clamp(0.0, 0.9);
      final end = (0.5 + i * 0.12).clamp(0.1, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _animController.forward();
  }

  Future<void> _fetchUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          setState(() {
            _userName = doc['name'] ?? 'User';
            _userPhone = doc['phone'] ?? doc['mobile'] ?? '';
          });
        }
      }
    } catch (_) {}
    setState(() => _loadingUser = false);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.secondary, AppTheme.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Bar ──────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Row(
                    children: [
                      AppAvatar(
                        initials: _userName.isNotEmpty ? _userName[0] : 'U',
                        size: 46,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _loadingUser
                                ? Container(
                                  width: 100,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                )
                                : Text(
                                  'Hello, $_userName 👋',
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            const SizedBox(height: 2),
                            Text(
                              _userPhone.isNotEmpty
                                  ? '+91 $_userPhone'
                                  : 'Sentinel User',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppBadge(
                        label: 'Protected',
                        color: AppTheme.success,
                        icon: Icons.shield_rounded,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.find<AuthController>().logout(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── SOS Big Button ────────────────────────
                SlideTransition(
                  position: _slideAnims[0],
                  child: GestureDetector(
                    onTap: () => Get.to(() => const SosScreen()),
                    child: AppGradientContainer(
                      colors: [AppTheme.primary, AppTheme.accent],
                      borderRadius: 20,
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          _PulsingIcon(),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SOS EMERGENCY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tap to trigger emergency alert',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Quick Actions Title ───────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Feature Grid ──────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnims[1],
                        child: _FeatureCard(
                          icon: Icons.location_on_rounded,
                          label: 'GPS\nTracking',
                          color: const Color(0xFF2196F3),
                          onTap: () => Get.to(() => const GpsScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnims[2],
                        child: _FeatureCard(
                          icon: Icons.report_rounded,
                          label: 'Incident\nReport',
                          color: const Color(0xFFFF9800),
                          onTap: () => Get.to(() => const IncidentScreen()),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Stats Row ─────────────────────────────
                SlideTransition(
                  position: _slideAnims[3],
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.warning_amber_rounded,
                          label: 'SOS Events',
                          color: AppTheme.primary,
                          collectionPath: 'sos_events',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.folder_open_rounded,
                          label: 'Incidents',
                          color: AppTheme.warning,
                          collectionPath: 'incidents',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Recent Activity ───────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _RecentSosList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pulsing SOS Icon ─────────────────────────────────────────
class _PulsingIcon extends StatefulWidget {
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.85,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: const Center(
          child: Text(
            'SOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Feature Card ─────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            Icons.arrow_forward_rounded,
            color: color.withOpacity(0.7),
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String collectionPath;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.collectionPath,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(collectionPath)
                .where('uid', isEqualTo: uid)
                .snapshots(),
        builder: (context, snap) {
          final count = snap.data?.docs.length ?? 0;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Recent SOS List ───────────────────────────────────────────
class _RecentSosList extends StatelessWidget {
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  _RecentSosList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('sos_events')
              .where('uid', isEqualTo: _uid)
              .orderBy('timestamp', descending: true)
              .limit(3)
              .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          );
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.success.withOpacity(0.7),
                  size: 28,
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Clear',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'No SOS events triggered yet',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final ts = data['timestamp'] as Timestamp?;
                final time =
                    ts != null
                        ? TimeOfDay.fromDateTime(ts.toDate()).format(context)
                        : '--:--';
                final date =
                    ts != null
                        ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                        : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    hasBorder: true,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SOS Triggered',
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$date at $time',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppBadge(
                          label: 'SOS',
                          color: AppTheme.primary,
                          icon: Icons.warning_rounded,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
