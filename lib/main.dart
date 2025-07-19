// Flutter 앱의 진입점 및 메인 UI를 담당하는 파일입니다.
// 주요 역할: 앱 실행, 홈 화면 상태 관리, API 호출 및 오디오 플레이어 표시
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'services/api_service.dart';
import 'services/search_service.dart';
import 'widgets/audio_player.dart';
import 'screens/splash_screen.dart';
import 'screens/webview_screen.dart';
import 'constants/app_constants.dart';
import 'constants/loading_messages.dart';
import 'utils/error_handler.dart';
import 'utils/link_handler.dart';
import 'widgets/custom_widgets.dart';

void main() {
  runApp(const MyApp());
}

/// 메인 앱 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const NewsPlayerScreen(),
      },
    );
  }
}

/// 뉴스 플레이어 메인 화면
class NewsPlayerScreen extends StatefulWidget {
  const NewsPlayerScreen({super.key});

  @override
  State<NewsPlayerScreen> createState() => _NewsPlayerScreenState();
}

/// 뉴스 플레이어 상태 관리
class _NewsPlayerScreenState extends State<NewsPlayerScreen> {
  // 데이터 상태
  String? _script;
  String? _audioUrl;
  List<Map<String, String>> _recommendedNews = [];
  List<Map<String, dynamic>> _sourceNews = []; // sourceNews 추가
  
  // UI 상태
  bool _showScript = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _shouldAutoPlay = false;
  final TextEditingController _searchController = TextEditingController();
  
