import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_badge.dart';
import '../controllers/sos_controller.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SosController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textLight),
          onPressed: () {
            controller.reset();
            Get.back();
          },
        ),
        title: const Text(
          'SOS Emergency',
          style: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.sosSent.value) {
          return _SosSuccessView(controller: controller);
        }
        return _SosTriggerView(controller: controller);
      }),
    );
  }
}

// ── Trigger View ─────────────────────────────────────────────
class _SosTriggerView extends StatelessWidget {
  final SosController controller;
  const _SosTriggerView({required this.controller});

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.primary, size: 26),
            SizedBox(width: 10),
            Text(
              'Confirm SOS',
              style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will trigger an emergency alert and save your current location. Are you sure?',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.triggerSos();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Send SOS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const Spacer(),

            // ── Pulsing SOS Button ────────────────────────
            _PulsingSOSButton(
              onTap: () => _showConfirmDialog(context),
            ),

            const SizedBox(height: 32),

            const Text(
              'Press the button to\ntrigger emergency alert',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const Spacer(),

            // ── Info Cards ────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    color: const Color(0xFF2196F3),
                    text: 'Your GPS location will be saved',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    color: AppTheme.warning,
                    text: 'Exact timestamp will be recorded',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.cloud_done_rounded,
                    color: AppTheme.success,
                    text: 'Event saved to secure database',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Error
            Obx(() => controller.errorMessage.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Success View ─────────────────────────────────────────────
class _SosSuccessView extends StatelessWidget {
  final SosController controller;
  const _SosSuccessView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final time = controller.lastSosTime.value;
    final formattedDate = time != null
        ? DateFormat('dd MMM yyyy').format(time)
        : '--';
    final formattedTime = time != null
        ? DateFormat('hh:mm:ss a').format(time)
        : '--';
    final latVal = controller.lat?.value ?? 0.0;
    final lngVal = controller.lng?.value ?? 0.0;
    final hasLocation = latVal != 0.0 || lngVal != 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const Spacer(),

            // ── Success Icon ──────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.success.withOpacity(0.15),
                border: Border.all(
                  color: AppTheme.success.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.success,
                size: 52,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'SOS Alert Sent!',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your emergency alert has been recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 32),

            // ── Details Card ──────────────────────────────
            AppCard(
              hasBorder: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Date
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: formattedDate,
                    color: const Color(0xFF2196F3),
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Time
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: formattedTime,
                    color: AppTheme.warning,
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // Location
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value: hasLocation
                        ? '${latVal.toStringAsFixed(5)}, ${lngVal.toStringAsFixed(5)}'
                        : 'Not available',
                    color: AppTheme.success,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Status Badge ──────────────────────────────
            AppBadge(
              label: 'Saved to Database',
              color: AppTheme.success,
              icon: Icons.cloud_done_rounded,
            ),

            const SizedBox(height: 24),

            // ── Buttons ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.reset();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surface,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.reset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Send Another SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing SOS Button ────────────────────────────────────────
class _PulsingSOSButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PulsingSOSButton({required this.onTap});

  @override
  State<_PulsingSOSButton> createState() => _PulsingSOSButtonState();
}

class _PulsingSOSButtonState extends State<_PulsingSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: false);

    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ring = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Transform.scale(
                scale: _ring.value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(
                        (1.0 - (_ring.value - 1.0) / 0.4).clamp(0.0, 0.4),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Main button
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}