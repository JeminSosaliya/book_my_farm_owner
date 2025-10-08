import 'dart:convert';
import 'dart:developer';

import 'package:book_my_farm_owner/core/models/farm_house.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/locale_keys.g.dart';
import '../../main.dart';
import '../models/blocked_date.dart';

class BlockedDatesProvider with ChangeNotifier {
  List<BlockedDate> _blockedDates = [];
  List<FarmHouse> _farms = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedReason;
  List<String> _selectedDates = [];
  final List<String> _reasons = [
    LocaleKeys.maintenance_work.tr(),
    LocaleKeys.farm_offline.tr(),
    LocaleKeys.special_event.tr(),
    LocaleKeys.weather_conditions.tr(),
    LocaleKeys.other_text.tr(),
  ];

  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;

  TimeOfDay? get checkInTime => _checkInTime;

  TimeOfDay? get checkOutTime => _checkOutTime;

  List<BlockedDate> get blockedDates => _blockedDates;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get selectedReason => _selectedReason;

  List<String> get selectedDates => _selectedDates;

  List<String> get reasons => _reasons;

  List<FarmHouse> get farms => _farms;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchBlockedDates(
    String farmhouseId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final String? token = await getToken();
      final Map<String, dynamic> queryParams = {
        if (startDate != null)
          'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
      };

      final Uri uri = Uri.parse(
        '$baseUrlGlobal/dashboard/farm-houses/$farmhouseId/blocked-dates',
      ).replace(queryParameters: queryParams);
      log("🔗 Blocked Dates URL: $uri");

      final Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      List<String> getDatesBetween(DateTime start, DateTime end) {
        final List<String> dates = [];
        DateTime current = start;
        while (!current.isAfter(end)) {
          dates.add(current.toIso8601String().split('T')[0]);
          current = current.add(Duration(days: 1));
        }
        return dates;
      }

      log("📡 Response Code: ${response.statusCode}");
      log("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> dataList = data['data'];
          _blockedDates = dataList.map((item) {
            final List<DateTime> parsedDate = (item["dates"] as List<dynamic>)
                .map((e) => DateTime.parse(e))
                .toList();
            final List<String> dates =
                getDatesBetween(parsedDate.first, parsedDate.last);
            return BlockedDate(
              id: item['_id'] ?? '',
              farmId: item['farmId'] ?? '',
              farmName: item['farmName'] ?? '',
              dates: dates,
              reason: item['reason'] ?? '',
              createdBy: item['createdBy'] ?? '',
              createdAt: DateTime.parse(item['createdAt']),
              updatedAt: DateTime.parse(item['updatedAt']),
            );
          }).toList();
          _isLoading = false;
          _error = null;
          notifyListeners();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            '❌ Failed to fetch blocked dates: ${response.statusCode}');
      }
    } catch (e) {
      _error = '❗ Error fetching blocked dates: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> blockDates(
    String farmhouseId,
    List<String> dates,
    String reason,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final List<String> datesToBlock =
          dates.length > 1 ? dates.sublist(0, dates.length - 1) : dates;

      final String? token = await getToken();
      final String url =
          '$baseUrlGlobal/dashboard/farm-houses/$farmhouseId/blocked-dates';
      final Map<String, dynamic> requestBody = {
        'farmId': farmhouseId,
        'dates': datesToBlock,
        'reason': reason,
      };
      print("Base URL :- $url");
      print("Request Body :- $requestBody");
      final Uri uri = Uri.parse(url);
      print(
          "id is $farmhouseId dates is $datesToBlock (excluding checkout date) and reason is $reason and token is $token");
      final Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      final dynamic data = json.decode(response.body);
      print(
          "data post $data and ${response.statusCode} and body is ${response.body} ");
      if (response.statusCode == 200 || response.statusCode == 201) {
        _blockedDates.add(
          BlockedDate(
            id: data['_id'] ?? '',
            farmId: farmhouseId,
            farmName: data['farmName'] ?? '',
            dates: datesToBlock,
            reason: reason,
            createdBy: data['createdBy'] ?? '',
            createdAt: DateTime.parse(
              data['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
            updatedAt: DateTime.parse(
              data['updatedAt'] ?? DateTime.now().toIso8601String(),
            ),
          ),
        );
        _isLoading = false;
        _selectedDates = [];
        _selectedReason = null;
        notifyListeners();
        return true;
      } else {
        print("error is ${data["message"]} and success is ${data["success"]}");
        _error = data['message'] ??
            data['error'] ??
            data['errors']?.toString() ??
            'Failed to block dates (Status: ${response.statusCode})';
        print("error is $_error");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setSelectedReason(String? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  void addSelectedDate(String date) {
    if (!_selectedDates.contains(date)) {
      _selectedDates.add(date);
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedDates = [];
    _selectedReason = null;
    notifyListeners();
  }
}
