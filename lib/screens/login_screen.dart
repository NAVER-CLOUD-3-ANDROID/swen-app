import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../widgets/custom_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 네이버 로그인 버튼 클릭 시 호출될 함수 (임시)
  Future<void> _handleNaverLogin() async {
    // TODO: 네이버 로그인 연동 예정
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('네이버 로그인 시도(연동 예정)')),
    );
    // 로그인 성공 시: Navigator.pushReplacementNamed(context, '/main');
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