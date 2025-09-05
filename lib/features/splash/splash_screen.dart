import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    if (!mounted) return;
    final prefs = await _prefs;
    String token = prefs.getString("auth_token") ?? "";
    if (token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../core/providers/auth_provider.dart';
// import '../../core/theme/app_colors.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }
//
//   Future<SharedPreferences> get _prefs async =>
//       await SharedPreferences.getInstance();
//
//   Future<void> _initializeApp() async {
//     await Future.delayed(const Duration(seconds: 1));
//
//     // Step 1: Check if location services are ON
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showLocationServiceDialog(); // Show dialog to prompt user
//       return;
//     }
//
//     // Step 2: Check and request permission
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     if (permission == LocationPermission.deniedForever ||
//         permission == LocationPermission.denied) {
//       _showPermissionDeniedDialog();
//       return;
//     }
//
//     // Step 3: If permission granted, proceed
//     final authProvider = context.read<AuthProvider>();
//     await authProvider.initialize();
//
//     final prefs = await _prefs;
//     String token = prefs.getString("auth_token") ?? "";
//
//     if (!mounted) return;
//     if (token.isNotEmpty) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }
//
//   void _showLocationServiceDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Location Services Disabled"),
//         content: const Text("Please enable location services to continue."),
//         actions: [
//           TextButton(
//             child: const Text("Allow"),
//             onPressed: () {
//               Geolocator.openLocationSettings(); // open device location settings
//               Navigator.pop(context);
//             },
//           ),
//           TextButton(
//             child: const Text("Retry"),
//             onPressed: () {
//               Navigator.pop(context);
//               _initializeApp();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Permission Denied"),
//         content: const Text("Location permission is required to proceed."),
//         actions: [
//           TextButton(
//             child: const Text("Retry"),
//             onPressed: () {
//               Navigator.pop(context);
//               _initializeApp();
//             },
//           ),
//           TextButton(
//             child: const Text("Cancel"),
//             onPressed: () {
//               Navigator.pop(context);
//               // Optionally stay on splash
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.primaryColor, AppColors.secondaryColor],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(
//                   Icons.agriculture,
//                   size: 100,
//                   color: Colors.white,
//                 ),
//                 SizedBox(height: 24),
//                 CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../core/providers/auth_provider.dart';
// import '../../core/theme/app_colors.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   bool _isCheckingLocation = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }
//
//   Future<SharedPreferences> get _prefs async =>
//       await SharedPreferences.getInstance();
//
//   Future<void> _initializeApp() async {
//     // Initial delay for splash screen
//     await Future.delayed(const Duration(seconds: 3));
//
//     // Handle location permissions before proceeding
//     await _handleLocationPermission();
//
//     // Only proceed with app initialization after location is resolved
//     if (!mounted) return;
//     _continueWithAppInitialization();
//   }
//
//   Future<void> _handleLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (!serviceEnabled) {
//       setState(() => _isCheckingLocation = true);
//       await _showLocationServiceDialog();
//       return;
//     }
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() => _isCheckingLocation = true);
//         await _showLocationPermissionDialog();
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() => _isCheckingLocation = true);
//       await _showLocationPermissionDialog(openSettings: true);
//       return;
//     }
//
//     setState(() => _isCheckingLocation = false);
//   }
//
//   Future<void> _continueWithAppInitialization() async {
//     final authProvider = context.read<AuthProvider>();
//     await authProvider.initialize();
//
//     if (!mounted) return;
//     final prefs = await _prefs;
//     String token = prefs.getString("auth_token") ?? "";
//
//     if (token.isNotEmpty) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }
//
//   Future<void> _showLocationServiceDialog() async {
//     await showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Location Service Disabled'),
//           content: const Text('Please enable location services to use this app.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: const Text('Enable'),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await Geolocator.openLocationSettings();
//                 // After returning from settings, check again
//                 if (mounted) _handleLocationPermission();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _showLocationPermissionDialog({bool openSettings = false}) async {
//     await showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Location Permission Required'),
//           content: const Text('This app needs location permissions to work properly.'),
//           actions: <Widget>[
//             if (!openSettings)
//               TextButton(
//                 child: const Text('Cancel'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             TextButton(
//               child: Text(openSettings ? 'Open Settings' : 'Grant Permission'),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 if (openSettings) {
//                   await Geolocator.openAppSettings();
//                   if (mounted) _handleLocationPermission();
//                 } else {
//                   _handleLocationPermission();
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.primaryColor, AppColors.secondaryColor],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.agriculture,
//                   size: 100,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(height: 24),
//                 if (_isCheckingLocation)
//                   const Text(
//                     'Checking location...',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
