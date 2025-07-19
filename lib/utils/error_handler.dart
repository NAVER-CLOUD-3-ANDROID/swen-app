import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 에러 처리를 담당하는 유틸리티 클래스
class ErrorHandler {
  /// 에러 스낵바를 표시하는 메서드
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(milliseconds: AppSizes.durationSnackBar),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
    );
  }

  /// 뉴스 로드 에러 메시지 생성
  static String getNewsLoadErrorMessage(dynamic error) {
    return '${AppStrings.newsLoadError}$error';
  }

  /// 검색 에러 메시지 생성
  static String getSearchErrorMessage(dynamic error) {
    return '${AppStrings.searchError}$error';
  }

  /// 검색어 유효성 검사
  static bool isValidSearchQuery(String query) {
    return query.trim().isNotEmpty;
  }

  /// URL 유효성 검사 (HTTP/HTTPS 포함)
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    // URL 정규화
    String normalizedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      normalizedUrl = 'https://$url';
    }
    
    try {
      final uri = Uri.parse(normalizedUrl);
      return uri.hasScheme && uri.hasAuthority && uri.host.isNotEmpty;
    } catch (e) {
      debugPrint('URL 검증 실패: $url - 오류: $e');
      return false;
    }
  }
  
  /// URL 정규화 (HTTP/HTTPS 프로토콜 추가)
  static String normalizeUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // HTTP 링크가 더 안정적일 수 있으므로 HTTP를 우선으로 시도
    return 'http://$url';
  }
} 