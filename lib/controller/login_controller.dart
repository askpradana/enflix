import 'package:enterkomputer/core/api.dart';
import 'package:enterkomputer/home.dart';
import 'package:enterkomputer/webview.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Controller for handling login functionality
class LoginController extends GetxController {
  /// Logger instance
  final Logger _logger = Logger();

  /// Observable string to store the request token
  var requestToken = ''.obs;

  /// Observable boolean to track loading state
  final isLoading = false.obs;

  /// Base API service instance
  final BaseApiService _apiService = BaseApiService();

  /// Logs messages with appropriate level based on debug mode
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[LoginController] $timestamp: $message';

    if (kDebugMode) {
      _logger.d(logMessage);
    } else {
      _logger.i(logMessage);
    }
  }

  /// Initiates the login process
  ///
  /// Fetches a new request token and opens the WebView for authentication
  Future<void> login() async {
    isLoading.value = true;
    try {
      _log('Initiating login process');
      var response = await _apiService.get('/authentication/token/new');
      if (response != null && response['request_token'] != null) {
        requestToken.value = response['request_token'];
        _log('Received request token: ${requestToken.value}');
        await openWebView();
      } else {
        _log('Failed to get initial request token');
      }
    } catch (e) {
      _log('Error during login: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens WebView for authentication
  ///
  /// After successful authentication, it proceeds to create a session
  Future<void> openWebView() async {
    _log('Opening WebView for authentication');
    await Get.to(() => WebViewAuth(requestToken: requestToken.value));
    _log('WebView authentication successful');
    _log('Approved request token: ${requestToken.value}');
    await Future.delayed(const Duration(seconds: 1));
    createSession();
  }

  /// Creates a new session using the approved request token
  ///
  /// On success, navigates to the HomePage
  Future<void> createSession() async {
    try {
      _log('Creating session with token: ${requestToken.value}');
      var response = await _apiService.post(
          '/authentication/session/new', {'request_token': requestToken.value});

      if (response['success'] == true) {
        _log('Session created successfully');
        BaseApiService service = BaseApiService();
        service.setSessionId = response['session_id'];
        Get.to(() => HomePage());
      } else {
        _log('Failed to create session. Response: $response');
      }
    } catch (e) {
      _log('Error creating session: $e');
    }
  }
}
