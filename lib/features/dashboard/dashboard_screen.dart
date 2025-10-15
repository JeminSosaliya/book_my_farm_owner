import 'package:book_my_farm_owner/core/models/booking_analytics.dart';
import 'package:book_my_farm_owner/core/models/farm_house.dart';
import 'package:book_my_farm_owner/core/providers/auth_provider.dart';
import 'package:book_my_farm_owner/core/providers/farm_provider.dart';
import 'package:book_my_farm_owner/core/providers/profile_provider.dart';
import 'package:book_my_farm_owner/core/theme/app_colors.dart';
import 'package:book_my_farm_owner/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadFarmsAndAnalytics();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    final profileProvider = context.read<ProfileProvider>();
    if (!profileProvider.hasProfile && !profileProvider.isLoading) {
      await profileProvider.loadProfile();
    }
  }

  Future<void> _loadFarmsAndAnalytics() async {
    if (!mounted) return;

    await Future.microtask(() async {
      final farmProvider = context.read<FarmProvider>();
      await Future.wait([
        farmProvider.fetchFarms(),
        farmProvider.fetchAnalytics(),
      ]);
    });
  }

  Widget _buildAnalyticsCard(BookingAnalytics? analytics) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.analytics_overview.tr(),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 16.h),

          // First Row (Total Bookings & Total Revenue)
          Row(
            children: [
              _buildAnalyticsTile(
                title: LocaleKeys.total_bookings.tr(),
                value: "${analytics?.totalBookings ?? 0}",
                icon: Icons.calendar_today,
                startColor: const Color(0xFF130391),
                endColor: const Color(0xFF8981F3),
              ),
              SizedBox(width: 16.w),
              _buildAnalyticsTile(
                title: LocaleKeys.total_revenue.tr(),
                value:
                    '${LocaleKeys.currency_symbol.tr()}${(analytics?.totalRevenue ?? 0.0).toStringAsFixed(2)}',
                icon: Icons.attach_money,
                startColor: const Color(0xFFA00239),
                endColor: const Color(0xFFF37C9E),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Second Row (Confirmed, Completed, Cancelled)
          Row(
            children: [
              _buildAnalyticsTile(
                title: LocaleKeys.confirmed.tr(),
                value: "${analytics?.statusBreakdown.confirmed ?? 0}",
                icon: Icons.check_circle,
                startColor: const Color(0xFF795D01),
                endColor: const Color(0xFF86734E),
              ),
              SizedBox(width: 16.w),
              _buildAnalyticsTile(
                title: LocaleKeys.completed.tr(),
                value: "${analytics?.statusBreakdown.completed ?? 0}",
                icon: Icons.done_all,
                startColor: const Color(0xFF056D6D),
                endColor: const Color(0xFF338876),
              ),
              SizedBox(width: 16.w),
              _buildAnalyticsTile(
                title: LocaleKeys.cancelled.tr(),
                value: "${analytics?.statusBreakdown.cancelled ?? 0}",
                icon: Icons.cancel,
                startColor: const Color(0xFF7A0C04),
                endColor: Colors.redAccent.withOpacity(0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTile({
    required String title,
    required String value,
    required IconData icon,
    required Color startColor,
    required Color endColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: Icon(icon, color: Colors.white, size: 28.r),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAnalyticsCard(BookingAnalytics? analytics) {
  //   return Padding(
  //     padding: EdgeInsets.only(left: 16.r, right: 16.r, top: 16.r),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           LocaleKeys.analytics_overview.tr(),
  //           style: TextStyle(
  //             fontSize: 20.sp,
  //             fontWeight: FontWeight.bold,
  //             color: AppColors.textColor,
  //           ),
  //         ),
  //         SizedBox(height: 16.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: LocaleKeys.total_bookings.tr(),
  //                 value: "${analytics?.totalBookings ?? 0}".toString(),
  //                 icon: Icons.calendar_today,
  //                 startColor: const Color.fromARGB(255, 19, 3, 145),
  //                 endColor: const Color.fromARGB(255, 137, 129, 243),
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: LocaleKeys.total_revenue.tr(),
  //                 value:
  //                     '${LocaleKeys.currency_symbol.tr()}${(analytics?.totalRevenue ?? 0.0).toStringAsFixed(2)}',
  //                 icon: Icons.attach_money,
  //                 startColor: const Color.fromARGB(255, 160, 2, 57),
  //                 endColor: const Color.fromARGB(255, 243, 124, 158),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 16.h),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: LocaleKeys.confirmed.tr(),
  //                 value: (analytics?.statusBreakdown.confirmed ?? 0).toString(),
  //                 icon: Icons.check_circle,
  //                 startColor: const Color.fromARGB(255, 121, 93, 1),
  //                 endColor:
  //                     const Color.fromARGB(255, 134, 115, 78).withOpacity(0.5),
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: LocaleKeys.completed.tr(),
  //                 value: (analytics?.statusBreakdown.completed ?? 0).toString(),
  //                 icon: Icons.done_all,
  //                 startColor: const Color.fromARGB(255, 5, 109, 109),
  //                 endColor:
  //                     const Color.fromARGB(255, 51, 136, 118).withOpacity(0.5),
  //               ),
  //             ),
  //             SizedBox(width: 16.w),
  //             Expanded(
  //               child: _buildStatCard(
  //                 title: LocaleKeys.cancelled.tr(),
  //                 value: (analytics?.statusBreakdown.cancelled ?? 0).toString(),
  //                 icon: Icons.cancel,
  //                 startColor: const Color.fromARGB(255, 122, 12, 4),
  //                 endColor: Colors.red.withOpacity(0.5),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatCard({
  //   required String title,
  //   required String value,
  //   required IconData icon,
  //   required Color startColor,
  //   required Color endColor,
  // }) {
  //   return Container(
  //     height: 150.h,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16.r),
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [startColor, endColor],
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: startColor.withOpacity(0.3),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(16.r),
  //         onTap: () {},
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 10.r),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Container(
  //                         padding: EdgeInsets.all(8.r),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white.withOpacity(0.2),
  //                           borderRadius: BorderRadius.circular(12.r),
  //                         ),
  //                         child: Icon(
  //                           icon,
  //                           color: Colors.white,
  //                           size: 24.r,
  //                         ),
  //                       ),
  //                       SizedBox(height: 12.h),
  //                       Container(
  //                         padding: EdgeInsets.symmetric(
  //                           horizontal: 8.r,
  //                           vertical: 6.r,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white.withOpacity(0.2),
  //                           borderRadius: BorderRadius.circular(20.r),
  //                         ),
  //                         child: Text(
  //                           title,
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 12.sp,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 12.h),
  //               Padding(
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: 5.r,
  //                 ),
  //                 child: Text(
  //                   value,
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 24.sp,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //               // SizedBox(height: 4.h),
  //               // Container(
  //               //   height: 4.h,
  //               //   width: 40.w,
  //               //   decoration: BoxDecoration(
  //               //     color: Colors.white.withOpacity(0.5),
  //               //     borderRadius: BorderRadius.circular(2.r),
  //               //   ),
  //               // ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFarmCard(FarmHouse farm) {
    String getImageUrl(String driveUrl) {
      final fileId = driveUrl.split('/d/')[1].split('/')[0];
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 15,
      shadowColor: Colors.black.withOpacity(0.2),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: farm.media.images.isNotEmpty
                      ? Image.network(
                          getImageUrl(farm.media.images.first),
                          height: 200.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;

                            return Center(
                              child: SizedBox(
                                height: 200.h,
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Image itself
                                    Image.network(
                                      getImageUrl(farm.media.images.first),
                                      height: 200.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child; // Image loaded
                                        return SizedBox
                                            .shrink(); // Hide Image while loading
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image,
                                            size: 40.sp, color: Colors.grey),
                                      ),
                                    ),

                                    // Loader overlay
                                    Positioned.fill(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          height: 200.h,
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 40.sp, color: Colors.grey),
                        ),
                ),
                // Stylish badge
                Positioned(
                  top: 12.r,
                  right: 12.r,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                    decoration: BoxDecoration(
                      color: farm.status == 'active'
                          ? Colors.green
                          : AppColors.errorColor,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      farm.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          farm.basicInfo.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${LocaleKeys.currency_symbol.tr()}${farm.pricing.normal.discountedPrice}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          '${farm.location.coordinates.latitude}, ${farm.location.coordinates.longitude}',
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      _buildInfoChip(
                        icon: Icons.people,
                        text: LocaleKeys.number_guests
                            .tr(args: ["${farm.basicInfo.capacity}"]),
                      ),
                      _buildInfoChip(
                        icon: Icons.bed,
                        text: LocaleKeys.value_bedrooms.tr(args: [
                          "${farm.basicInfo.bedrooms + farm.basicInfo.acBedroom}"
                        ]),
                      ),
                      _buildInfoChip(
                        icon: Icons.area_chart,
                        text: LocaleKeys.value_sq_ft
                            .tr(args: ["${farm.basicInfo.area}"]),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.access_alarm,
                          label: LocaleKeys.bookings.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/bookings',
                            arguments: {
                              "farmhouseid": farm.farmhouseId,
                              "checkIn": farm.timings.checkIn,
                              "checkOut": farm.timings.checkOut,
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.calendar_today,
                          label: LocaleKeys.block_dates.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/block-dates',
                            arguments: {
                              "farmhouseid": farm.id,
                              "farmName": farm.basicInfo.name,
                              "timings": farm.timings.toJson(),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.9),
              AppColors.primaryColor
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          height: 42.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: Colors.white,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.select_language.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              selected: context.locale.languageCode == 'en',
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇮🇳'),
              title: const Text('हिंदी'),
              selected: context.locale.languageCode == 'hi',
              onTap: () {
                context.setLocale(const Locale('hi'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇮🇳'),
              title: const Text('ગુજરાતી'),
              selected: context.locale.languageCode == 'gu',
              onTap: () {
                context.setLocale(const Locale('gu'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final farmProvider = context.watch<FarmProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.dashboard.tr()),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        width: 250.w,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (profileProvider.isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Text(
                      profileProvider.profile?.name ?? LocaleKeys.no_name.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    profileProvider.profile?.mobileNumber ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            // ListTile(
            //   leading: const Icon(Icons.person),
            //   title: Text(LocaleKeys.profile.tr()),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(LocaleKeys.language.tr()),
              onTap: () async {
                Navigator.pop(context);
                _showLanguageDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(LocaleKeys.logout.tr()),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: farmProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          // : farmProvider.error != null
          //     ? Center(
          //         child: Text(
          //           farmProvider.error!,
          //           style: TextStyle(
          //             color: AppColors.errorColor,
          //             fontSize: 16.sp,
          //           ),
          //         ),
          //       )
          : RefreshIndicator(
              onRefresh: _loadFarmsAndAnalytics,
              child: ListView(
                children: [
                  // if (farmProvider.analytics != null)
                  _buildAnalyticsCard(farmProvider.analytics),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.r,
                      right: 16.r,
                    ),
                    child: Text(
                      LocaleKeys.my_farms.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  ...farmProvider.farms.map((farm) => _buildFarmCard(farm)),
                ],
              ),
            ),
    );
  }
}
