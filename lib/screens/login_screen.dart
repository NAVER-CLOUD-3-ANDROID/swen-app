import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final apiService = ApiService();

  void handleNaverLogin() {
    const naverLoginUrl = 'http://localhost:8080/naver'; // 실제 URL

    // 현재 창에서 리디렉션
    html.window.location.href = naverLoginUrl;
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
                Text(
                  'SWEN',
                  style: CustomWidgets.defaultTextStyle(
                    fontSize: AppSizes.fontSizeLarge + 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
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
                      backgroundColor: const Color(0xFF03C75A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: handleNaverLogin, // 네이버 로그인 요청 함수 연결
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
