import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logger/logger.dart';

/// A widget that handles authentication using a WebView.
class WebViewAuth extends StatefulWidget {
  /// The request token used for authentication.
  final String requestToken;

  /// Creates a WebViewAuth widget.
  ///
  /// The [requestToken] is required and used to construct the authentication URL.
  const WebViewAuth({super.key, required this.requestToken});

  @override
  State<WebViewAuth> createState() => _WebViewAuthState();
}

class _WebViewAuthState extends State<WebViewAuth> {
  /// WebViewController instance to control the WebView.
  late final WebViewController controller;

  /// Indicates whether the WebView is currently loading.
  bool isLoading = true;

  /// Logger instance for logging events and errors.
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// Initializes the WebView with necessary settings and navigation delegate.
  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: _onProgress,
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(
        Uri.parse(
            'https://www.themoviedb.org/authenticate/${widget.requestToken}'),
      );
    _log('WebView initialized with token: ${widget.requestToken}');
  }

  /// Logs messages with appropriate level.
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[WebViewAuth] $timestamp: $message';
    _logger.d(logMessage);
  }

  /// Handles WebView loading progress.
  void _onProgress(int progress) {
    _log('WebView is loading (progress : $progress%)');
  }

  /// Handles page start loading event.
  void _onPageStarted(String url) {
    _log('Page started loading: $url');
  }

  /// Handles page finish loading event.
  void _onPageFinished(String url) {
    _log('Page finished loading: $url');
    setState(() {
      isLoading = false;
    });
  }

  /// Handles web resource errors.
  void _onWebResourceError(WebResourceError error) {
    _log('Web resource error: ${error.description}');
  }

  /// Handles navigation requests.
  ///
  /// Returns [NavigationDecision.navigate] to allow navigation,
  /// or [NavigationDecision.prevent] to prevent it.
  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    _log('Navigation request to: ${request.url}');
    if (request.url.contains('/authenticate/') &&
        request.url.endsWith('/allow')) {
      _log('Authentication approved. URL: ${request.url}');
      // Navigator.of(context).pop(true);
      // return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authenticate')),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
