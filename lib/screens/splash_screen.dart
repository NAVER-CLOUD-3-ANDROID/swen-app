import 'package:flutter/material.dart';

/// 스플래시 화면 위젯
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// 스플래시 화면 상태 관리
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _scheduleNavigation();
  }
  
  /// 애니메이션 초기화
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }
  
  /// 네비게이션 스케줄링
  void _scheduleNavigation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startFadeOut();
      }
    });
  }
  
  /// 페이드 아웃 시작
  void _startFadeOut() {
    setState(() {
      _isFadingOut = true;
    });
    
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'SWEN',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
} 