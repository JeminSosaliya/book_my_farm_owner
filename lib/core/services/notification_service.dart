// import 'dart:developer';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class NotificationService {
//    Future<void> updateFcmToken(String fcmToken) async {
//     String? token = "";/// todo: get token from storage
//     log("token >>>> $token");
//     final response = await http.post(
//       Uri.parse(''),/// todo: add api url
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'fcm_token': fcmToken,
//       }),
//     );
//     debugPrint('Update FCM Token StatusCode: ${response.statusCode}');
//     debugPrint('Update FCM Token Response: ${response.body}');
//
//     if (response.statusCode == 200) {
//       debugPrint('FCM token updated successfully');
//     } else {
//       throw Exception('Failed to update FCM token');
//     }
//   }
//
// }
//
//
