import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? color;

  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color ?? AppTheme.primary,
            color?.withOpacity(0.6) ?? AppTheme.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}