import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Admin Panel',
              style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.find<AuthController>().logout(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.textLight,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.warning_rounded, size: 18),
              text: 'SOS Alerts',
            ),
            Tab(
              icon: Icon(Icons.report_rounded, size: 18),
              text: 'Incidents',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SosTab(),
          _IncidentTab(),
        ],
      ),
    );
  }
}

// ── SOS Tab ──────────────────────────────────────────────────
class _SosTab extends StatelessWidget {
  const _SosTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sos_events')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (snap.hasError) {
          return Center(
            child: Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: AppTheme.primary),
            ),
          );
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.success.withOpacity(0.5),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No SOS alerts yet',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _SosCard(data: data);
          },
        );
      },
    );
  }
}

// ── SOS Card ─────────────────────────────────────────────────
class _SosCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _SosCard({required this.data});

  @override
  State<_SosCard> createState() => _SosCardState();
}

class _SosCardState extends State<_SosCard> {
  String _userName = 'Loading...';
  String _userMobile = '';

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final uid = widget.data['uid'] as String?;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? 'Unknown';
          _userMobile = doc['mobile'] ?? '';
        });
      } else {
        setState(() => _userName = 'Unknown User');
      }
    } catch (_) {
      setState(() => _userName = 'Unknown User');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.data['timestamp'];
    DateTime? dt;
    if (ts != null) {
      try {
        dt = (ts as dynamic).toDate();
      } catch (_) {}
    }

    final hasLocation = widget.data['locationAvailable'] == true;
    final lat = (widget.data['latitude'] ?? 0.0) as double;
    final lng = (widget.data['longitude'] ?? 0.0) as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        hasBorder: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (_userMobile.isNotEmpty)
                        Text(
                          '+91 $_userMobile',
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

            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),

            // Time
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  dt != null
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(dt)
                      : 'Unknown time',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: hasLocation ? AppTheme.success : AppTheme.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasLocation
                        ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
                        : 'Location not available',
                    style: TextStyle(
                      color:
                          hasLocation ? AppTheme.success : AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Incident Tab ─────────────────────────────────────────────
class _IncidentTab extends StatelessWidget {
  const _IncidentTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (snap.hasError) {
          return Center(
            child: Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: AppTheme.primary),
            ),
          );
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  color: AppTheme.textMuted.withOpacity(0.4),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No incidents reported yet',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _IncidentCard(data: data);
          },
        );
      },
    );
  }
}

// ── Incident Card ─────────────────────────────────────────────
class _IncidentCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _IncidentCard({required this.data});

  @override
  State<_IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<_IncidentCard> {
  String _userName = 'Loading...';
  String _userMobile = '';

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final uid = widget.data['uid'] as String?;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? 'Unknown';
          _userMobile = doc['mobile'] ?? '';
        });
      } else {
        setState(() => _userName = 'Unknown User');
      }
    } catch (_) {
      setState(() => _userName = 'Unknown User');
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Theft':
        return const Color(0xFF9C27B0);
      case 'Assault':
        return AppTheme.primary;
      case 'Accident':
        return AppTheme.warning;
      case 'Fire':
        return const Color(0xFFFF5722);
      case 'Medical Emergency':
        return const Color(0xFF2196F3);
      case 'Suspicious Activity':
        return const Color(0xFF607D8B);
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.data['timestamp'];
    DateTime? dt;
    if (ts != null) {
      try {
        dt = (ts as dynamic).toDate();
      } catch (_) {}
    }

    final type = widget.data['type'] ?? 'Unknown';
    final description = widget.data['description'] ?? '';
    final hasLocation = widget.data['locationCaptured'] == true;
    final lat = (widget.data['latitude'] ?? 0.0) as double;
    final lng = (widget.data['longitude'] ?? 0.0) as double;
    final typeColor = _typeColor(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        hasBorder: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.report_rounded,
                    color: typeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (_userMobile.isNotEmpty)
                        Text(
                          '+91 $_userMobile',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                AppBadge(
                  label: type,
                  color: typeColor,
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),

            // Description
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Time
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  dt != null
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(dt)
                      : 'Unknown time',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: hasLocation ? AppTheme.success : AppTheme.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasLocation
                        ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
                        : 'Location not captured',
                    style: TextStyle(
                      color:
                          hasLocation ? AppTheme.success : AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}