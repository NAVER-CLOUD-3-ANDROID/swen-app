import 'dart:async';
import 'package:flutter/material.dart';

/// 로딩 메시지 관련 상수와 함수들을 담은 클래스
class LoadingMessages {
  /// 재미있는 로딩 메시지들
  static const List<String> messages = [
    '🚚📦 따끈한 뉴스, 음성으로 쓱싹 배송 중...',
    '📰🥖 오늘의 뉴스빵, 음성으로 갓 구워서 출발!',
    '🚚🎧 이어폰 켜세요, 음성 뉴스 곧 도착합니다!',
    '📬🔈 음성으로 문 앞까지 뉴스 배달 중!',
    '🚛📃 신문 꾸러미, 음성으로 안전 이송 중!',
    '📦🎙️ 오늘 뉴스, 음성으로 찰떡포장 완료!',
    '🚚🔊 스피커 ON! 음성 뉴스 택배 오는 중!',
    '📬🚚 문 앞에 음성 뉴스 상자 도착 예정!',
    '🗞️📦 신문 대신 음성으로 오늘 소식 전달!',
    '🎧🚚 이어폰으로 듣는 뉴스, 배달 중입니다!',
    '📦📰 오늘 헤드라인, 음성 박스로 포장 완료!',
    '🚛🔊 세상 뉴스, 음성 택배로 쓱쓱 이동 중!',
    '📬🎙️ 음성 뉴스 상자, 벨 누르기 직전!',
    '📦🎧 따끈따끈 뉴스, 음성으로 문 앞까지!',
    '🚚🔈 귀 대신 음성으로 소식 쏙쏙 배달!',
    '📬📰 신문 대신 음성 뉴스가 찾아갑니다!',
    '🚚🎙️ 스피커 켜세요, 음성 뉴스 도착 1분 전!',
    '📦🔊 최신 뉴스, 음성으로 바로 드립니다!',
    '🚛🎧 헤드폰 준비! 음성 뉴스 택배 출발!',
    '📬🥐 따끈한 뉴스빵, 음성으로 갓 배달 중!',
    '🚚📦 오늘의 뉴스, 음성으로 안전배송 중…',
    '📰✈️ 따끈따끈 음성 뉴스, 비행기로 출발!',
    '🚚🗞️ 소식 상자, 음성으로 전송 중!',
    '📮✨ 음성으로 배달되는 오늘의 뉴스!',
    '🚛🔔 세상 소식, 음성으로 곧 도착!',
    '🚚📡 최신 뉴스, 음성 실시간 배송 중…',
    '📨🚛 오늘의 헤드라인, 음성으로 문 앞까지!',
    '📦🚦 음성 뉴스 트럭, 신호 대기 중…',
    '🏠📬 음성으로 뉴스가 문을 두드려요!',
    '🚚🎧 두 대로 달려요! 음성 뉴스 조금만 기다려요!',
    '📦🔊 따끈한 뉴스, 음성으로 포장 완료!',
    '📰🚚 음성 뉴스 꾸러미 출발 준비 중…',
    '📦🎧 음성 뉴스 택배가 곧 도착합니다!',
    '🚛📃 오늘 뉴스, 음성으로 바로 연결 중!',
    '📬🔈 헤드라인, 음성으로 곧 도착 예정!',
    '🗞️📦 오늘 소식, 음성 택배로 이동 중!',
    '🚚🔊 음성 뉴스 트럭 가득 싣고 달리는 중!',
    '📦🎙️ 따끈따끈 음성 뉴스, 안전배송 중…',
    '🚛📬 소식 박스, 음성으로 도어벨 누르는 중!',
    '🎧🚚 이어폰 챙기셨나요? 음성 뉴스 배달 중!',
  ];

}

/// 로딩 메시지 애니메이션 관리 클래스
class LoadingAnimationController {
  Timer? _timer;
  int _currentIndex = 0;
  final VoidCallback? onMessageChanged;

  LoadingAnimationController({this.onMessageChanged});

  /// 현재 메시지 인덱스
  int get currentIndex => _currentIndex;

  /// 현재 메시지
  String get currentMessage => LoadingMessages.messages[_currentIndex];

  /// 로딩 메시지 애니메이션 시작
  void start() {
    if (_timer != null) return; // 이미 실행 중이면 중복 실행 방지
    _currentIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentIndex = (_currentIndex + 1) % LoadingMessages.messages.length;
      onMessageChanged?.call();
    });
  }

  /// 로딩 메시지 애니메이션 정지
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 리소스 해제
  void dispose() {
    stop();
  }
} 