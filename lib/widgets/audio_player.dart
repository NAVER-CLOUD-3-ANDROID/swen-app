import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

/// 오디오 플레이어 위젯
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool autoPlay;
  final VoidCallback? onPlay;
  final VoidCallback? onComplete;
  final VoidCallback? onError; // 오류 발생 시 콜백 추가

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.autoPlay = false,
    this.onPlay,
    this.onComplete,
    this.onError,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

/// 오디오 플레이어 상태 관리
class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  /// 오디오 플레이어 초기 설정
  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      debugPrint('오디오 재생 완료 이벤트 발생');
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          // 재생 완료 후에도 duration은 유지 (재재생을 위해)
        });
        debugPrint('완료 콜백 호출');
        widget.onComplete?.call();
        
        // 재생 완료 후 상태 초기화를 위한 추가 처리
        debugPrint('재생 완료 후 상태 초기화 - position: $_position, duration: $_duration');
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    if (widget.autoPlay && widget.audioUrl.isNotEmpty) {
      _loadAndPlayAudio();
    }
  }

  /// 오디오 URL 변경 시 새 오디오 로드
  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.audioUrl != widget.audioUrl && 
        widget.autoPlay && 
        widget.audioUrl.isNotEmpty) {
      debugPrint('오디오 URL 변경됨: ${widget.audioUrl}');
      _loadAndPlayAudio();
    }
  }

  /// 오디오 로드 및 재생
  Future<void> _loadAndPlayAudio() async {
    if (widget.audioUrl.isEmpty) return;

    // UI 업데이트를 메인 스레드에서 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });

    try {
      debugPrint('오디오 URL 로드 중: ${widget.audioUrl}');
      
      // 기존 오디오 정리
      await _audioPlayer.stop();
      
      // 타임아웃 설정 (10초)
      await _audioPlayer.setSourceUrl(widget.audioUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('오디오 로드 타임아웃', const Duration(seconds: 10));
        },
      );
      
      await _audioPlayer.setVolume(1.0); // 볼륨 최대 (0.0~1.0 범위)
      
      // 오디오가 완전히 준비될 때까지 대기
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('오디오 재생 시작');
      await _audioPlayer.resume();
      
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPlay?.call();
        });
      }
    } catch (e) {
      debugPrint('오디오 로드 오류: $e');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _errorMessage = '오디오 로드 실패 - 네트워크를 확인해주세요';
          });
          // 오류 콜백 호출
          widget.onError?.call();
        });
      }
    }
  }

  /// 재생/일시정지 토글
  Future<void> _playPause() async {
    debugPrint('재생/일시정지 버튼 클릭 - 현재 상태: $_isPlaying, 위치: $_position, 길이: $_duration');
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // 재생이 끝났거나 처음 재생하는 경우
      if (_position >= _duration || _position == Duration.zero) {
        debugPrint('재생 위치를 처음으로 되돌림');
        
        // 재생 완료된 경우 무조건 다시 로드
        if (_position >= _duration || _position == Duration.zero) {
          debugPrint('재생 완료됨 또는 처음 위치 - 오디오 다시 로드');
          await _loadAndPlayAudio();
          return;
        }
        
        // 오디오가 로드되지 않은 경우 다시 로드
        if (_duration == Duration.zero) {
          debugPrint('오디오 로드되지 않음 - 다시 로드');
          await _loadAndPlayAudio();
          return;
        }
        
        // 위치를 처음으로 되돌리고 재생
        await _audioPlayer.seek(Duration.zero);
        debugPrint('위치를 처음으로 되돌림 완료');
        
        // 잠시 대기 후 재생
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      debugPrint('오디오 재생 시작');
      await _audioPlayer.resume();
    }
  }

  /// 재생 위치 변경
  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 시간 포맷팅
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }
    return _buildPlayerWidget();
  }

  /// 오류 위젯
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red[600], size: 32),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 플레이어 위젯
  Widget _buildPlayerWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildPlayPauseButton(),
          const SizedBox(height: 16),
          if (_duration > Duration.zero) _buildProgressSection(),
        ],
      ),
    );
  }

  /// 재생/일시정지 버튼
  Widget _buildPlayPauseButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 48,
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          color: Colors.blue[900],
          onPressed: _playPause,
          tooltip: _isPlaying ? '일시정지' : '재생',
        ),
      ],
    );
  }

  /// 진행률 섹션
  Widget _buildProgressSection() {
    return Column(
      children: [
        Slider(
          value: _position.inMilliseconds.toDouble(),
          min: 0,
          max: _duration.inMilliseconds.toDouble(),
          onChanged: (value) {
            _seekTo(Duration(milliseconds: value.toInt()));
          },
          activeColor: Colors.blue[900],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
        ),
      ],
    );
  }
} 