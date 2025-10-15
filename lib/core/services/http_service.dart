import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

/// Centralized HTTP service that handles authentication errors automatically
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isVerifiedKey = 'is_verified';

  // Prevent duplicate logout runs
  bool _isLoggingOut = false;

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Check if response indicates authentication error
  bool _isAuthError(Response response) {
    // Check HTTP status code
    if (response.statusCode == 401) {
      return true;
    }

    // Check response body for auth error patterns
    try {
      final responseBody = response.body;
      if (responseBody.isNotEmpty) {
        final data = jsonDecode(responseBody);

        // Check for success: false with auth-related error messages
        if (data is Map<String, dynamic>) {
          final success = data['success'];
          final error = data['error']?.toString().toLowerCase() ?? '';
          final details = data['details']?.toString().toLowerCase() ?? '';
          final message = data['message']?.toString().toLowerCase() ?? '';

          if (success == false) {
            final authErrorPatterns = [
              'please authenticate',
              'jwt expired',
              'token expired',
              'authentication failed',
              'unauthorized',
              'invalid token',
              'access denied',
              'authentication required'
            ];

            final combinedText = '$error $details $message';
            return authErrorPatterns
                .any((pattern) => combinedText.contains(pattern));
          }
        }
      }
    } catch (e) {
      // If JSON parsing fails, only rely on status code
      log('HttpService: Failed to parse response body for auth check: $e');
    }

    return false;
  }

  /// Centralized logout routine that clears all user data
  Future<void> _performLogout() async {
    if (_isLoggingOut) {
      log('HttpService: Logout already in progress, skipping duplicate logout');
      return;
    }

    _isLoggingOut = true;
    log('HttpService: Performing centralized logout');

    try {
      // Clear all stored user data
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_isVerifiedKey);

      // Clear any other cached data that might exist
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.contains('user') ||
            key.contains('auth') ||
            key.contains('profile')) {
          await prefs.remove(key);
        }
      }

      log('HttpService: Cleared all user data from storage');

      // Reset in-memory state by notifying providers
      // This will be handled by the navigation system
    } catch (e) {
      log('HttpService: Error during logout: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  /// Navigate to login screen and clear all previous routes
  void _navigateToLogin() {
    try {
      // Get the current navigator context
      final context = navigatorKey.currentContext;
      if (context != null) {
        log('HttpService: Navigating to login screen');
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      log('HttpService: Error navigating to login: $e');
    }
  }

  /// Handle authentication error by logging out and navigating to login
  Future<void> _handleAuthError() async {
    log('HttpService: Authentication error detected, initiating logout');

    await _performLogout();
    _navigateToLogin();
  }

  /// Get authentication token
  Future<String?> _getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  /// Make authenticated GET request with automatic auth error handling
  Future<Response> authenticatedGet(String url,
      {Map<String, String>? headers}) async {
    final token = await _getToken();

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    log('HttpService: GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: requestHeaders,
    );

    log('HttpService: GET response status: ${response.statusCode}');

    if (_isAuthError(response)) {
      await _handleAuthError();
    }

    return response;
  }

  /// Make authenticated POST request with automatic auth error handling
  Future<Response> authenticatedPost(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _getToken();

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    log('HttpService: POST $url');
    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );

    log('HttpService: POST response status: ${response.statusCode}');

    if (_isAuthError(response)) {
      await _handleAuthError();
    }

    return response;
  }

  /// Make authenticated PUT request with automatic auth error handling
  Future<Response> authenticatedPut(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _getToken();

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    log('HttpService: PUT $url');
    final response = await http.put(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );

    log('HttpService: PUT response status: ${response.statusCode}');

    if (_isAuthError(response)) {
      await _handleAuthError();
    }

    return response;
  }

  /// Make authenticated DELETE request with automatic auth error handling
  Future<Response> authenticatedDelete(String url,
      {Map<String, String>? headers}) async {
    final token = await _getToken();

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    log('HttpService: DELETE $url');
    final response = await http.delete(
      Uri.parse(url),
      headers: requestHeaders,
    );

    log('HttpService: DELETE response status: ${response.statusCode}');

    if (_isAuthError(response)) {
      await _handleAuthError();
    }

    return response;
  }

  /// Make unauthenticated GET request (for public endpoints)
  Future<Response> get(String url, {Map<String, String>? headers}) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    log('HttpService: GET $url (unauthenticated)');
    return await http.get(
      Uri.parse(url),
      headers: requestHeaders,
    );
  }

  /// Make unauthenticated POST request (for public endpoints)
  Future<Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    log('HttpService: POST $url (unauthenticated)');
    return await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
