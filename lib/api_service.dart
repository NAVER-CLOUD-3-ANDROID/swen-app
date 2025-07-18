import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

/// API 관련 상수
class ApiConstants {
  /// 서버 주소 설정
  /// 
  /// 개발용 (에뮬레이터):
  /// - Android 에뮬레이터: http://10.0.2.2:8080/api/v1/news/play
  /// - iOS 시뮬레이터: http://localhost:8080/api/v1/news/play
  /// 
  /// 배포용 (실제 기기):
  /// - 실제 서버 IP: http://192.168.1.100:8080/api/v1/news/play
  /// - 도메인: https://your-domain.com/api/v1/news/play
  static String get baseUrl => AppConfig.baseUrl;
  
  /// API 응답 키
  static const String scriptKey = 'script';
  static const String dataKey = 'data';
  static const String statusKey = 'status';
  
  /// 오디오 URL 관련 키들
  static const List<String> audioUrlKeys = ['audioUrl', 'audio_url', 'audioFileUrl'];
}

/// API 서비스 클래스
class ApiService {
  /// 스크립트와 오디오 URL을 API에서 가져옵니다
  static Future<Map<String, dynamic>> fetchNewsData() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.baseUrl));
      return _handleResponse(response);
    } catch (e) {
      // API 서버 연결 실패 시 임시 테스트 데이터 반환
      // print('API 서버 연결 실패: $e');
      // print('임시 테스트 데이터를 사용합니다.');
      return _getTestData();
    }
  }

  /// HTTP 응답을 처리합니다
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }

    final jsonResponse = _parseJsonResponse(response.body);
    return _extractData(jsonResponse);
  }

  /// JSON 응답을 파싱합니다
  static Map<String, dynamic> _parseJsonResponse(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('JSON 파싱 오류: $e');
    }
  }

  /// JSON에서 데이터를 추출합니다
  static Map<String, dynamic> _extractData(Map<String, dynamic> jsonResponse) {
    // 실제 API 응답 구조: {status: 200, data: {...}}
    if (jsonResponse.containsKey(ApiConstants.statusKey) && 
        jsonResponse.containsKey(ApiConstants.dataKey)) {
      final data = jsonResponse[ApiConstants.dataKey];
      if (data != null && data[ApiConstants.scriptKey] != null) {
        return data as Map<String, dynamic>;
      }
    }
    
    // 기존 구조 (하위 호환성)
    final data = jsonResponse[ApiConstants.dataKey];
    if (data != null && data[ApiConstants.scriptKey] != null) {
      return data as Map<String, dynamic>;
    }

    throw Exception('스크립트 데이터를 찾을 수 없습니다.');
  }

  /// 임시 테스트 데이터를 반환합니다
  static Map<String, dynamic> _getTestData() {
    return {
      ApiConstants.scriptKey: '오늘은 날씨가 좋네요! Flutter 앱이 정상적으로 작동하고 있습니다. API 서버가 연결되면 실제 뉴스 스크립트가 표시됩니다.',
      'audioUrl': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
    };
  }
  
  /// 여러 가능한 오디오 URL 필드에서 URL을 추출합니다
  static String extractAudioUrl(Map<String, dynamic> data) {
    for (final key in ApiConstants.audioUrlKeys) {
      final url = data[key];
      if (url != null && url is String && url.isNotEmpty) {
        return url;
      }
    }
    return '';
  }
}

// 기존 함수 호환성을 위한 래퍼 함수
Future<Map<String, String>> fetchScriptAndAudioUrl() async {
  final data = await ApiService.fetchNewsData();
  return {
    ApiConstants.scriptKey: data[ApiConstants.scriptKey] as String,
    'audioUrl': ApiService.extractAudioUrl(data),
  };
} 