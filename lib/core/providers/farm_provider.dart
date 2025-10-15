import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../main.dart';
import '../models/farm_house.dart';
import '../models/booking_analytics.dart';
import '../services/http_service.dart';

class FarmProvider with ChangeNotifier {
  List<FarmHouse> _farms = [];
  BookingAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;
  static const String _tokenKey = 'auth_token';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  List<FarmHouse> get farms => _farms;

  BookingAnalytics? get analytics => _analytics;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await _prefs;
    final String? token = prefs.getString(_tokenKey);
    print("getToken: $token");
    return token;
  }

  Future<void> fetchFarms() async {
    await Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      final Response response = await HttpService().authenticatedGet(
        '$baseUrlGlobal/dashboard/farm-houses',
      );

      log("FARM HOUSE URL : $baseUrlGlobal/dashboard/farm-houses");
      log("FARM STATUS CODE: ${response.statusCode}");
      log("FARM RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          await Future.microtask(() {
            _farms = (responseData['data'] as List)
                .map((json) => FarmHouse.fromJson(json))
                .toList();
            _isLoading = false;
            _error = null;
            notifyListeners();
          });
        } else {
          await Future.microtask(() {
            _error = 'Invalid response format';
            _isLoading = false;
            notifyListeners();
          });
        }
      } else {
        await Future.microtask(() {
          _error = 'Failed to fetch farms: ${response.statusCode}';
          _isLoading = false;
          notifyListeners();
        });
      }
    } catch (e) {
      await Future.microtask(() {
        log("FARM ERROR: $e");
        _error = 'Error fetching farms: $e';
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<void> fetchAnalytics() async {
    await Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      final Response response = await HttpService().authenticatedGet(
        '$baseUrlGlobal/dashboard/booking-analytics',
      );
      log("ANALYTICS STATUS URL : $baseUrlGlobal/dashboard/booking-analytics");
      log("ANALYTICS STATUS CODE: ${response.statusCode}");
      log("ANALYTICS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        await Future.microtask(() {
          _analytics = BookingAnalytics.fromJson(data["data"]);
          _isLoading = false;
          _error = null;
          notifyListeners();
        });
      } else {
        await Future.microtask(() {
          _error = 'Failed to fetch analytics: ${response.statusCode}';
          _isLoading = false;
          notifyListeners();
        });
      }
    } catch (e) {
      await Future.microtask(() {
        log("ANALYTICS ERROR: $e");
        _error = 'Error fetching analytics: $e';
        _isLoading = false;
        notifyListeners();
      });
    }
  }
}
