import 'dart:convert';
import 'dart:developer';
import 'package:book_my_farm_owner/core/config/api_config.dart';
import 'package:book_my_farm_owner/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../notification/notification.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isVerifiedKey = 'is_verified';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlGlobal/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      log("Send Otp URL : $baseUrlGlobal/auth/send-otp");
      print("login send otp body: $mobileNumber");
      print("login send otp status code: ${response.statusCode}");
      print("login send otp body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp, String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final fcmToken = prefs.getString(NotificationUtils.fcmTokenKey);
      // log("fcmToken ========================================== $fcmToken");
      // if (fcmToken == null) throw Exception('FCM token not found in SharedPreferences');
      final response = await http.post(
        Uri.parse('$baseUrlGlobal/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'otp': otp,
          "fcmToken": fcmToken,
        }),
      );

      log("Verify Otp URL : $baseUrlGlobal/auth/verify-otp");
      print("login verify otp body: $mobileNumber");
      print("login verify otp status code: ${response.statusCode}");
      print("login verify otp body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];
          
          if (token != null) {
            final prefs = await _prefs;
            await prefs.setString(_tokenKey, token);
            print("login verify otp token saved: $token");
            
            if (user != null) {
              await prefs.setString(_userIdKey, user['id']);
              await prefs.setBool(_isVerifiedKey, user['isVerified'] ?? false);
              print("login verify otp user data saved: ${user['id']}, ${user['isVerified']}");
            }
          }
        }
        return data;
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey);
    print("getToken: $token");
    return token;
  }

  Future<bool> isAuthenticated() async {
    final prefs = await _prefs;
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getString(_userIdKey);
    final isVerified = prefs.getBool(_isVerifiedKey) ?? false;
    print("isAuthenticated check - token: $token, userId: $userId, isVerified: $isVerified");
    return token != null && userId != null && isVerified;
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        print("getProfile: No token found");
        throw Exception('No token found');
      }
      log("URL :- $baseUrlGlobal/dashboard/profile");
      print("getProfile: Making API call with token: $token");
      final response = await http.get(
        Uri.parse('$baseUrlGlobal/dashboard/profile'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("getProfile status code: ${response.statusCode}");
      print("getProfile response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['farmOwner'] != null) {
          print("getProfile: Successfully parsed farm owner data");
          return data;
        } else {
          print("getProfile: Invalid response structure");
          throw Exception('Invalid profile data structure');
        }
      } else {
        print("getProfile: API call failed with status ${response.statusCode}");
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      print("getProfile error: $e");
      throw Exception('Error getting profile: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_isVerifiedKey);
    print("logout: cleared all auth data");
  }
} 