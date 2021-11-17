import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../constants.dart';

class RampWebView extends StatefulWidget {
  final String name;
  final String symbol;

  RampWebView({this.name, this.symbol});

  @override
  _RampWebViewState createState() => _RampWebViewState();
}

class _RampWebViewState extends State<RampWebView> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  StreamSubscription _onDestroy;

  StreamSubscription<String> _onUrlChanged;

  StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged = flutterWebviewPlugin.onStateChanged
        .listen((WebViewStateChanged state) async {
      print("onStateChanged: ${state.type} ${state.url}");
      if (state.url.startsWith("http://codiste.com") ||
          state.url.startsWith("https://www.codiste.com")) {
        Navigator.pushNamedAndRemoveUntil(
            context, homeRoute, (Route<dynamic> route) => false);
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("URL changed: $url");
    });
  }

  @override
  Widget build(BuildContext context) {
    String url = ModalRoute.of(context).settings.arguments;
    print("Ramp URL : $url");
    return WebviewScaffold(
      url: url,
      appBar: new AppBar(
        title: new Text("Buy ${this.widget.name} (${this.widget.symbol})"),
      ),
    );
  }
}

// https://ri-widget-staging-ropsten.firebaseapp.com/?userAddress=${this.address}&swapAsset=${this.symbol}&hostAppName=Crypto Wallet&defaultAsset=${this.symbol}&finalUrl=www.google.com
