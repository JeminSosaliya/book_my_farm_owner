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

    print("🚀 Fetching blocked dates for farmhouse: $farmhouseId");

    try {
      final String? token = await getToken();
      print("🔑 Token status: ${token != null ? '✅ Available' : '❌ Missing'}");

      final Map<String, dynamic> queryParams = {
        if (startDate != null)
          'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
      };

      print("📅 Query Params: $queryParams");

      final Uri uri = Uri.parse(
        '$baseUrlGlobal/dashboard/farm-houses/$farmhouseId/blocked-dates',
      ).replace(queryParameters: queryParams);

      print("🌐 API Endpoint: $uri");

      final Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      log("📨 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data['success'] == true && data['data']["blockedDates"] is List) {
          final List<dynamic> dataList = data['data']["blockedDates"];
          print("✅ API Success: Received ${dataList.length} blocked records");

          _blockedDates = dataList.map((item) {
            // final List<String> nights = (item['dates'] as List<dynamic>)
            //     .map((e) => DateTime.parse(e.toString()))
            //     .map((d) => d.toIso8601String().split('T')[0])
            //     .toList()
            //   ..sort();
            String date = item['date']??"";
            if(date.isNotEmpty){
              date = DateTime.parse(date).toIso8601String().split('T')[0];
            }

            // print(
            //     "📦 Processed blocked entry: ${item['_id']} with ${nights.length} nights");

            return BlockedDate(
              id: item['_id'] ?? '',
              farmId: item['farmId'] ?? '',
              farmName: item['farmName'] ?? '',
              // dates: nights,
              dates: [date],
              reason: item['reason'] ?? '',
              createdBy: item['createdBy'] ?? '',
              createdAt:
                  DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
              updatedAt:
                  DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
            );
          }).toList();

          _isLoading = false;
          _error = null;
          notifyListeners();

          print(
              "🎉 Successfully updated local blockedDates list (${_blockedDates.length} entries)");
        } else {
          print("⚠️ Unexpected API response structure: $data");
          throw Exception('Invalid response format');
        }
      } else {
        print("❌ Server responded with status: ${response.statusCode}");
        throw Exception(
            'Failed to fetch blocked dates: ${response.statusCode}');
      }
    } catch (e) {
      _error = '❗ Error fetching blocked dates: $e';
      _isLoading = false;
      notifyListeners();

      print("💥 Exception occurred while fetching blocked dates: $e");
    } finally {
      print("🏁 Fetch blocked dates completed for farmhouse: $farmhouseId\n");
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

    print("🚀 Starting to block dates for farmhouse: $farmhouseId");
    print("📅 Dates to block (nights only): $dates");
    print("📝 Reason: $reason");

    try {
      final List<String> nightsToBlock = dates;
      final String? token = await getToken();

      print(
          "🔑 Retrieved token: ${token != null ? '✅ Available' : '❌ Missing'}");

      final String url =
          '$baseUrlGlobal/dashboard/farm-houses/$farmhouseId/blocked-dates';
      final Map<String, dynamic> requestBody = {
        'farmId': farmhouseId,
        'dates': nightsToBlock,
        'reason': reason,
      };

      print("🌐 API Endpoint: $url");
      print("📦 Request Body: $requestBody");

      final Uri uri = Uri.parse(url);
      final Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");

      final dynamic data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Successfully blocked dates for farmhouse: $farmhouseId");

        _blockedDates.add(
          BlockedDate(
            id: data['_id'] ?? '',
            farmId: farmhouseId,
            farmName: data['farmName'] ?? '',
            dates: nightsToBlock,
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

        print("🎉 Blocked dates added locally & state updated successfully!");
        return true;
      } else {
        _error = data['message'] ??
            data['error'] ??
            data['errors']?.toString() ??
            'Failed to block dates (Status: ${response.statusCode})';

        print("⚠️ Failed to block dates → Error: $_error");

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '💥 Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      print("💣 Exception occurred while blocking dates: $e");
      return false;
    } finally {
      print("🏁 Block date request completed for farmhouse: $farmhouseId\n");
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
