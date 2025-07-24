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
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    // TODO: 실제 로그인 API 연동 예정
    // 임시로 바로 메인화면 이동
    Navigator.pushReplacementNamed(context, '/main');
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
                // 아이디 입력
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                // 비밀번호 입력
                TextField(
                  controller: _pwController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: AppSizes.spacingL),
                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onLoginPressed,
                    style: CustomWidgets.defaultButtonStyle(),
                    child: const Text('로그인'),
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