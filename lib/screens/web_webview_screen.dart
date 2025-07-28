import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class WebWebViewScreen extends StatelessWidget {
  final String url;
  const WebWebViewScreen({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    final viewId = 'iframe-${url.hashCode}';

    // 이 부분이 중요!
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final element = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen';
      return element;
    });

    return HtmlElementView(viewType: viewId);
  }
}
