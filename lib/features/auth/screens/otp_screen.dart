import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends StatelessWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final otpCtrl = TextEditingController();

    final pinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
    );

    final focusedPinTheme = pinTheme.copyWith(
      decoration: pinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Sent to +91 $mobile (simulated)',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              // Static OTP hint
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.warning, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Test OTP: 234567',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Pinput
              Center(
                child: Pinput(
                  length: 6,
                  controller: otpCtrl,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onCompleted: (otp) => controller.verifyOtp(otp),
                ),
              ),

              const SizedBox(height: 12),

              // Error
              Obx(() => controller.errorMessage.value.isNotEmpty
                  ? Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: 32),

              // Verify Button
              Obx(() => AppButton(
                    label: 'Verify OTP',
                    isLoading: controller.isLoading.value,
                    onPressed: () =>
                        controller.verifyOtp(otpCtrl.text.trim()),
                  )),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
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