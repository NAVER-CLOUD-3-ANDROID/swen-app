import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// 오디오 플레이어 관련 상수
class AudioPlayerConstants {
  static const double playButtonSize = 48.0;
  static const double containerPadding = 16.0;
  static const double buttonSpacing = 16.0;
  static const double sliderTrackHeight = 4.0;
  static const double sliderThumbRadius = 6.0;
  static const double sliderOverlayRadius = 12.0;
  static const double errorPadding = 8.0;
  static const double urlTextSize = 10.0;
  static const double timeTextSize = 12.0;
  
  // 색상
  static const MaterialColor primaryColor = Colors.blue;
  static const MaterialColor errorColor = Colors.red;
  static const MaterialColor textColor = Colors.grey;
}

/// 오디오 플레이어 위젯
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudio();
  }

  /// 오디오 플레이어 이벤트 리스너 설정
  void _setupAudio() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    
    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
    });
    
    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });
    
    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = _duration;
      });
    });
  }

  /// 재생/일시정지 토글
  Future<void> _playPause() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setSource(UrlSource(widget.audioUrl));
        await _audioPlayer.resume();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '재생/일시정지 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 재생 위치 변경
  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      setState(() {
        _errorMessage = '재생 위치 변경 중 오류가 발생했습니다: $e';
      });
    }
  }

  /// Duration을 MM:SS 또는 HH:MM:SS 형식으로 변환
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AudioPlayerConstants.containerPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 오류 메시지
          if (_errorMessage != null) _buildErrorMessage(),
          
          // 재생/일시정지 버튼
          _buildPlayButton(),
          
          const SizedBox(height: AudioPlayerConstants.buttonSpacing),
          
          // 진행률 표시
          if (_duration.inSeconds > 0) _buildProgressSection(),
          
          // 오디오 URL 표시 (디버깅용)
          if (widget.audioUrl.isNotEmpty) _buildUrlDisplay(),
        ],
      ),
    );
  }

  /// 오류 메시지 위젯
  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AudioPlayerConstants.errorPadding),
      margin: const EdgeInsets.only(bottom: AudioPlayerConstants.errorPadding),
      decoration: BoxDecoration(
        color: AudioPlayerConstants.errorColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AudioPlayerConstants.errorColor.withAlpha(76)),
      ),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: AudioPlayerConstants.errorColor[700]),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 재생 버튼 위젯
  Widget _buildPlayButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _isLoading ? null : _playPause,
          icon: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: AudioPlayerConstants.playButtonSize,
                  color: AudioPlayerConstants.primaryColor[600],
                ),
        ),
      ],
    );
  }

  /// 진행률 섹션 위젯
  Widget _buildProgressSection() {
    return Column(
      children: [
        // 시간 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: TextStyle(
                fontSize: AudioPlayerConstants.timeTextSize,
                color: AudioPlayerConstants.textColor[600],
              ),
            ),
            Text(
              _formatDuration(_duration),
              style: TextStyle(
                fontSize: AudioPlayerConstants.timeTextSize,
                color: AudioPlayerConstants.textColor[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AudioPlayerConstants.primaryColor[600],
            inactiveTrackColor: AudioPlayerConstants.textColor[300],
            thumbColor: AudioPlayerConstants.primaryColor[600],
            overlayColor: AudioPlayerConstants.primaryColor[200],
            trackHeight: AudioPlayerConstants.sliderTrackHeight,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: AudioPlayerConstants.sliderThumbRadius,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: AudioPlayerConstants.sliderOverlayRadius,
            ),
          ),
          child: Slider(
            value: _duration.inMilliseconds > 0
                ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                : 0.0,
            onChanged: _isLoading ? null : (value) {
              final newPosition = Duration(
                milliseconds: (value * _duration.inMilliseconds).round(),
              );
              _seekTo(newPosition);
            },
          ),
        ),
      ],
    );
  }

  /// URL 표시 위젯
  Widget _buildUrlDisplay() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '오디오 URL: ${widget.audioUrl}',
        style: TextStyle(
          fontSize: AudioPlayerConstants.urlTextSize,
          color: AudioPlayerConstants.textColor[500],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
} 