  // 로딩 메시지 애니메이션 관련 변수들
  late LoadingAnimationController _loadingAnimationController;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = LoadingAnimationController(
      onMessageChanged: () {
        if (mounted) setState(() {});
      },
    );
    _loadingAnimationController.start(); // 앱 시작 시 로딩 메시지 애니메이션 시작
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loadingAnimationController.dispose(); // 앱 종료 시 로딩 메시지 애니메이션 정지
    super.dispose();
  }

  /// 공통 데이터 업데이트 메서드
  void _updateNewsData(Map<String, dynamic> data, {bool resetScript = false}) {
    if (!mounted) return;

    debugPrint('데이터 업데이트 시작 - 스크립트: ${data['script']?.toString().substring(0, 20)}..., 오디오: ${data['audioUrl']}, 뉴스: ${data['recommendedNews']?.length}개');
    
    setState(() {
      _script = data['script'];
      _audioUrl = data['audioUrl'];
      _recommendedNews = data['recommendedNews'];
      _sourceNews = List<Map<String, dynamic>>.from(data['sourceNews'] ?? []); // sourceNews 업데이트
      _isLoading = false;
      _isPlaying = true;
      _shouldAutoPlay = resetScript;
      if (resetScript) _showScript = false;
    });
    
    debugPrint('데이터 업데이트 완료 - _isPlaying: $_isPlaying, _shouldAutoPlay: $_shouldAutoPlay');
  }

  /// API 호출 및 데이터 로드 (공통 로직)
  Future<void> _loadNewsData({bool isInitialLoad = false}) async {
    if (_isLoading) return;
    
    if (!isInitialLoad) {
      setState(() => _isLoading = true);
    }

    try {
      final data = await ApiService.fetchNewsData();
      if (mounted) {
        _updateNewsData(data, resetScript: !isInitialLoad);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getNewsLoadErrorMessage(e),
        );
      }
    }
  }

  /// 첫 플레이 버튼 클릭 시 실행되는 함수
  Future<void> _fetchAndShowPlayer() async {
    setState(() {
      _isLoading = true;
    });
    
    // 로딩 메시지 애니메이션 시작
    _loadingAnimationController.start();

    try {
      final data = await ApiService.fetchNewsData();
      
      if (data != null) {
        setState(() {
          _audioUrl = data['audioUrl'];
          _script = data['script'];
          _recommendedNews = List<Map<String, String>>.from(data['recommendedNews'] ?? []);
          _sourceNews = List<Map<String, dynamic>>.from(data['sourceNews'] ?? []);
          _isPlaying = true;
          _shouldAutoPlay = true;
        });
      } else {
        ErrorHandler.showErrorSnackBar(context, AppStrings.newsLoadError);
      }
    } catch (error) {
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getNewsLoadErrorMessage(error));
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      // 로딩 완료 시 애니메이션 정지
      _loadingAnimationController.stop();
    }
  }

  /// 오디오 재생 완료 시 콜백
  Future<void> _onAudioComplete() async {
    // 오디오 재생 완료 시 추가 로직이 필요한 경우 여기에 구현
  }

  /// 새로고침 버튼 클릭 시 새 뉴스 로드
  void _refreshNews() {
    _searchController.clear();
    _loadNewsData(isInitialLoad: false);
  }

  /// 검색 실행 함수 (간단한 버전)
  Future<void> _searchNews() async {
    // 키보드 숨기기
    FocusScope.of(context).unfocus();
    
    final query = _searchController.text.trim();
    if (!ErrorHandler.isValidSearchQuery(query)) {
      ErrorHandler.showErrorSnackBar(context, AppStrings.emptySearchMessage);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    // 로딩 메시지 애니메이션 시작
    _loadingAnimationController.start();

    try {
      // 검색어와 함께 API 호출
      final data = await ApiService.fetchNewsData(searchQuery: query);
      
      if (data != null) {
        setState(() {
          _audioUrl = data['audioUrl'];
          _script = data['script'];
          _recommendedNews = List<Map<String, String>>.from(data['recommendedNews'] ?? []);
          _sourceNews = List<Map<String, dynamic>>.from(data['sourceNews'] ?? []);
          _isPlaying = true;
          _shouldAutoPlay = true;
        });
      } else {
        ErrorHandler.showErrorSnackBar(context, AppStrings.searchError);
      }
    } catch (error) {
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getSearchErrorMessage(error));
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      // 로딩 완료 시 애니메이션 정지
      _loadingAnimationController.stop();
      
      // 검색 후 입력값 지우기
      _searchController.clear();
    }
  }

  /// 오디오 오류 발생 시 새 뉴스 로드
  Future<void> _onAudioError() async {
    if (_isLoading) return;
    await _loadNewsData();
  }

  /// 스크립트 모달 표시
  void _showScriptModal() {
    if (_script == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 화면 터치로 닫기 가능
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(AppSizes.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📑 스크립트',
                      style: CustomWidgets.defaultTextStyle(
                        fontSize: AppSizes.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: '닫기',
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingM),
                // 구분선
                Container(
                  height: 1,
                  color: AppColors.divider,
                ),
                const SizedBox(height: AppSizes.spacingM),
                // 스크립트 내용
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
                    child: Text(
                      _script!,
                      style: CustomWidgets.defaultTextStyle(
                        fontSize: AppSizes.fontSizeBody,
                      ).copyWith(
                        height: 1.8, // 줄 간격 증가
                        letterSpacing: 0.3, // 자간 추가
                      ),
                      textAlign: TextAlign.justify, // 양쪽 정렬
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 첫 번째 뉴스 링크로 웹뷰 열기
  void _openFirstNewsLink() {
    LinkHandler.openFirstNewsLink(context, _recommendedNews);
  }

  /// 현재 데이터의 링크로 웹뷰 열기 (sourceNews의 link 사용)
  void _openCurrentDataLink() {
    LinkHandler.openCurrentDataLink(context, _sourceNews);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildLogo(),
            if (!_isPlaying)
              Expanded(child: _buildPlayButton())
            else
              Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  /// SWEN 로고 위젯 (크기 조정하고 오른쪽으로 이동)
  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.spacingM,
        top: AppSizes.spacingM,
        right: AppSizes.spacingM,
        bottom: AppSizes.spacingS,
      ),
      child: Row(
        children: [
          Text(
            AppStrings.appName,
            style: CustomWidgets.defaultTextStyle(
              fontSize: AppSizes.fontSizeLarge + 2, // 크기 줄임
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ).copyWith(letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }



  /// 첫 플레이 버튼 위젯
  Widget _buildPlayButton() {
    return Center(
      child: _isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomWidgets.loadingIndicator(
                  size: AppSizes.iconSizeXXL,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.spacingL),
                _buildLoadingMessage(),
              ],
            )
          : IconButton(
              iconSize: AppSizes.iconSizeXXXL,
              icon: const Icon(Icons.play_arrow),
              color: AppColors.primary,
              onPressed: _fetchAndShowPlayer,
              tooltip: AppStrings.playButton,
            ),
    );
  }

  /// 로딩 중 메시지 위젯
  Widget _buildLoadingMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM,
      ),
      child: Column(
        children: [
          Text(
            _loadingAnimationController.currentMessage,
            style: CustomWidgets.defaultTextStyle(
              fontSize: AppSizes.fontSizeMedium,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingS),
                      Text(
              '잠시만 기다려주세요...',
              style: CustomWidgets.defaultTextStyle(
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 위젯
  Widget _buildMainContent() {
    return Column(
      children: [
        // 상단 고정 영역 (검색 + 플레이어)
        Container(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            children: [
              _buildSearchSection(),
              const SizedBox(height: AppSizes.spacingM),
              _buildPlayerSection(),
            ],
          ),
        ),
        
        // 하단 스크롤 영역 (뉴스 + 스크립트)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
        child: Column(
              children: [
                const SizedBox(height: AppSizes.spacingL), // 상단 여백 추가
                if (_recommendedNews.isNotEmpty) ...[
                  _buildRecommendedNewsList(),
                  const SizedBox(height: AppSizes.spacingM),
                ],
                if (_script != null) ...[
                  _buildScriptButton(),
                  const SizedBox(height: AppSizes.spacingM),
                ],
                const SizedBox(height: AppSizes.spacingXL),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 검색 섹션 위젯
  Widget _buildSearchSection() {
    return Container(
      height: AppSizes.heightSearch + 10, // 검색 박스 크기 조금 줄이기
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS, // 위아래 패딩 줄이기
      ),
      decoration: CustomWidgets.defaultContainerDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: CustomWidgets.defaultTextStyle(
                fontSize: AppSizes.fontSizeBody,
              ),
              decoration: const InputDecoration(
                hintText: AppStrings.searchHint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingS,
                  vertical: AppSizes.spacingM, // 위아래 패딩 늘려서 중앙 정렬
                ),
                isDense: true,
                alignLabelWithHint: true, // 힌트 텍스트를 아래로 정렬
              ),
              onSubmitted: (_) => _searchNews(),
              onTap: () {
                // 포커스 유지 - 타자 입력 활성화
                debugPrint('TextField 터치됨 - 키보드 활성화');
              },
              onChanged: (value) {
                // 실시간 입력 확인
                debugPrint('입력된 텍스트: "$value" (길이: ${value.length})');
              },
              // 맥북 키보드 직접 입력을 위한 설정
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              enableInteractiveSelection: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              obscureText: false,
              readOnly: false,
              enabled: true,
              // 한국어 입력 지원을 위한 추가 설정
              inputFormatters: [],
              textDirection: TextDirection.ltr,
              // IME 설정으로 한국어 입력 활성화
              enableIMEPersonalizedLearning: true,
              // 자동 완성 비활성화
              autofillHints: null,
              // 맥북 키보드 직접 입력을 위한 추가 설정
              showCursor: true,
              cursorWidth: 2.0,
              cursorHeight: 20.0,
              cursorRadius: const Radius.circular(1.0),
              // 포커스 노드 설정
              focusNode: FocusNode(),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          _isLoading
              ? CustomWidgets.loadingIndicator(
                  size: AppSizes.iconSizeM,
                )
              : CustomWidgets.iconButton(
                  icon: Icons.search,
                  onPressed: _searchNews,
                  size: AppSizes.iconSizeM,
                  tooltip: AppStrings.searchButton,
                ),
        ],
      ),
    );
  }

  /// 오디오 플레이어 섹션 위젯
  Widget _buildPlayerSection() {
    return AudioPlayerWidget(
      audioUrl: _audioUrl ?? '',
      autoPlay: _shouldAutoPlay,
      onPlay: () {
        setState(() {
          _shouldAutoPlay = false; // 재생 후 자동재생 플래그 해제
        });
      },
      onComplete: _onAudioComplete,
      onError: _onAudioError,
    );
  }

  /// 추천 뉴스 목록 위젯
  Widget _buildRecommendedNewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recommendedNewsTitle,
          style: CustomWidgets.defaultTextStyle(
            fontSize: AppSizes.fontSizeMedium, // 글씨 크기 줄이기
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Container(
          height: 120, // 최대 5개 뉴스에 맞춘 고정 높이
          decoration: CustomWidgets.defaultContainerDecoration(),
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6, // 스크롤바 두께
            radius: const Radius.circular(10), // 스크롤바 모서리 둥글게
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.spacingS),
              itemCount: _recommendedNews.length,
              itemBuilder: (context, index) => _buildNewsItem(_recommendedNews[index]),
            ),
          ),
        ),
      ],
    );
  }

  /// 개별 뉴스 아이템 위젯
  Widget _buildNewsItem(Map<String, String> news) {
    final hasValidUrl = ErrorHandler.isValidUrl(news['url']);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => _handleNewsTap(news),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
            Text(
                AppStrings.bulletPoint,
                style: CustomWidgets.defaultTextStyle(
                  fontSize: AppSizes.fontSizeMedium,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  news['title']!,
                  style: CustomWidgets.defaultTextStyle(
                    fontSize: AppSizes.fontSizeSmall - 2, // 글씨 크기 1줄 줄임
                    color: AppColors.textPrimary, // 검정색으로 변경
                  ).copyWith(
                    decoration: TextDecoration.none, // 밑줄 제거
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ),
              if (hasValidUrl)
                Icon(
                  Icons.open_in_new,
                  size: AppSizes.iconSizeS,
                  color: AppColors.textPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 뉴스 클릭 처리
  void _handleNewsTap(Map<String, String> news) {
    LinkHandler.handleNewsTap(context, news);
  }

  /// 스크립트 토글 버튼 위젯
  Widget _buildScriptButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 링크 바로가기 버튼 (예쁜 디자인)
        if (_audioUrl != null)
          Container(
            margin: const EdgeInsets.only(right: AppSizes.spacingS),
            child: SizedBox(
              width: AppSizes.iconSizeXXL,
              height: AppSizes.iconSizeXXL,
              child: ElevatedButton(
                onPressed: () => _openCurrentDataLink(),
                style: CustomWidgets.defaultButtonStyle(
                  backgroundColor: AppColors.primary,
                  borderRadius: AppSizes.radiusL,
                ).copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.all(AppSizes.spacingS),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(AppSizes.iconSizeXXL, AppSizes.iconSizeXXL),
                  ),
                  elevation: WidgetStateProperty.all(4),
                  shadowColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.link,
                  size: AppSizes.iconSizeL,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () => _showScriptModal(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.showScriptEmoji,
                style: const TextStyle(fontSize: AppSizes.iconSizeS),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(AppStrings.showScriptText),
            ],
          ),
          style: CustomWidgets.defaultButtonStyle(),
        ),
        const SizedBox(width: AppSizes.spacingM),
        _isLoading
            ? SizedBox(
                width: AppSizes.iconSizeXXL,
                height: AppSizes.iconSizeXXL,
                child: ElevatedButton(
                  onPressed: null,
                  style: CustomWidgets.defaultButtonStyle(
                    borderRadius: AppSizes.radiusL,
                  ).copyWith(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.all(AppSizes.spacingM),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      const Size(AppSizes.iconSizeXXL, AppSizes.iconSizeXXL),
                    ),
                  ),
                  child: CustomWidgets.loadingIndicator(
                    size: AppSizes.iconSizeL,
                    color: AppColors.background,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: _refreshNews,
                style: CustomWidgets.defaultButtonStyle(
                  borderRadius: AppSizes.radiusL,
                ).copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.all(AppSizes.spacingM),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(AppSizes.iconSizeXXL, AppSizes.iconSizeXXL),
                  ),
                ),
                child: const Icon(Icons.refresh, size: AppSizes.iconSizeL),
              ),
      ],
    );
  }

  /// 스크립트 내용 위젯
  Widget _buildScriptSection() {
    return Container(
      height: AppSizes.heightScript,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: CustomWidgets.defaultContainerDecoration(
        backgroundColor: AppColors.surface,
      ),
      child: SingleChildScrollView(
        child: Text(
          _script!,
          style: CustomWidgets.defaultTextStyle(
            fontSize: AppSizes.fontSizeSmall,
          ).copyWith(
            height: 1.6, // 줄 간격 증가
            letterSpacing: 0.2, // 자간 추가
          ),
          textAlign: TextAlign.justify, // 양쪽 정렬
        ),
      ),
    );
  }
}

