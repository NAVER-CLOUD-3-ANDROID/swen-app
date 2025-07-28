import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swen/screens/platform_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/native_webview_screen.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

/// 링크 처리 관련 유틸리티 클래스
class LinkHandler {
  /// 뉴스 클릭 처리
  static void handleNewsTap(BuildContext context, Map<String, String> news) {
    final title = news['title'] ?? '관련 뉴스';
    final url = news['url'];

    debugPrint('뉴스 클릭됨 - 제목: $title, URL: $url');

    if (url != null && ErrorHandler.isValidUrl(url)) {
      final normalizedUrl = ErrorHandler.normalizeUrl(url);
      debugPrint('정규화된 URL: $normalizedUrl');

      // 웹뷰로 먼저 시도
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlatformWebViewScreen(
            url: normalizedUrl,
            title: title,
            onLoadFailed: () =>
                _openInExternalBrowser(normalizedUrl, title, context),
          ),
        ),
      );
    } else {
      debugPrint('유효하지 않은 URL: $url');
      _showUrlErrorDialog(url, title, context);
    }
  }

  /// 현재 데이터의 링크로 웹뷰 열기 (sourceNews의 link 사용)
  static void openCurrentDataLink(
      BuildContext context, List<Map<String, dynamic>> sourceNews) {
    debugPrint('링크 버튼 클릭됨 - sourceNews 개수: ${sourceNews.length}');
    debugPrint('sourceNews 내용: $sourceNews');

    // sourceNews에서 첫 번째 뉴스의 link 사용
    if (sourceNews.isNotEmpty) {
      final firstSourceNews = sourceNews.first;
      debugPrint('첫 번째 sourceNews: $firstSourceNews');

      final link = firstSourceNews['link'] ?? firstSourceNews['originallink'];
      final title = firstSourceNews['title'] ?? '관련 뉴스';

      debugPrint('찾은 링크: $link');
      debugPrint('뉴스 제목: $title');

      if (link != null && ErrorHandler.isValidUrl(link)) {
        final normalizedUrl = ErrorHandler.normalizeUrl(link);
        debugPrint('정규화된 URL: $normalizedUrl');

        // 웹뷰로 먼저 시도
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlatformWebViewScreen(
              url: normalizedUrl,
              title: title,
              onLoadFailed: () =>
                  _openInExternalBrowser(normalizedUrl, title, context),
            ),
          ),
        );
      } else {
        debugPrint('유효하지 않은 링크: $link');
        _showUrlErrorDialog(link, title, context);
      }
    } else {
      debugPrint('sourceNews가 비어있음');
      _showNoSourceNewsDialog(context);
    }
  }

  /// 첫 번째 뉴스 링크로 웹뷰 열기
  static void openFirstNewsLink(
      BuildContext context, List<Map<String, String>> recommendedNews) {
    if (recommendedNews.isEmpty) return;

    final firstNews = recommendedNews.first;
    final url = firstNews['url'];

    if (url != null && ErrorHandler.isValidUrl(url)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlatformWebViewScreen(
            url: url,
            title: firstNews['title'] ?? '관련 뉴스',
          ),
        ),
      );
    } else {
      ErrorHandler.showErrorSnackBar(context, AppStrings.noLinkMessage);
    }
  }

  /// 외부 브라우저로 링크 열기
  static Future<void> _openInExternalBrowser(
      String url, String title, BuildContext context) async {
    debugPrint('외부 브라우저로 열기 시도: $url');

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('외부 브라우저로 성공적으로 열림: $url');

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.open_in_browser, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '외부 브라우저에서 열렸습니다!',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('외부 브라우저로 열기 실패: $url');
        _showBrowserErrorDialog(url, title, context);
      }
    } catch (e) {
      debugPrint('외부 브라우저 열기 중 오류: $e');
      _showBrowserErrorDialog(url, title, context);
    }
  }

  /// URL 오류 다이얼로그 표시
  static void _showUrlErrorDialog(
      String? url, String title, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔗 링크 오류'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('뉴스: $title'),
            const SizedBox(height: 8),
            Text('URL: ${url ?? "없음"}'),
            const SizedBox(height: 8),
            const Text(
              '유효하지 않은 링크입니다.\n다른 뉴스를 시도해보세요.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 브라우저 오류 다이얼로그 표시
  static void _showBrowserErrorDialog(
      String url, String title, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🌐 브라우저 오류'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('뉴스: $title'),
            const SizedBox(height: 8),
            Text('URL: $url'),
            const SizedBox(height: 8),
            const Text(
              '외부 브라우저로 열기 실패했습니다.\nURL을 복사해서 직접 브라우저에 붙여넣어보세요.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              _copyUrlToClipboard(url, context);
              Navigator.of(context).pop();
            },
            child: const Text('📋 링크 복사'),
          ),
        ],
      ),
    );
  }

  /// sourceNews 없음 다이얼로그 표시
  static void _showNoSourceNewsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📰 관련 뉴스 없음'),
        content: const Text(
          '현재 뉴스와 관련된 추가 링크가 없습니다.\n\n새로운 뉴스를 불러오거나 다른 뉴스를 확인해보세요.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// URL을 클립보드에 복사
  static void _copyUrlToClipboard(String url, BuildContext context) {
    Clipboard.setData(ClipboardData(text: url)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.copy, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '링크가 클립보드에 복사되었습니다!\n$url',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '확인',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      debugPrint('URL이 클립보드에 복사됨: $url');
    }).catchError((error) {
      debugPrint('클립보드 복사 실패: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크 복사에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}
