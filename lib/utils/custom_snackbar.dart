import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';

enum SnackBarType { success, error, info }

void showCustomSnackBar(
  String message, {
  SnackBarType type = SnackBarType.success,
  Duration duration = const Duration(seconds: 3),
}) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getIconColor(type).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getIconColor(type).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(type),
                    color: _getIconColor(type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

IconData _getIcon(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return Icons.check_circle_outline;
    case SnackBarType.error:
      return Icons.error_outline;
    case SnackBarType.info:
      return Icons.info_outline;
  }
}

Color _getIconColor(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return const Color(0xFF00FF94); // Neon yeşil
    case SnackBarType.error:
      return const Color(0xFFFF3366); // Neon kırmızı
    case SnackBarType.info:
      return const Color(0xFF00D9FF); // Neon mavi
  }
}
