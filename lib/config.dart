/// 앱 설정 관리
class AppConfig {
  /// 현재 환경
  static const Environment environment = Environment.development;
  
  /// 환경별 서버 주소
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://10.0.2.2:8080/api/v1/news/play';
      case Environment.staging:
        return 'https://staging-api.your-domain.com/api/v1/news/play';
      case Environment.production:
        return 'https://api.your-domain.com/api/v1/news/play';
    }
  }
  
  /// 앱 이름
  static const String appName = '뉴스 오디오 플레이어';
  
  /// 앱 버전
  static const String appVersion = '1.0.0';
}

/// 환경 타입
enum Environment {
  development,  // 개발용 (에뮬레이터)
  staging,      // 스테이징용
  production,   // 배포용
} 