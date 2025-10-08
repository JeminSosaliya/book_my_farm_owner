import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isAuthenticated();
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize auth state: $e';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String mobileNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final Map<String, dynamic> response =
          await _authService.sendOtp("91$mobileNumber");
      _error = null;
      return response['success'] == true;
    } catch (e) {
      _error = '$e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(
    String mobileNumber,
    String otp,
    String fcmToken,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final Map<String, dynamic> response = await _authService.verifyOtp(
        "91$mobileNumber",
        otp,
        fcmToken,
      );
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['token'] != null) {
        _isAuthenticated = true;
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Invalid OTP';
        return false;
      }
    } catch (e) {
      _error = 'Failed to verify OTP: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Failed to logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
