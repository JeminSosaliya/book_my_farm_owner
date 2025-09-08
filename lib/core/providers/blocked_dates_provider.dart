// import 'dart:developer';
// import 'package:book_my_farm_owner/core/models/farm_house.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../generated/locale_keys.g.dart';
// import '../models/blocked_date.dart';
// import '../config/api_config.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BlockedDatesProvider with ChangeNotifier {
//   List<BlockedDate> _blockedDates = [];
//   List<FarmHouse> _farms = [];
//   bool _isLoading = false;
//   String? _error;
//   String? _selectedReason;
//   List<String> _selectedDates = [];
//   final List<String> _reasons = [
//     LocaleKeys.maintenance_work.tr(),
//     LocaleKeys.farm_offline.tr(),
//     LocaleKeys.special_event.tr(),
//     LocaleKeys.weather_conditions.tr(),
//     LocaleKeys.other_text.tr(),
//   ];
//
//   TimeOfDay? _checkInTime;
//   TimeOfDay? _checkOutTime;
//
//   TimeOfDay? get checkInTime => _checkInTime;
//   TimeOfDay? get checkOutTime => _checkOutTime;
//
//   List<BlockedDate> get blockedDates => _blockedDates;
//
//   bool get isLoading => _isLoading;
//
//   String? get error => _error;
//
//   String? get selectedReason => _selectedReason;
//
//   List<String> get selectedDates => _selectedDates;
//
//   List<String> get reasons => _reasons;
//
//   List<FarmHouse> get farms => _farms;
//
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }
//
//   Future<void> fetchBlockedDates(String farmId,
//       {DateTime? startDate, DateTime? endDate}) async {
//     await Future.microtask(() {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
//     });
//
//     try {
//       final token = await getToken();
//       final queryParams = {
//         if (startDate != null)
//           'startDate': startDate.toIso8601String().split('T')[0],
//         if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
//       };
//
//       final uri = Uri.parse(
//               '${ApiConfig.baseUrl}/dashboard/farm-houses/$farmId/blocked-dates')
//           .replace(queryParameters: queryParams);
//
//       final response = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       log("Blocked Dates Url :- ${ApiConfig.baseUrl}/dashboard/farm-houses/$farmId/blocked-dates");
//       log("blocked dates provider ${response.statusCode}");
//       log("blocked dates provider ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           await Future.microtask(() {
//             _blockedDates = (data['data'] as List)
//                 .map((json) => BlockedDate.fromJson(json))
//                 .toList();
//
//             final checkIn = data['checkInTime'];
//             final checkOut = data['checkOutTime'];
//
//             _checkInTime = checkIn != null && checkIn.contains(':')
//                 ? TimeOfDay(
//               hour: int.parse(checkIn.split(':')[0]),
//               minute: int.parse((checkIn.split(':')[1]).split(' ')[0]),
//             )
//                 : null;
//
//             _checkOutTime = checkOut != null && checkOut.contains(':')
//                 ? TimeOfDay(
//               hour: int.parse(checkOut.split(':')[0]),
//               minute: int.parse((checkOut.split(':')[1]).split(' ')[0]),
//             )
//                 : null;
//
//             _isLoading = false;
//             _error = null;
//             notifyListeners();
//           });
//         } else {
//           throw Exception('Invalid response format');
//         }
//       } else {
//         throw Exception(
//             'Failed to fetch blocked dates: ${response.statusCode}');
//       }
//     } catch (e) {
//       await Future.microtask(() {
//         _error = 'Error fetching blocked dates: $e';
//         _isLoading = false;
//         notifyListeners();
//       });
//     }
//   }
//
//   Future<bool> blockDates(String farmId, List<String> dates, String reason) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final token = await getToken();
//       final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/farm-houses/$farmId/blocked-dates');
//
//       final response = await http.post(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({
//           'farmId': farmId,
//           'dates': dates,
//           'reason': reason,
//         }),
//       );
//
//       final data = json.decode(response.body);
//
//       if ((response.statusCode == 200 || response.statusCode == 201) ) {
//         _isLoading = false;
//         _selectedDates = [];
//         _selectedReason = null;
//
//         notifyListeners();
//         return true; // success
//       } else {
//         _error = data['message'] ?? 'Invalid response format';
//         _isLoading = false;
//         notifyListeners();
//         return false; // failure
//       }
//     } catch (e) {
//       _error = 'Error blocking dates: ${e.toString()}';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
//
//
//   void setSelectedReason(String? reason) {
//     _selectedReason = reason;
//     notifyListeners();
//   }
//
//   void addSelectedDate(String date) {
//     if (!_selectedDates.contains(date)) {
//       _selectedDates.add(date);
//       notifyListeners();
//     }
//   }
//
//   void removeSelectedDate(String date) {
//     _selectedDates.remove(date);
//     notifyListeners();
//   }
//
//
//   void clearSelection() {
//     _selectedDates = [];
//     _selectedReason = null;
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:book_my_farm_owner/core/models/farm_house.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/locale_keys.g.dart';
import '../../main.dart';
import '../config/api_config.dart';
import '../models/block_all_dates.dart';
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchBlockedDates(
      String farmhouseid, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await getToken();

      final queryParams = {
        if (startDate != null)
          'startDate': startDate.toIso8601String().split('T')[0],
        if (endDate != null)
          'endDate': endDate.toIso8601String().split('T')[0],
      };

      final uri = Uri.parse(
        '$baseUrlGlobal/dashboard/farm-houses/682343f204e68a34c123d638/blocked-dates',
      ).replace(queryParameters: queryParams);

      // log the final link
      log("🔗 Blocked Dates URL: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      List<String> _getDatesBetween(DateTime start, DateTime end) {
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
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> dataList = data['data'];

          _blockedDates = dataList.map((item) {

            final List<DateTime>  parsedDate  =  (item["dates"] as List<dynamic>).map((e)=>DateTime.parse(e)).toList();
final dates  =  _getDatesBetween(parsedDate.first, parsedDate.last);


            return BlockedDate(
              id: item['_id'] ?? '',
              farmId: item['farmId'] ?? '',
              farmName: item['farmName'] ?? '',
              dates:dates,
              reason: item['reason'] ?? '',
              createdBy: item['createdBy'] ?? '',
              createdAt: DateTime.parse(item['createdAt']),
              updatedAt: DateTime.parse(item['updatedAt']),
            );
          }).toList();

          // Commented old code when using BlockAllDates model
          /*
        final blockAllDates = BlockAllDates.fromJson(data['data']);
        _blockedDates = blockAllDates.bookedDates.map((booked) {
          return BlockedDate(
            id: '',
            farmId: blockAllDates.farmId,
            farmName: blockAllDates.farmName,
            dates: _getDatesBetween(booked.checkIn.date, booked.checkOut.date),
            reason: booked.reason ?? '',
            createdBy: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();

        final checkIn = data['checkInTime'];
        final checkOut = data['checkOutTime'];

        _checkInTime = checkIn != null && checkIn.contains(':')
            ? TimeOfDay(
                hour: int.parse(checkIn.split(':')[0]),
                minute: int.parse((checkIn.split(':')[1]).split(' ')[0]),
              )
            : null;

        _checkOutTime = checkOut != null && checkOut.contains(':')
            ? TimeOfDay(
                hour: int.parse(checkOut.split(':')[0]),
                minute: int.parse((checkOut.split(':')[1]).split(' ')[0]),
              )
            : null;
        */

          _isLoading = false;
          _error = null;
          notifyListeners();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('❌ Failed to fetch blocked dates: ${response.statusCode}');
      }
    } catch (e) {
      _error = '❗ Error fetching blocked dates: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> blockDates(
      String farmhouseid, List<String> dates, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await getToken();
      final uri = Uri.parse(
          '$baseUrlGlobal/dashboard/farm-houses/682343f204e68a34c123d638/blocked-dates');
      print(
          "id is $farmhouseid dates is $dates and reason is $reason and token is $token");
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'farmId': "682343f204e68a34c123d638",
          'dates': dates,
          'reason': reason,
        }),
      );

      final data = json.decode(response.body);
      print("data post $data and ${response.statusCode} and body is ${response.body} ");
      if (response.statusCode == 200 || response.statusCode == 201) {
        _blockedDates.add(BlockedDate(
          id: data['_id'] ?? '',
          farmId: farmhouseid,
          farmName: data['farmName'] ?? '',
          // Use the farm name from the response if available
          dates: dates,
          reason: reason,
          createdBy: data['createdBy'] ?? '',
          // Use the createdBy field from the response if available
          createdAt: DateTime.parse(
              data['createdAt'] ?? DateTime.now().toIso8601String()),
          // Parse createdAt from the response
          updatedAt: DateTime.parse(data['updatedAt'] ??
              DateTime.now()
                  .toIso8601String()), // Parse updatedAt from the response
        ));

        _isLoading = false;
        _selectedDates = [];
        _selectedReason = null;

        notifyListeners();
        return true; // success
      } else {
        print("error is ${data["message"]} and sucess is ${data["success"]}");
        _error = data['message'] ?? 'Invalid response format';
        print("error is $_error");
        _isLoading = false;
        notifyListeners();
        return false; // failure
      }
    } catch (e) {
      _error = 'Error blocking dates: ${e.toString()}';
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

  void removeSelectedDate(String date) {
    _selectedDates.remove(date);
    notifyListeners();
  }

  void clearSelection() {
    _selectedDates = [];
    _selectedReason = null;
    notifyListeners();
  }
}
