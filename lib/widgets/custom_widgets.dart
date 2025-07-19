import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 재사용 가능한 커스텀 위젯들을 정의하는 파일
class CustomWidgets {
  /// 로딩 인디케이터 위젯
  static Widget loadingIndicator({
    double size = AppSizes.iconSizeL,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }

  /// 기본 컨테이너 스타일
  static BoxDecoration defaultContainerDecoration({
    Color? borderColor,
    Color? backgroundColor,
    double borderRadius = AppSizes.radiusM,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor ?? AppColors.border,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      color: backgroundColor ?? AppColors.background,
    );
  }

  /// 기본 버튼 스타일
  static ButtonStyle defaultButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = AppSizes.radiusL,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// 기본 텍스트 스타일
  static TextStyle defaultTextStyle({
    double fontSize = AppSizes.fontSizeBody,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? AppColors.textPrimary,
      fontWeight: fontWeight,
    );
  }

  /// 구분선 위젯
  static Widget divider({double height = AppSizes.spacingL}) {
    return SizedBox(height: height);
  }

  /// 아이콘 버튼 위젯
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = AppSizes.iconSizeM,
    Color? color,
    String? tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size),
      color: color ?? AppColors.primary,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 30,
      ),
    );
  }
} 