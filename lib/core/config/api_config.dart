class ApiConfig {
  static const String baseUrl = 'https://farmhouseapi.onrender.com/farm-owner';
  static String? _token;

  static String get token => _token ?? '';

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }
} 