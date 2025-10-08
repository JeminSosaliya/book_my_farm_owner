import 'package:flutter/material.dart';
import '../models/farm_owner_profile.dart';
import '../services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  FarmOwnerProfile? _profile;
  bool _isLoading = false;
  String? _error;
  FarmOwnerProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;
  String? get error => _error;

  Future<void> loadProfile() async {
    if (_isLoading) return;
    await Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });
    try {
      final Map<String, dynamic> response = await _authService.getProfile();
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['farmOwner'] != null) {
        final dynamic farmOwnerData = response['data']['farmOwner'];
        await Future.microtask(() {
          _profile = FarmOwnerProfile.fromJson(farmOwnerData);
          _isLoading = false;
          _error = null;
          notifyListeners();
        });
      } else {
        throw Exception('Invalid profile data');
      }
    } catch (e) {
      await Future.microtask(() {
        _isLoading = false;
        _error = 'Failed to load profile: $e';
        print("profile error: $e");
        notifyListeners();
      });
    }
  }
}
