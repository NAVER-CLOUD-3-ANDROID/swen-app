// Flutter 앱의 기본 패키지들을 import
import 'package:flutter/material.dart';
// HTTP 요청을 위한 패키지 import (API 호출용)
import 'package:http/http.dart' as http;
// JSON 데이터를 파싱하기 위한 패키지 import
import 'dart:convert';

// 앱의 시작점 (main 함수) - Flutter 앱이 실행될 때 가장 먼저 호출되는 함수
void main() {
  // runApp: Flutter 앱을 시작하는 함수
  // MyApp 위젯을 루트 위젯으로 설정하여 앱을 실행
  runApp(const MyApp());
}

// 앱 전체의 뼈대가 되는 StatelessWidget
// StatelessWidget: 상태가 변하지 않는 정적인 위젯
class MyApp extends StatelessWidget {
  // 생성자: 위젯이 생성될 때 호출되는 함수
  // super.key: 부모 위젯에서 전달받은 키값
  const MyApp({super.key});

  // build 메서드: 위젯이 화면에 그려질 때 호출되는 함수
  // BuildContext: 위젯 트리에서 현재 위치를 나타내는 객체
  @override
  Widget build(BuildContext context) {
    // MaterialApp: Material Design을 사용하는 앱의 루트 위젯
    // 앱의 전역 테마, 라우팅, 홈 위젯 등을 설정
    return MaterialApp(
      title: 'Simple Button App', // 앱의 제목 (앱 바에 표시됨)
      theme: ThemeData(
        // ColorScheme: 앱의 색상 테마를 설정
        // fromSeed: 하나의 색상으로부터 전체 색상 팔레트를 자동 생성
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Material 3 디자인 시스템 사용
        fontFamily: 'Roboto', // 기본 폰트를 Roboto로 설정 (외부 폰트 로드 방지)
      ),
      home: const MyHomePage(), // 앱이 시작될 때 보여줄 첫 화면 위젯
    );
  }
}

// 실제로 화면에 보여지는 부분 (StatefulWidget으로 변경 - 상태 관리 필요)
// StatefulWidget: 상태가 변할 수 있는 동적인 위젯
class MyHomePage extends StatefulWidget {
  // 생성자: 위젯이 생성될 때 호출되는 함수
  const MyHomePage({super.key});

  // createState: StatefulWidget이 State 객체를 생성할 때 호출되는 함수
  // State 객체: 위젯의 상태를 관리하는 객체
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// MyHomePage의 상태를 관리하는 클래스
// State 클래스: 위젯의 상태와 생명주기를 관리
class _MyHomePageState extends State<MyHomePage> {
  // 상태 변수들: 위젯의 상태를 저장하는 변수들
  String _response = ''; // API 응답을 저장할 변수 (빈 문자열로 초기화)
  bool _isLoading = false; // 로딩 상태를 저장할 변수 (false로 초기화)

  // API 요청을 보내는 비동기 함수
  // async: 비동기 함수임을 나타내는 키워드
  // Future<void>: 반환값이 없는 비동기 작업을 나타냄
  Future<void> fetchData() async {
    // setState: 위젯의 상태를 변경하고 화면을 다시 그리도록 하는 함수
    setState(() {
      _isLoading = true; // 로딩 상태를 true로 변경 (로딩 시작)
      _response = ''; // 이전 응답을 초기화 (화면을 깨끗하게 만듦)
    });

    // try-catch: 예외 처리를 위한 구문
    try {
      // 실제 API 엔드포인트로 GET 요청 보내기
      // Uri.parse: 문자열을 URI 객체로 변환
      final url = Uri.parse('http://localhost:8080/api/v1/news/play');
      // http.get: GET 요청을 보내는 함수 (비동기)
      // await: 비동기 작업이 완료될 때까지 기다림
      final response = await http.get(url);

      // 응답이 성공적이면 상태 업데이트
      // statusCode: HTTP 응답 코드 (200 = 성공)
      if (response.statusCode == 200) {
        // JSON 응답을 파싱
        // json.decode: JSON 문자열을 Dart 객체로 변환
        final jsonResponse = json.decode(response.body);
        
        // data 부분 추출
        // null 체크: 데이터가 존재하는지 확인
        if (jsonResponse['data'] != null) {
          final data = jsonResponse['data']; // data 객체를 변수에 저장
          
          // 스크립트 추출
          if (data['script'] != null) {
            setState(() {
              _response = data['script']; // 스크립트만 저장
            });
          } else {
            setState(() {
              _response = '스크립트 데이터를 찾을 수 없습니다.';
            });
          }
        } else {
          setState(() {
            _response = '스크립트 데이터를 찾을 수 없습니다.';
          });
        }
      } else {
        // HTTP 오류 처리
        setState(() {
          _response = '서버 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      // 예외 발생 시 에러 메시지 표시
      // catch: try 블록에서 예외가 발생했을 때 실행되는 블록
      setState(() {
        _response = '연결 오류: $e'; // 예외 메시지를 화면에 표시
      });
    } finally {
      // finally: try-catch 블록이 끝나면 항상 실행되는 블록
      setState(() {
        _isLoading = false; // 로딩 상태를 false로 변경 (로딩 완료)
      });
    }
  }

  // build 메서드: 위젯이 화면에 그려질 때 호출되는 함수
  @override
  Widget build(BuildContext context) {
    // Scaffold: Material Design의 기본 레이아웃 구조를 제공하는 위젯
    // 앱바, 바디, 플로팅 액션 버튼 등을 쉽게 구성할 수 있음
    return Scaffold(
      body: Center(
        // Center: 자식 위젯을 화면 중앙에 배치하는 위젯
        child: Column(
          // Column: 자식 위젯들을 세로로 배치하는 위젯
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          children: [
            // API 요청 버튼
            ElevatedButton(
              // onPressed: 버튼이 눌렸을 때 실행될 함수
              // 로딩 중일 때는 null을 전달하여 버튼을 비활성화
              onPressed: _isLoading ? null : fetchData,
              child: _isLoading 
                ? const Row(
                    // Row: 자식 위젯들을 가로로 배치하는 위젯
                    mainAxisSize: MainAxisSize.min, // 필요한 만큼만 크기 사용
                    children: [
                      // CircularProgressIndicator: 로딩 스피너 위젯
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8), // 8픽셀 간격
                      Text('요청 중...'), // 로딩 텍스트
                    ],
                  )
                : const Text('스크립트 요청'), // 일반 상태의 버튼 텍스트
            ),
            const SizedBox(height: 20), // 20픽셀 세로 간격
            // 로딩 중일 때 로딩 표시
            if (_isLoading) // 조건부 렌더링: _isLoading이 true일 때만 표시
              const Column(
                children: [
                  CircularProgressIndicator(), // 큰 로딩 스피너
                  SizedBox(height: 16), // 16픽셀 간격
                  Text('스크립트를 가져오는 중...'), // 로딩 메시지
                ],
              ),
            // 스크립트 내용만 표시
            if (_response.isNotEmpty && !_isLoading) // 응답이 있고 로딩이 아닐 때만 표시
              Expanded(
                // Expanded: 남은 공간을 모두 차지하도록 하는 위젯
                child: SingleChildScrollView(
                  // SingleChildScrollView: 내용이 많을 때 스크롤 가능하게 만드는 위젯
                  padding: const EdgeInsets.all(16.0), // 모든 방향에 16픽셀 여백
                  child: Text(
                    _response, // API에서 받은 스크립트 내용
                    style: const TextStyle(fontSize: 16), // 텍스트 크기 16
                    textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// crystal
