import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TradingView extends StatefulWidget {
  @override
  _TradingViewState createState() => _TradingViewState();
}

class _TradingViewState extends State<TradingView> {
  InAppWebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            supportZoom: false,
            transparentBackground: true,
          ),
        ),
        initialUrlRequest: URLRequest(
          url: Uri.parse('http://localhost:29588/assets/webview/test.html'),
        ),
        // Make sure the webview get all the gesture
        gestureRecognizers: [
          Factory(() => EagerGestureRecognizer()),
        ].toSet(),
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onLoadStart: (controller, url) {
          // Webview start loading
          _controller = controller;
        },
        onLoadStop: (controller, url) {
          // Webview done loading
          _controller = controller;

          // Dart -> JS
          controller.evaluateJavascript(source: 'runMyFunction();');

          // JS -> Dart
          controller.addJavaScriptHandler(
            handlerName: 'getIntraday',
            callback: (arguments) async {
              // Handle arguments passed from js
              // return jsonEncode(something);
              return 'Hello';
            },
          );
        },
        onLoadError: (controller, url, code, message) {
          // Webview error loading
          _controller = controller;
        },
        onLoadHttpError: (controller, url, statusCode, description) {
          // Webview HTTP error
          _controller = controller;
        },
      ),
    );
  }
}
