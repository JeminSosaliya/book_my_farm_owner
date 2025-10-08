import 'dart:developer';
import 'package:book_my_farm_owner/features/bookings/bookings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'config_service.dart';
import 'core/models/farm_house.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/farm_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/blocked_dates_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/verify_otp_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/bookings/booking_details_screen.dart';
import 'features/block_dates/block_dates_screen.dart';
import 'firebase.dart';

String baseUrlGlobal = "";

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    log('Handling a background message: ${message.notification!.title} - ${message.notification!.body}');
    await Firebase.initializeApp();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigService.getBaseUrl().then((url) {
    if (url != null && url.isNotEmpty) {
      baseUrlGlobal = url;
      log('Base URL from Firestore: $baseUrlGlobal');
    } else {
      baseUrlGlobal = 'https://farmhouseapi-2ktx.onrender.com';
      log('Using default Base URL: $baseUrlGlobal');
    }
  }).catchError((error) {
    baseUrlGlobal = 'https://farmhouseapi-2ktx.onrender.com';
    log('Error fetching Base URL, using default: $baseUrlGlobal. Error: $error');
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('gu'),
        Locale('hi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log('MyHomePage Init State');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext _) => AuthProvider()),
        ChangeNotifierProvider(create: (BuildContext _) => ProfileProvider()),
        ChangeNotifierProvider(create: (BuildContext _) => FarmProvider()),
        ChangeNotifierProvider(create: (BuildContext _) => BookingProvider()),
        ChangeNotifierProvider(
            create: (BuildContext _) => BlockedDatesProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'Farm House Owner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (BuildContext _) => const SplashScreen(),
                  );
                case '/login':
                  return MaterialPageRoute(
                    builder: (BuildContext _) => const LoginScreen(),
                  );
                case '/verify-otp':
                  final String mobileNumber = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (BuildContext _) => VerifyOtpScreen(
                      mobileNumber: mobileNumber,
                    ),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (BuildContext _) => const DashboardScreen(),
                  );
                case '/bookings':
                  return MaterialPageRoute(
                    builder: (BuildContext _) => const BookingsScreen(),
                  );
                case '/block-dates':
                  Map? args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (BuildContext _) => BlockDatesScreen(
                      farmHouseId: args?['farmhouseid'] ?? "",
                      farmName: args?['name'] ?? "",
                      timings: Timings.fromJson(args?['timings'] ?? {}),
                    ),
                  );
                case '/booking-details':
                  final String bookingId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (BuildContext _) =>
                        BookingDetailsScreen(bookingId: bookingId),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (BuildContext _) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
