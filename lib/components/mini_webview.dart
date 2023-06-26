import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MiniWebView extends StatefulWidget {
  const MiniWebView({super.key, required this.htmlString});

  final String htmlString;

  @override
  State<MiniWebView> createState() => _MiniWebViewState();
}

class _MiniWebViewState extends State<MiniWebView> {
  final _controllerCompleter = Completer<WebViewController>();
  WebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return WebView(
      onWebViewCreated: (controller) {
        _controllerCompleter.complete(controller);
        this.controller = controller;
        controller.loadHtmlString(widget.htmlString);
      },
      initialUrl: 'about:blank',
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: false,
    );
  }
}
