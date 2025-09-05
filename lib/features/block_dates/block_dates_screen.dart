import 'package:book_my_farm_owner/core/models/farm_house.dart';
import 'package:book_my_farm_owner/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/providers/blocked_dates_provider.dart';
import '../../core/theme/app_colors.dart';

class BlockDatesScreen extends StatefulWidget {
  final String farmhouseid;
  final String farmName;
  final Timings timings;


  const BlockDatesScreen({
    super.key,
    required this.farmhouseid,
    required this.farmName,
    required this.timings,
  });

  @override
  State<BlockDatesScreen> createState() => _BlockDatesScreenState();
}

class _BlockDatesScreenState extends State<BlockDatesScreen> {

  DateTime? _selectedCheckIn;
  DateTime? _selectedCheckOut;



  // Fixed check-in and check-out times
  // final TimeOfDay fixedCheckInTime = const TimeOfDay(hour: 20, minute: 0);
  // final TimeOfDay fixedCheckOutTime = const TimeOfDay(hour: 7, minute: 30);




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBlockedDates();  // call your provider method here
    });  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _loadBlockedDates() async {
    if (!mounted) return;
    final provider = context.read<BlockedDatesProvider>();
    await provider.fetchBlockedDates(
      widget.farmhouseid,
      startDate: DateTime(2024),
      endDate: DateTime(2026),
    );
  }


  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.trim().split(RegExp(r'[:\s]'));
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = parts[2].toLowerCase();

      int hour24 = hour;
      if (period == 'pm' && hour != 12) {
        hour24 += 12;
      } else if (period == 'am' && hour == 12) {
        hour24 = 0;
      }

      return TimeOfDay(hour: hour24, minute: minute);
    } catch (e) {
      debugPrint("Failed to parse time: $timeString. Error: $e");
      return const TimeOfDay(hour: 0, minute: 0); // fallback
    }
  }

  Widget _buildSelectedDatesSection() {
    final provider = context.watch<BlockedDatesProvider>();

    if (provider.selectedDates.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedDates = provider.selectedDates
        .map((date) => DateTime.parse(date))
        .toList()
      ..sort();

    final startDate = sortedDates.first;
    final endDate = sortedDates.last;

    // Format check-in and check-out times
    final checkInTime = widget.timings.checkIn.isNotEmpty
        ? _formatTime(_parseTime(widget.timings.checkIn))
        : 'N/A';

    final checkOutTime = widget.timings.checkOut.isNotEmpty
        ? _formatTime(_parseTime(widget.timings.checkOut))
        : 'N/A';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.select_dates.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  _selectDateRange(context); // Ensure this method is correctly linked
                },
              ),
            ],
          ),
          Text(
            '${DateFormat('MMM dd, yyyy').format(startDate)} ($checkInTime) to ${DateFormat('MMM dd, yyyy').format(endDate)} ($checkOutTime)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final provider = context.read<BlockedDatesProvider>();

    // Fetch blocked dates from provider
    final blockedDates = provider.blockedDates
        .expand((blocked) => blocked.dates.map((date) => DateTime.parse(date)))
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();



    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: null,
      selectableDayPredicate: (DateTime date, DateTime? start, DateTime? end) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final today = DateTime.now();
        final todayNormalized = DateTime(today.year, today.month, today.day);

        // Disable past dates
        if (normalizedDate.isBefore(todayNormalized)) {
          return false;
        }

        // Check for selected range
        if (_selectedCheckIn != null) {
          final rangeStart = DateTime(_selectedCheckIn!.year, _selectedCheckIn!.month, _selectedCheckIn!.day);

          // Allow the `rangeEnd` (last date) but disable intermediate dates
          if (normalizedDate.isAfter(rangeStart) && normalizedDate != _selectedCheckOut) {
            return false;
          }
        }

        // Block dates that are already in the blocked list
        if (blockedDates.contains(normalizedDate)) {
          return false;
        }

        // Allow all other dates
        return true;
      },
    );

    if (picked != null) {
      final startDate = picked.start;
      final endDate = picked.end;

      setState(() {
        _selectedCheckIn = startDate;
        _selectedCheckOut = endDate;
      });

      provider.clearSelection();

      // Include the end date in the range
      final nights = endDate.difference(startDate).inDays + 1;

      for (var i = 0; i < nights; i++) {
        final date = startDate.add(Duration(days: i));
        provider.addSelectedDate(DateFormat('yyyy-MM-dd').format(date));
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LocaleKeys.blocked_date_range.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(LocaleKeys.you_have_blocked_the_following_date_and_time_range_com.tr()),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(startDate)} (${_formatTime(_parseTime(widget.timings.checkIn))}) to ${DateFormat('MMM dd, yyyy').format(endDate)} (${_formatTime(_parseTime(widget.timings.checkOut))})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.ok.tr()),
              ),
            ],
          );
        },
      );
    }
  }
  Future<void> _selectReason(BuildContext context) async {
    final provider = context.read<BlockedDatesProvider>();

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.select_reason.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            ...provider.reasons.map((reason) => ListTile(
              title: Text(
                reason,
                style: TextStyle(
                  color: provider.selectedReason == reason
                      ? AppColors.primaryColor
                      : AppColors.textColor,
                  fontSize: 16.sp,
                ),
              ),
              onTap: () {
                provider.setSelectedReason(reason);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  Widget _buildBlockedDatesList() {
    final provider = context.watch<BlockedDatesProvider>();

    if (provider.blockedDates.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.no_blocked_dates.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.blockedDates.length,
      itemBuilder: (context, index) {
        final blockedDate = provider.blockedDates[index];

        // Blocked date range and reason
        final dateRange = _formatDateRange(blockedDate.dates);
        final reason = blockedDate.reason;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block,
                    color: Colors.redAccent,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 12.w),

                // Date Range and Reason
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blocked Date Range
                      Text(
                        dateRange,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Reason for Block
                      Text(
                        reason,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateRange(List<String> dates) {
    if (dates.isEmpty) return '';
    final sortedDates = dates.map(DateTime.parse).toList()..sort();
    final start = DateFormat('MMM dd, yyyy').format(sortedDates.first);
    final end = DateFormat('MMM dd, yyyy').format(sortedDates.last);
    return start == end ? start : '$start to $end';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlockedDatesProvider>();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final timingsMap = args?['timings'] as Map<String, dynamic>?;

    final timings = timingsMap != null ? Timings.fromJson(timingsMap) : Timings(checkIn: '', checkOut: '');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.block_dates_screen_title.tr(args: [widget.farmName]),
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
        child: Text(
          provider.error!,
          style: TextStyle(
            color: AppColors.errorColor,
            fontSize: 16.sp,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Dates Block
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.select_dates.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(LocaleKeys.select_date_range.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Select Reason Block
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.select_reason.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _selectReason(context),
                    icon: const Icon(Icons.info_outline),
                    label: Text(
                      provider.selectedReason ??
                          LocaleKeys.select_reason_prompt.tr(),
                      style: TextStyle(
                        color: provider.selectedReason != null
                            ? AppColors.primaryColor
                            : Colors.grey,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),


            // Display selected dates
            _buildSelectedDatesSection(),
            SizedBox(height: 20.h),

            // Block Dates Button
            ElevatedButton(
              onPressed: provider.selectedDates.isNotEmpty &&
                  provider.selectedReason != null
                  ? () async {
                final success = await provider.blockDates(
                  widget.farmhouseid,
                  provider.selectedDates,
                  provider.selectedReason!,
                );

                if (success) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primaryColor,
                        content: Text(LocaleKeys.dates_blocked_successfully_dot.tr()),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        content: Text(LocaleKeys.something_went_wrong_dot.tr()),
                      ),
                    );
                  }
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: Text(LocaleKeys.block_selected_dates.tr()),
            ),
            SizedBox(height: 20.h),
            _buildBlockedDatesList(),
          ],
        ),
      ),
    );
  }
}
