// 검색 기능을 담당하는 서비스 파일입니다.
// 토픽 검색 및 검색 결과 처리를 담당합니다.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

/// 검색 서비스 클래스
class SearchService {
  static const Duration _timeout = Duration(seconds: 30);
  
  /// 토픽 검색으로 뉴스 데이터를 가져오는 함수
  static Future<Map<String, dynamic>> searchNewsData(String topic) async {
    try {
      final url = '${AppConfig.baseUrl}/play';
      debugPrint('검색 API 호출 시작: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'topic': topic, 'scriptLength': 'LONG'}),
      ).timeout(_timeout);
      
      debugPrint('검색 API 응답 상태: ${response.statusCode}');
      
      if (response.statusCode == 500) {
        debugPrint('서버 내부 오류 발생 - 테스트 데이터 사용');
        return _getTestData();
      }
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('검색 API 호출 실패: $e - 테스트 데이터 사용');
      return _getTestData();
    }
  }

  /// 서버 응답 처리
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }
    final jsonResponse = _parseJsonResponse(response.body);
    return _extractData(jsonResponse);
  }

  /// JSON 파싱
  static Map<String, dynamic> _parseJsonResponse(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('JSON 파싱 오류: $e');
    }
  }

  /// 데이터 추출
  static Map<String, dynamic> _extractData(Map<String, dynamic> jsonResponse) {
    debugPrint('전체 API 응답: $jsonResponse');
    final data = jsonResponse['data'];
    debugPrint('데이터 부분: $data');
    
    if (data != null && data['script'] != null) {
      final script = data['script'] as String;
      final audioUrl = _extractAudioUrl(data);
      
      // 추천 뉴스 데이터 추출 - 다양한 키 이름 시도
      List<Map<String, String>> recommendedNews = [];
      
      // 가능한 키 이름들
      final possibleKeys = ['recommendedNews', 'recommended_news', 'relatedNews', 'related_news', 'news', 'sourcenews', 'sourceNews'];
      
      for (final key in possibleKeys) {
        final newsList = data[key] as List<dynamic>?;
        if (newsList != null && newsList.isNotEmpty) {
          debugPrint('추천 뉴스 키 "$key"에서 데이터 발견: $newsList');
          
          for (int i = 0; i < newsList.length; i++) {
            final item = newsList[i];
            debugPrint('뉴스 아이템 $i: $item');
            
            if (item is Map<String, dynamic>) {
              // 다양한 URL 키 이름 시도
              String? url;
              final urlKeys = ['url', 'link', 'href', 'source'];
              for (final urlKey in urlKeys) {
                if (item[urlKey] != null) {
                  url = item[urlKey].toString();
                  debugPrint('URL 키 "$urlKey"에서 발견: $url');
                  break;
                }
              }
              
              final title = item['title']?.toString() ?? item['headline']?.toString() ?? '';
              if (title.isNotEmpty) {
                recommendedNews.add({
                  'title': title,
                  'url': url ?? '',
                });
                debugPrint('추가된 뉴스: $title - $url');
              }
            }
          }
          break; // 첫 번째로 발견된 키 사용
        }
      }
      
      debugPrint('최종 파싱된 추천 뉴스: $recommendedNews');
      return {
        'script': script,
        'audioUrl': audioUrl,
        'recommendedNews': recommendedNews,
      };
    }
    throw Exception('스크립트 데이터를 찾을 수 없습니다.');
  }

  /// 테스트 데이터 반환
  static Map<String, dynamic> _getTestData() {
    return {
      'script': '안녕하세요! SWEN 뉴스입니다. 현재 서버에서 뉴스를 가져오는 중입니다. 잠시만 기다려주세요. (테스트 모드)',
      'audioUrl': 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
      'recommendedNews': [
        {
          'title': '서버 연결 중 - 잠시만 기다려주세요',
          'url': 'https://www.google.com',
        },
        {
          'title': '네트워크 상태를 확인해주세요',
          'url': 'https://www.naver.com',
        },
        {
          'title': '곧 정상적인 뉴스를 제공할 예정입니다',
          'url': 'https://www.daum.net',
        },
        {
          'title': 'SWEN 앱을 이용해주셔서 감사합니다',
          'url': 'https://www.youtube.com',
        },
        {
          'title': '더 나은 서비스를 위해 노력하겠습니다',
          'url': 'https://www.github.com',
        },
      ],
    };
  }

  /// 오디오 URL 추출
  static String _extractAudioUrl(Map<String, dynamic> data) {
    final audioUrlKeys = ['audioUrl', 'audio_url', 'audioFileUrl'];
    for (final key in audioUrlKeys) {
      final url = data[key];
      if (url != null && url is String && url.isNotEmpty) {
        return url;
      }
    }
    return '';
  }
} 