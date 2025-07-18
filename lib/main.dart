import 'package:flutter/material.dart';
import 'api_service.dart';
import 'audio_player.dart';

/// 앱 전체 상수
class AppConstants {
  // UI 상수
  static const double playButtonSize = 80.0;
  static const double scriptPadding = 24.0;
  static const double audioPlayerTopPadding = 32.0;
  static const double scriptFontSize = 18.0;
  
  // 메시지
  static const String connectionError = '서버에 연결할 수 없습니다.\n\n임시 테스트 데이터를 사용합니다.';
  static const String generalError = '오류가 발생했습니다: ';
  static const String playTooltip = '재생';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뉴스 오디오 플레이어',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _audioUrl;
  String? _script;
  bool _isLoading = false;

  Future<void> _fetchAndPlayAudio() async {
    _setLoadingState(true);
    
    try {
      final data = await ApiService.fetchNewsData();
      _updateAudioData(data);
    } catch (e) {
      _setErrorState(e.toString());
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool loading) {
    setState(() {
      _isLoading = loading;
      if (loading) {
        _audioUrl = null;
        _script = null;
      }
    });
  }

  void _updateAudioData(Map<String, dynamic> data) {
    setState(() {
      _script = data[ApiConstants.scriptKey] as String;
      _audioUrl = ApiService.extractAudioUrl(data);
    });
  }

  void _setErrorState(String error) {
    setState(() {
      if (error.contains('Connection refused')) {
        _script = AppConstants.connectionError;
      } else if (error.contains('Exception:')) {
        _script = error.replaceFirst('Exception: ', '');
      } else {
        _script = AppConstants.generalError + error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScriptSection(),
            const Spacer(),
            _buildPlayButton(),
            _buildAudioPlayer(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptSection() {
    if (_script == null || _script!.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.scriptPadding),
      child: Text(
        _script!,
        style: const TextStyle(fontSize: AppConstants.scriptFontSize),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : IconButton(
              iconSize: AppConstants.playButtonSize,
              icon: const Icon(Icons.play_circle_fill),
              color: Colors.blue,
              onPressed: _fetchAndPlayAudio,
              tooltip: AppConstants.playTooltip,
            ),
    );
  }

  Widget _buildAudioPlayer() {
    if (_audioUrl == null || !_audioUrl!.startsWith('http')) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.audioPlayerTopPadding),
      child: AudioPlayerWidget(audioUrl: _audioUrl!),
    );
  }
}
