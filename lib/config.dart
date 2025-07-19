/// 앱 설정 관리
class AppConfig {
  /// 현재 환경
  static const Environment environment = Environment.development;
  
  /// 환경별 서버 주소 (캐시된 값)
  static String? _cachedBaseUrl;
  static String get baseUrl {
    _cachedBaseUrl ??= _getBaseUrlForEnvironment();
    return _cachedBaseUrl!;
  }
  
  /// 환경별 URL 생성
  static String _getBaseUrlForEnvironment() {
    switch (environment) {
      case Environment.development:
        // 개발 서버 주소 - 실제 기기용
        return 'http://192.168.219.105:8080/api/v1/news';
      case Environment.staging:
        return 'https://staging-api.your-domain.com/api/v1/news/play';
      case Environment.production:
        return 'https://api.your-domain.com/api/v1/news/play';
    }
  }
  
  /// 앱 정보
  static const String appName = 'SWEN';
  static const String appVersion = '1.0.0';
}

/// 환경 타입
enum Environment {
  development,  // 개발용 (에뮬레이터)
  staging,      // 스테이징용
  production,   // 배포용
} 