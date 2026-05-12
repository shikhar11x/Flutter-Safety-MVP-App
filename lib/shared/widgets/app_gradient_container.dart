import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppGradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final double borderRadius;
  final EdgeInsets? padding;

  const AppGradientContainer({
    super.key,
    required this.child,
    this.colors,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors ??
              [
                AppTheme.primary.withOpacity(0.8),
                AppTheme.accent.withOpacity(0.6),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}