import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:enterkomputer/core/secret.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Base api services
class BaseApiService {
  /// Logger instance
  final Logger _logger = Logger();

  /// Base tmdb api url
  final String baseUrl = "https://api.themoviedb.org/3";

  /// API key for authentication
  final String apiKey = AppSecret.apiKey;

  /// API key for token bearer
  final String apiToken = AppSecret.apiToken;

  /// Session ID
  String? _sessionId;

  /// GET Session ID
  String? get sessionId => _sessionId;

  /// SET Session ID
  set setSessionId(String? value) {
    _sessionId = value;
    _log('Session ID set: $_sessionId');
  }

  /// Returns the headers required for API requests.
  ///
  /// The headers include Accept, Content-Type, Authorization, and Host.
  Future<Map<String, String>> _getHeaders() async {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiToken',
      'Host': 'api.themoviedb.org',
    };
  }

  /// Logs http activity with logger.
  void _log(String message, {String? method, String? url}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '[BaseApiService] $timestamp - ${method ?? ''} ${url ?? ''}: $message';

    if (kDebugMode) {
      _logger.d(logMessage);
    } else {
      _logger.i(logMessage);
    }
  }

  /// Performs a GET request to [endpoint].
  ///
  /// Returns the decoded JSON response.
  /// Throws an exception if the request fail
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    _log('Sending request', method: 'GET', url: url.toString());
    final response = await http.get(url, headers: headers);
    _logResponse(response);

    return _handleResponse(response);
  }

  /// Performs a POST request to the specified [endpoint] with the given [body].
  ///
  /// Returns the decoded JSON response.
  /// Throws an exception if the request fails.
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    body['api_key'] = apiKey;

    _log('Sending request', method: 'POST', url: url.toString());
    _log('Request body: ${json.encode(body)}');

    final response =
        await http.post(url, headers: headers, body: json.encode(body));
    _logResponse(response);

    return _handleResponse(response);
  }

  /// Logs the response details.
  void _logResponse(http.Response response) {
    _log('Response status: ${response.statusCode}');
    _log('Response body: ${response.body}');
  }

  /// Handles the HTTP response.
  ///
  /// If the status code is between 200 and 299, it returns the decoded JSON body.
  /// Otherwise, it throws an exception with the status code and reason phrase.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorMessage =
          'HTTP request failed, statusCode: ${response.statusCode}, reason: ${response.reasonPhrase}';
      _log('Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }
}
