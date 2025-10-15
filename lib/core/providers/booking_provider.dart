import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import '../../main.dart';
import '../models/booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _statusFilter;

  List<Booking> get bookings => _bookings;

  Booking? get selectedBooking => _selectedBooking;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  bool get hasNextPage => _hasNextPage;

  bool get hasPrevPage => _hasPrevPage;

  DateTime? get startDate => _startDate;

  DateTime? get endDate => _endDate;

  String? get statusFilter => _statusFilter;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchBookings({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int page = 1,
    required String farmId,
  }) async {
    await Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      final String? token = await getToken();
      final queryParams = {
        'page': page.toString(),
        'limit': '10',
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
        _startDate = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
        _endDate = endDate;
      }
      if (status != null) {
        queryParams['status'] = status;
        _statusFilter = status;
      }

      String url = '$baseUrlGlobal/dashboard/farm-houses/$farmId/bookings';
      final Uri uri = Uri.parse(url)
          .replace(queryParameters: queryParams);
      final Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log("Bookings Url :- $url");
      log("Bookings Query Params :- $queryParams");
      log("booking provider ${response.statusCode}");
      log("booking provider ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          await Future.microtask(() {
            _bookings = (data['data']['bookings'] as List)
                .map((dynamic json) => Booking.fromJson(json))
                .toList();
            _currentPage = data['data']['pagination']['page'];
            _totalPages = data['data']['pagination']['pages'];
            _hasNextPage = data['data']['pagination']['hasNextPage'];
            _hasPrevPage = data['data']['pagination']['hasPrevPage'];
            _isLoading = false;
            _error = null;
            notifyListeners();
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch bookings: ${response.statusCode}');
      }
    } catch (e) {
      await Future.microtask(() {
        _error = 'Error fetching bookings: $e';
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<void> nextPage({required String farmId}) async {
    if (_hasNextPage) {
      await fetchBookings(
        startDate: _startDate,
        endDate: _endDate,
        status: _statusFilter,
        page: _currentPage + 1,
        farmId: farmId,
      );
    }
  }

  Future<void> previousPage({required String farmId}) async {
    if (_hasPrevPage) {
      await fetchBookings(
        startDate: _startDate,
        endDate: _endDate,
        status: _statusFilter,
        page: _currentPage - 1,
        farmId: farmId,
      );
    }
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _statusFilter = null;
    notifyListeners();
  }

  Future<void> fetchBookingDetails(String bookingId) async {
    await Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      final String? token = await getToken();
      final Uri uri = Uri.parse('$baseUrlGlobal/dashboard/bookings/$bookingId');

      final Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log("Single Booking Details Url :- $baseUrlGlobal/dashboard/bookings/$bookingId");
      log("Booking Provider Details ${response.statusCode}");
      log("Booking Provider Details ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          await Future.microtask(() {
            _selectedBooking = Booking.fromJson(data['data']);
            _isLoading = false;
            _error = null;
            notifyListeners();
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'Failed to fetch booking details: ${response.statusCode}');
      }
    } catch (e) {
      await Future.microtask(() {
        _error = 'Error fetching booking details: $e';
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }
}
