import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

/// 웹뷰 화면 위젯
class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;
  final VoidCallback? onLoadFailed;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
    this.onLoadFailed,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

/// 웹뷰 화면 상태 관리
class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _hasCalledFailedCallback = false;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// 웹뷰 초기화
  void _initializeWebView() {
    debugPrint('웹뷰 초기화 시작: ${widget.url}');
    
    // 간단한 URL 정규화
    String initialUrl = widget.url;
    
    // URL에 프로토콜이 없으면 https 추가
    if (!initialUrl.startsWith('http://') && !initialUrl.startsWith('https://')) {
      initialUrl = 'https://$initialUrl';
    }
    
    // URL 공백 제거
    initialUrl = initialUrl.trim();
    
    // URL 파싱 및 검증
    Uri? parsedUri;
    try {
      parsedUri = Uri.parse(initialUrl);
      debugPrint('URL 파싱 성공: $parsedUri');
    } catch (e) {
      debugPrint('URL 파싱 실패: $e');
      // 기본 URL로 리다이렉트
      initialUrl = 'https://www.google.com';
      parsedUri = Uri.parse(initialUrl);
    }
    
    debugPrint('최종 URL: $initialUrl');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_generateAdvancedUserAgent())
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('웹뷰 로딩 진행률: $progress%');
            if (progress > 50 && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            debugPrint('페이지 로딩 시작: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
              _hasCalledFailedCallback = false;
            });
          },
          onPageFinished: (String url) {
            debugPrint('페이지 로딩 완료: $url');
            setState(() {
              _isLoading = false;
              _loadAttempts = 0; // 성공 시 시도 횟수 리셋
            });
            
            // 실시간 ORB 우회 JavaScript 주입
            _injectRealTimeBypass();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('웹뷰 오류 발생: ${error.description} (코드: ${error.errorCode})');
            
            // ORB 오류 감지 시 한 번만 재시도
            if ((error.description.contains('ORB') || error.description.contains('BLOCKED')) && _loadAttempts == 0) {
              debugPrint('ORB 차단 감지! 한 번만 재시도...');
              _loadAttempts++;
              Future.delayed(Duration(seconds: 2), () {
                if (mounted) {
                  _retryWithDynamicBypass();
                }
              });
              return;
            }
            
            // 연결 오류나 타임아웃은 한 번만 재시도
            if ((error.errorCode == -6 || error.errorCode == -8) && _loadAttempts < 1) {
              _loadAttempts++;
              debugPrint('연결 오류로 한 번만 재시도: $_loadAttempts');
              
              Future.delayed(Duration(seconds: 3), () {
                if (mounted) {
                  _controller.reload();
                }
              });
              return;
            }
            
            // 최대 재시도 횟수 초과 또는 다른 오류
            debugPrint('웹뷰 오류로 인한 최종 실패');
            setState(() {
              _hasError = true;
              _errorMessage = _getErrorMessage(error);
            });
            
            // 실패 콜백 호출
            if (!_hasCalledFailedCallback && widget.onLoadFailed != null) {
              _hasCalledFailedCallback = true;
              widget.onLoadFailed!();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('네비게이션 요청: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      
      // 고급 헤더로 페이지 로드 (ORB 우회용)
      ..loadRequest(parsedUri!, headers: _generateAdvancedHeaders(parsedUri!));
  }

  /// 고급 User Agent 생성 (ORB 우회용)
  String _generateAdvancedUserAgent() {
    // 항상 Android 모바일 User Agent로 고정
    return 'Mozilla/5.0 (Linux; Android 15; SM-S921N Build/AP1A.240505.004) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.60 Mobile Safari/537.36';
  }

  /// 고급 HTTP 헤더 생성 (ORB 우회용)
  Map<String, String> _generateAdvancedHeaders(Uri uri) {
    final String userAgent = _generateAdvancedUserAgent();
    
    return {
      'User-Agent': userAgent,
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br',
      'DNT': '1',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Sec-Fetch-Site': 'none',
      'Sec-Fetch-User': '?1',
      'Cache-Control': 'max-age=0',
      'Sec-Ch-Ua': '"Chromium";v="125", "Google Chrome";v="125", "Not_A Brand";v="99"',
      'Sec-Ch-Ua-Mobile': '?0',
      'Sec-Ch-Ua-Platform': '"Windows"',
      'Sec-GPC': '1',
      'X-Forwarded-For': '${_generateRandomIP()}',
      'X-Real-IP': _generateRandomIP(),
      'X-Forwarded-Proto': 'https',
      'X-Requested-With': 'XMLHttpRequest',
    };
  }

  /// 랜덤 IP 주소 생성
  String _generateRandomIP() {
    final List<String> ips = [
      '203.241.${_randomInt(1, 255)}.${_randomInt(1, 255)}',
      '211.252.${_randomInt(1, 255)}.${_randomInt(1, 255)}',
      '175.223.${_randomInt(1, 255)}.${_randomInt(1, 255)}',
      '121.254.${_randomInt(1, 255)}.${_randomInt(1, 255)}',
      '59.186.${_randomInt(1, 255)}.${_randomInt(1, 255)}',
    ];
    return ips[DateTime.now().millisecond % ips.length];
  }

  /// 랜덤 정수 생성
  int _randomInt(int min, int max) {
    return min + (DateTime.now().microsecond % (max - min + 1));
  }

  /// 오류 메시지 생성 (간단한 처리)
  String _getErrorMessage(WebResourceError error) {
    switch (error.errorCode) {
      case -2: // ERROR_HOST_LOOKUP
        return '서버를 찾을 수 없습니다.\n네트워크 연결을 확인해주세요.';
      case -6: // ERROR_CONNECT
        return '서버에 연결할 수 없습니다.\n인터넷 연결을 확인해주세요.';
      case -8: // ERROR_TIMEOUT
        return '페이지 로딩 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요.';
      case -13: // ERROR_BAD_URL
        return '잘못된 URL입니다.\n외부 브라우저로 열어보세요.';
      default:
        return '페이지를 불러올 수 없습니다.\n외부 브라우저로 열어보세요.';
    }
  }

  /// 페이지 다시 로드 (안정적인 버전)
  void _reloadPage() {
    if (_loadAttempts < 1) { // 한 번만 재시도
      _loadAttempts++;
      debugPrint('페이지 다시 로드 시도: $_loadAttempts');
      
      setState(() {
        _isLoading = true;
        _hasError = false;
        _hasCalledFailedCallback = false;
      });
      
      // 동적 우회 시스템으로 재시도
      _retryWithDynamicBypass();
    } else {
      debugPrint('재시도 횟수 초과');
      if (widget.onLoadFailed != null) {
        widget.onLoadFailed!();
      }
    }
  }

  /// 동적 우회 시스템으로 재시도
  void _retryWithDynamicBypass() {
    // 새로운 User Agent와 헤더로 재시도
    final String newUserAgent = _generateAdvancedUserAgent();
    final Map<String, String> newHeaders = _generateAdvancedHeaders(Uri.parse(widget.url));
    
    debugPrint('동적 우회 재시도 - User Agent: $newUserAgent');
    
    _controller
      ..setUserAgent(newUserAgent)
      ..loadRequest(Uri.parse(widget.url), headers: newHeaders);
  }

  /// 안정적인 ORB 우회 JavaScript 주입 (한 번만 실행)
  void _injectRealTimeBypass() {
    _controller.runJavaScript('''
      // 뷰포트 최적화
      var viewport = document.querySelector('meta[name="viewport"]');
      if (!viewport) {
        viewport = document.createElement('meta');
        viewport.name = 'viewport';
        document.head.appendChild(viewport);
      }
      viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      
      // ORB 우회를 위한 브라우저 환경 위장 (한 번만 실행)
      Object.defineProperty(navigator, 'webdriver', {
        get: () => undefined,
      });
      
      // Chrome 객체 위장
      if (typeof window.chrome === 'undefined') {
        window.chrome = {
          runtime: {},
          loadTimes: function() { return {}; },
          csi: function() { return {}; },
          app: {}
        };
      }
      
      // Permissions API 위장
      if (navigator.permissions) {
        const originalQuery = navigator.permissions.query;
        navigator.permissions.query = function(parameters) {
          return Promise.resolve({ state: 'granted' });
        };
      }
      
      // Service Worker API 위장
      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistrations = function() {
          return Promise.resolve([]);
        };
      }
      
      // Notification API 위장
      if ('Notification' in window) {
        Notification.permission = 'granted';
        Notification.requestPermission = function() {
          return Promise.resolve('granted');
        };
      }
      
      // WebGL 위장
      const getParameter = WebGLRenderingContext.prototype.getParameter;
      WebGLRenderingContext.prototype.getParameter = function(parameter) {
        if (parameter === 37445) {
          return 'Intel Inc.';
        }
        if (parameter === 37446) {
          return 'Intel(R) Iris(TM) Graphics 6100';
        }
        return getParameter.call(this, parameter);
      };
      
      // Canvas 위장
      const originalGetContext = HTMLCanvasElement.prototype.getContext;
      HTMLCanvasElement.prototype.getContext = function(type) {
        const context = originalGetContext.apply(this, arguments);
        if (type === '2d') {
          const originalFillText = context.fillText;
          context.fillText = function() {
            return originalFillText.apply(this, arguments);
          };
        }
        return context;
      };
      
      // 언어 설정 위장
      Object.defineProperty(navigator, 'languages', {
        get: () => ['ko-KR', 'ko', 'en-US', 'en'],
      });
      
      // 플랫폼 위장
      Object.defineProperty(navigator, 'platform', {
        get: () => 'Win32',
      });
      
      // 하드웨어 동시성 위장
      Object.defineProperty(navigator, 'hardwareConcurrency', {
        get: () => 8,
      });
      
      // 메모리 정보 위장
      if (navigator.deviceMemory === undefined) {
        Object.defineProperty(navigator, 'deviceMemory', {
          get: () => 8,
        });
      }
      
      // 페이지 로딩 완료 표시
      console.log('ORB 우회 JavaScript 주입 완료');
    ''');
  }

  /// URL을 클립보드에 복사
  void _copyUrlToClipboard(String url, BuildContext context) {
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

  /// 외부 브라우저로 열기
  Future<void> _openInExternalBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('외부 브라우저로 열기: $url');
    } else {
      debugPrint('외부 브라우저 열기 실패: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('외부 브라우저를 열 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('🔗', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              'swen link',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.buttonText,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPage,
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyUrlToClipboard(widget.url, context),
            tooltip: '링크 복사',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openInExternalBrowser(widget.url),
            tooltip: '외부 브라우저로 열기',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            // 오류 화면
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '페이지를 불러올 수 없습니다',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _reloadPage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openInExternalBrowser(widget.url),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('외부 브라우저'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            // 웹뷰
            WebViewWidget(controller: _controller),
          
          // 로딩 인디케이터
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 