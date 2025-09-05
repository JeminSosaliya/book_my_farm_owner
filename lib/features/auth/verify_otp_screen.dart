import 'dart:async';

import 'package:book_my_farm_owner/core/notification/notification.dart';
import 'package:book_my_farm_owner/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String mobileNumber;

  const VerifyOtpScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  late final TextEditingController _otpController;
  int _timer = 30;
  bool _canResend = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _countdownTimer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose(); // Proper disposal of controller
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _countdownTimer?.cancel(); // stop the timer
      }
    });
  }

  Future<void> _verifyOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = prefs.getString(NotificationUtils.fcmTokenKey);
    if (_otpController.text.length == 6) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.verifyOtp(
        widget.mobileNumber,
        _otpController.text,
        fcmToken ?? "",
      );
      print("FCM Token: $fcmToken");

      if (mounted) {
        if (success) {
          _otpController.clear();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  authProvider.error ?? LocaleKeys.failed_to_verify_otp.tr()),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_canResend) {
      setState(() {
        _canResend = false;
        _timer = 30;
      });
      _startTimer();

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendOtp(widget.mobileNumber);

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                authProvider.error ?? LocaleKeys.failed_to_resend_otp.tr()),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocaleKeys.verify_otp.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    LocaleKeys.enter_the_6_digit_code_sent_to
                        .tr(args: [(widget.mobileNumber)]),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),
                  Container(
                    color: Colors.transparent,
                    // Ensures background is transparent
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      onChanged: (value) {},
                      onCompleted: (value) {
                        if (mounted) {
                          _verifyOtp();
                        }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50.h,
                        fieldWidth: 45.w,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.white.withOpacity(0.9),
                        selectedFillColor: Colors.white,
                        activeColor: AppColors.primaryColor,
                        inactiveColor: AppColors.greyColor,
                        selectedColor: AppColors.primaryColor,
                      ),
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      enableActiveFill: true,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _verifyOtp,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(LocaleKeys.verify_otp.tr()),
                  ),
                  SizedBox(height: 10.h),
                  TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? LocaleKeys.resend_otp.tr()
                          : LocaleKeys.resend_otp_in_timer_seconds
                              .tr(args: ["$_timer"]),
                      style: TextStyle(
                        color: _canResend
                            ? AppColors.primaryColor
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
