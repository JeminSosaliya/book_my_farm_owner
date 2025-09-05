import 'package:book_my_farm_owner/core/notification/notification.dart';
import 'package:book_my_farm_owner/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mobileController;
  late final TextEditingController _countryCodeController;
  String _selectedCountryCode = '+91';
  String _selectedCountryFlag = '🇮🇳';

  @override
  void initState() {
    NotificationUtils().init();
    super.initState();
    _mobileController = TextEditingController();
    _countryCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountryCode = '+${country.phoneCode}';
          _selectedCountryFlag = country.flagEmoji;
        });
      },
      searchAutofocus: true,
      showWorldWide: false,
      showSearch: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16),
        borderRadius: BorderRadius.circular(12.r),
        inputDecoration: InputDecoration(
          labelText: LocaleKeys.search.tr(),
          // Using localized key
          hintText: LocaleKeys.start_typing_to_search.tr(),
          // Using localized key
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      final fullMobileNumber = _mobileController.text;
      final success = await authProvider.sendOtp(fullMobileNumber);

      if (mounted) {
        if (success) {
          Navigator.pushNamed(context, '/verify-otp',
              arguments: fullMobileNumber);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  authProvider.error ?? LocaleKeys.failed_to_send_otp.tr()),
              // Using localized key
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      LocaleKeys.welcome_back.tr(), // Using localized key
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.enter_your_mobile_number_to_continue.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(
                            0.9), // Changed from greyColor to white
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 10.w),
                                  Text(
                                    _selectedCountryFlag,
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _selectedCountryCode,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.greyColor,
                                    size: 20.sp,
                                  ),
                                ],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.mobileNumber.tr(),
                              // Using localized key
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.error_empty_mobile
                                    .tr(); // Using localized key
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return LocaleKeys.error_invalid_mobile
                                    .tr(); // Using localized key
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _sendOtp,
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
                          : Text(
                              LocaleKeys.sendOtp.tr()), // Using localized key
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
