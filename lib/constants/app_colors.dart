import 'package:flutter/material.dart';

/// 앱에서 사용하는 색상 상수들
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1565C0); // Colors.blue[900]
  static const Color primaryLight = Color(0xFF1976D2); // Colors.blue[700]
  static const Color primaryDark = Color(0xFF0D47A1); // Colors.blue[900]
  
  // Secondary Colors
  static const Color secondary = Color(0xFF26A69A); // Colors.teal[500]
  
  // Background Colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color card = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF424242); // Colors.grey[800]
  static const Color textSecondary = Color(0xFF757575); // Colors.grey[600]
  static const Color textHint = Color(0xFFBDBDBD); // Colors.grey[400]
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color divider = Color(0xFFEEEEEE); // Colors.grey[200]
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Colors.green[500]
  static const Color warning = Color(0xFFFF9800); // Colors.orange[500]
  static const Color error = Color(0xFFD32F2F); // Colors.red[600]
  static const Color info = Color(0xFF2196F3); // Colors.blue[500]
  
  // Interactive Colors
  static const Color link = Color(0xFF1976D2); // Colors.blue[700]
  static const Color button = Color(0xFF1565C0); // Colors.blue[900]
  static const Color buttonText = Colors.white;
} 