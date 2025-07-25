// API 통신과 관련된 기능을 모아놓은 파일입니다.
// 서버에서 뉴스 스크립트와 오디오 주소를 받아오는 역할을 합니다.

import 'dart:convert'; // JSON(문자열 ↔ 데이터) 변환에 필요
import 'package:http/http.dart' as http; // 인터넷으로 서버에 요청할 때 필요
import '../config.dart'; // 서버 주소 등 설정값을 가져옴

/// API 관련 상수
class ApiConstants {
  static String get baseUrl => AppConfig.baseUrl;
  static const String scriptKey = 'script';
  static const String dataKey = 'data';
  static const String statusKey = 'status';
  static const List<String> audioUrlKeys = [
    'audioUrl',
    'audio_url',
    'audioFileUrl'
  ];
}

/// API 서비스 클래스
class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  // 요청 URL
  final String backendUrl = 'http://localhost:8080/oauth2/authorization/naver';

  /// 네이버 소셜 로그인 요청 메서드
  /// 실제로는 백엔드 인증 서버로 로그인 요청을 보내고 결과를 받는 구조
  Future<Map<String, dynamic>?> requestNaverLogin() async {
    try {
      final url =
          'http://localhost:8080/api/auth/user'; // 예, 로그인 후 사용자 정보 반환 API
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('사용자 정보 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('사용자 정보 요청 예외: $e');
    }
    return null;
  }

  /// 뉴스 데이터를 가져오는 함수
  static Future<Map<String, dynamic>> fetchNewsData(
      {String? searchQuery}) async {
    try {
      String url;
      http.Response response;

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        // 검색어가 있으면 POST 요청으로 검색
        url = '${ApiConstants.baseUrl}/play';
        print('검색 API 호출 시작: $url (검색어: $searchQuery)');

        response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'topic': searchQuery.trim(),
                'scriptLength': 'long',
              }),
            )
            .timeout(_timeout);
      } else {
        // 검색어가 없으면 기본 GET 요청
        url = '${ApiConstants.baseUrl}/play?scriptLength=LONG';
        print('기본 API 호출 시작: $url');

        response = await http
            .get(
              Uri.parse(url),
            )
            .timeout(_timeout);
      }

      print('API 응답 상태: ${response.statusCode}');

      if (response.statusCode == 500) {
        print('서버 내부 오류 발생 - 테스트 데이터 사용');
        return _getTestData(searchQuery: searchQuery);
      }

      return _handleResponse(response);
    } catch (e) {
      print('API 호출 실패: $e - 테스트 데이터 사용');
      return _getTestData(searchQuery: searchQuery);
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
    print('전체 API 응답: $jsonResponse');
    final data = jsonResponse[ApiConstants.dataKey];
    print('데이터 부분: $data');

    if (data != null && data[ApiConstants.scriptKey] != null) {
      final script = data[ApiConstants.scriptKey] as String;
      final audioUrl = extractAudioUrl(data);

      // 추천 뉴스 데이터 추출 - 다양한 키 이름 시도
      List<Map<String, String>> recommendedNews = [];
      List<Map<String, dynamic>> sourceNews = [];

      // 추천 뉴스 추출 (서버 응답 구조에 맞게 수정)
      final recommendedList = data['recommendedNews'] as List<dynamic>?;
      if (recommendedList != null && recommendedList.isNotEmpty) {
        print('추천 뉴스 데이터 발견: $recommendedList');

        for (int i = 0; i < recommendedList.length; i++) {
          final item = recommendedList[i];
          print('뉴스 아이템 $i: $item');

          if (item is Map<String, dynamic>) {
            final title = item['title']?.toString() ?? '';
            final link = item['link']?.toString() ?? '';

            if (title.isNotEmpty) {
              recommendedNews.add({
                'title': title,
                'url': link,
              });
              print('추가된 뉴스: $title - $link');
            }
          }
        }
      }

      // sourceNews 추출
      final sourceKeys = ['sourceNews', 'sourcenews', 'source_news'];
      for (final key in sourceKeys) {
        final sourceList = data[key] as List<dynamic>?;
        if (sourceList != null && sourceList.isNotEmpty) {
          print('sourceNews 키 "$key"에서 데이터 발견: $sourceList');
          sourceNews = sourceList.cast<Map<String, dynamic>>();
          break;
        }
      }

      print('최종 파싱된 추천 뉴스: $recommendedNews');
      print('최종 파싱된 sourceNews: $sourceNews');
      return {
        'script': script,
        'audioUrl': audioUrl,
        'recommendedNews': recommendedNews,
        'sourceNews': sourceNews,
      };
    }
    throw Exception('스크립트 데이터를 찾을 수 없습니다.');
  }

  /// 테스트 데이터 반환
  static Map<String, dynamic> _getTestData({String? searchQuery}) {
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      // 검색어에 따른 다른 테스트 데이터
      String searchTerm = searchQuery.trim().toLowerCase();

      if (searchTerm.contains('호우') ||
          searchTerm.contains('비') ||
          searchTerm.contains('강우')) {
        return {
          'script':
              '"$searchQuery" 관련 뉴스입니다. 최근 호우와 관련된 기상 상황과 피해 현황을 전해드립니다. 많은 지역에서 강우가 예상되며, 시민들의 안전에 각별한 주의가 필요합니다.',
          'audioUrl':
              'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
          'recommendedNews': [
            {
              'title': '전국 호우 예보, 안전에 주의',
              'url': 'https://weather.naver.com',
            },
            {
              'title': '호우로 인한 교통 지연 발생',
              'url': 'https://www.koroad.or.kr',
            },
            {
              'title': '호우 대비 방재 시스템 점검',
              'url': 'https://www.safekorea.go.kr',
            },
          ],
          'sourceNews': [
            {
              'title': '기상청 호우 특보 발령',
              'link': 'https://www.weather.go.kr',
              'originallink': 'https://www.weather.go.kr',
            },
          ],
        };
      } else if (searchTerm.contains('코로나') || searchTerm.contains('감염')) {
        return {
          'script': '"$searchQuery" 관련 뉴스입니다. 코로나19 상황과 예방 수칙에 대해 전해드립니다.',
          'audioUrl':
              'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
          'recommendedNews': [
            {
              'title': '코로나19 신규 확진자 현황',
              'url': 'https://ncov.kdca.go.kr',
            },
            {
              'title': '코로나19 예방접종 현황',
              'url': 'https://ncv.kdca.go.kr',
            },
          ],
          'sourceNews': [
            {
              'title': '질병관리청 코로나19 정보',
              'link': 'https://ncov.kdca.go.kr',
              'originallink': 'https://ncov.kdca.go.kr',
            },
          ],
        };
      } else {
        return {
          'script': '"$searchQuery"에 대한 검색 결과입니다. 관련 뉴스와 정보를 찾아보았습니다.',
          'audioUrl':
              'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
          'recommendedNews': [
            {
              'title': '"$searchQuery" 관련 뉴스 1',
              'url': 'https://www.google.com/search?q=$searchQuery',
            },
            {
              'title': '"$searchQuery" 관련 뉴스 2',
              'url': 'https://search.naver.com/search.naver?query=$searchQuery',
            },
          ],
          'sourceNews': [
            {
              'title': '"$searchQuery" 검색 결과',
              'link': 'https://www.google.com/search?q=$searchQuery',
              'originallink': 'https://www.google.com/search?q=$searchQuery',
            },
          ],
        };
      }
    }
    return {
      'script':
          '안녕하세요! SWEN 뉴스입니다. 현재 서버에서 뉴스를 가져오는 중입니다. 잠시만 기다려주세요. (테스트 모드)',
      'audioUrl':
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
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
      'sourceNews': [
        {
          'title': 'SWEN 테스트 뉴스',
          'link': 'https://www.google.com',
          'originallink': 'https://www.google.com',
        },
      ],
    };
  }

  /// 오디오 URL 추출
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

/// 기존 코드와 호환을 위한 함수
Future<Map<String, String>> fetchScriptAndAudioUrl() async {
  final data = await ApiService.fetchNewsData();
  return {
    ApiConstants.scriptKey: data[ApiConstants.scriptKey] as String,
    'audioUrl': ApiService.extractAudioUrl(data),
  };
}
