# 뉴스 오디오 플레이어

Flutter로 개발된 뉴스 스크립트와 오디오 재생 앱입니다.

## 🎯 주요 기능

- **API 연동**: Spring Boot 서버에서 뉴스 스크립트와 오디오 URL을 가져옴
- **실시간 오디오 재생**: 앱 내에서 오디오 파일을 직접 재생
- **진행률 표시**: 재생 시간과 슬라이더로 진행률 확인
- **오류 처리**: 네트워크 오류 시 테스트 데이터로 대체

## 📱 지원 플랫폼

- ✅ Android (에뮬레이터/실기기)
- ✅ iOS (시뮬레이터/실기기)
- ❌ Web (현재 모바일 전용)

## 🛠 기술 스택

- **Flutter**: 3.2.3+
- **Dart**: 3.2.3+
- **audioplayers**: 5.2.1 (오디오 재생)
- **http**: 1.1.0 (API 통신)

## 🚀 시작하기

### 1. 프로젝트 클론
```bash
git clone <repository-url>
cd swen_flutter
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 앱 실행
```bash
# Android 에뮬레이터
flutter run

# iOS 시뮬레이터
flutter run -d ios
```

## 🔧 설정

### API 서버 설정
- **Android 에뮬레이터**: `http://10.0.2.2:8080/api/v1/news/play`
- **iOS 시뮬레이터**: `http://localhost:8080/api/v1/news/play`
- **실기기**: 실제 서버 IP 주소 사용

### API 응답 형식
```json
{
  "status": 200,
  "data": {
    "script": "뉴스 스크립트 내용...",
    "audioUrl": "https://example.com/audio.mp3"
  }
}
```

## 📁 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점 및 메인 UI
├── api_service.dart       # API 통신 서비스
└── audio_player.dart      # 오디오 플레이어 위젯
```

## 🎨 UI 구성

1. **메인 화면**: 중앙에 큰 재생 버튼
2. **스크립트 표시**: 버튼 클릭 시 상단에 뉴스 스크립트 표시
3. **오디오 플레이어**: 하단에 재생/일시정지, 진행률, 시간 표시

## 🔍 주요 클래스

### AppConstants
앱 전체에서 사용하는 상수들 (UI 크기, 메시지 등)

### ApiService
- `fetchNewsData()`: API에서 데이터 가져오기
- `extractAudioUrl()`: 다양한 오디오 URL 필드에서 URL 추출

### AudioPlayerWidget
- 실제 오디오 재생 기능
- 진행률 표시 및 제어
- 오류 처리

## 🐛 문제 해결

### 오디오가 재생되지 않는 경우
1. API 서버가 실행 중인지 확인
2. 오디오 URL이 유효한지 확인
3. 네트워크 연결 상태 확인

### 에뮬레이터에서 API 연결 실패
- Android: `10.0.2.2` 사용
- iOS: `localhost` 사용

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
