import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_badge.dart';
import '../controllers/incident_controller.dart';

class IncidentScreen extends StatelessWidget {
  const IncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IncidentController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textLight),
          onPressed: () {
            controller.reset();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Incident Report',
          style: TextStyle(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isSubmitted.value) {
          return _SuccessView(controller: controller);
        }
        return _FormView(controller: controller);
      }),
    );
  }
}

// ── Form View ─────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final IncidentController controller;
  final TextEditingController _descCtrl = TextEditingController();

  _FormView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Incident Type ────────────────────────────────
          const Text(
            'Incident Type',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => AppCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedType.value,
                    isExpanded: true,
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textMuted,
                    ),
                    items: controller.incidentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedType.value = val;
                    },
                  ),
                ),
              )),

          const SizedBox(height: 24),

          // ── Description ──────────────────────────────────
          const Text(
            'Description',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            style: const TextStyle(color: AppTheme.textLight),
            decoration: InputDecoration(
              hintText: 'Describe what happened...',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFFF9800),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Location ─────────────────────────────────────
          const Text(
            'Location',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: controller.locationCaptured.value
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.textMuted.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: controller.locationCaptured.value
                            ? AppTheme.success
                            : AppTheme.textMuted,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: controller.locationCaptured.value
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location Captured',
                                  style: TextStyle(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${controller.latitude.value.toStringAsFixed(5)}, ${controller.longitude.value.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Location not captured yet',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                    ),
                    controller.isFetchingLocation.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.success,
                              strokeWidth: 2,
                            ),
                          )
                        : TextButton(
                            onPressed: controller.captureLocation,
                            child: Text(
                              controller.locationCaptured.value
                                  ? 'Refresh'
                                  : 'Capture',
                              style: const TextStyle(
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

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

          const SizedBox(height: 12),

          // ── Submit Button ────────────────────────────────
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submitIncident(_descCtrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              )),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final IncidentController controller;
  const _SuccessView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'Report Submitted!',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your incident report has been saved successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            AppBadge(
              label: 'Saved to Database',
              color: AppTheme.success,
              icon: Icons.cloud_done_rounded,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.reset();
                  Navigator.pop(context);
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
                onPressed: controller.reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Submit Another Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}