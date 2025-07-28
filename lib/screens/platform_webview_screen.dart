import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'web_webview_screen.dart'; // 이제 이걸 직접 import!
import 'native_webview_screen.dart'; // 기존 네이티브 WebView 화면

class PlatformWebViewScreen extends StatelessWidget {
  final String url;
  final String? title;
  final VoidCallback? onLoadFailed;

  const PlatformWebViewScreen({
    super.key,
    required this.url,
    this.title,
    this.onLoadFailed,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? WebWebViewScreen(url: url)
        : NativeWebViewScreen(
            url: url,
            title: title,
            onLoadFailed: onLoadFailed,
          );
  }
}
