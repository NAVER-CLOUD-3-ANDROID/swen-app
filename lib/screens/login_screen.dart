import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../widgets/custom_widgets.dart';
import 'package:naver_login/naver_login.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 네이버 로그인 버튼 클릭 시 호출될 함수 (임시)
  Future<void> _handleNaverLogin() async {
    try {
      final NaverLoginResult result = await NaverLogin.login();
      if (result.status == NaverLoginStatus.loggedIn) {
        final accessToken = result.accessToken;
        // 백엔드 인증 요청
        await ApiService.loginWithNaver(accessToken);
        // 로그인 성공 시 메인화면 이동
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네이버 로그인 실패: ${result.errorMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고
                Text(
                  'SWEN',
                  style: CustomWidgets.defaultTextStyle(
                    fontSize: AppSizes.fontSizeLarge + 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                // 네이버 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/images/naver_icon.png',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text('네이버로 로그인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03C75A), // 네이버 그린
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _handleNaverLogin,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 