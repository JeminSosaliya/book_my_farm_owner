import 'package:book_my_farm_owner/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/app_colors.dart';
import 'booking_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    final bookingProvider = context.read<BookingProvider>();
    await bookingProvider.fetchBookings();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final bookingProvider = context.read<BookingProvider>();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
      initialDateRange:
          bookingProvider.startDate != null && bookingProvider.endDate != null
              ? DateTimeRange(
                  start: bookingProvider.startDate!,
                  end: bookingProvider.endDate!)
              : null,
    );

    if (picked != null) {
      await bookingProvider.fetchBookings(
        startDate: picked.start,
        endDate: picked.end,
        status: bookingProvider.statusFilter,
      );
    }
  }

  Future<void> _selectStatus(BuildContext context) async {
    final bookingProvider = context.read<BookingProvider>();
    final statuses = [
      LocaleKeys.pending.tr(),
      LocaleKeys.confirmed.tr(),
      LocaleKeys.completed.tr(),
      LocaleKeys.cancelled.tr(),
    ];

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.select_status.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...statuses.map((status) => ListTile(
                  title: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: bookingProvider.statusFilter == status
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await bookingProvider.fetchBookings(
                      startDate: bookingProvider.startDate,
                      endDate: bookingProvider.endDate,
                      status: status,
                    );
                  },
                )),
            ListTile(
              title: Text(LocaleKeys.clear_filter.tr()),
              textColor: AppColors.errorColor,
              onTap: () async {
                Navigator.pop(context);
                bookingProvider.clearFilters();
                await bookingProvider.fetchBookings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(booking) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.orange;
        case 'confirmed':
          return Colors.green;
        case 'completed':
          return Colors.blue;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(bookingId: booking.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.bookingId,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                    decoration: BoxDecoration(
                      color: getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: getStatusColor(booking.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        color: getStatusColor(booking.status),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    booking.user.name,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.home, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    booking.farmName,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(booking.checkIn)} - ${DateFormat('MMM dd, yyyy').format(booking.checkOut)}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${booking.payment.totalAmount}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        LocaleKeys.number_guests
                            .tr(args: ["${booking.numberOfGuests}"]),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                    decoration: BoxDecoration(
                      color: booking.payment.paymentStatus == 'completed'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: booking.payment.paymentStatus == 'completed'
                            ? Colors.green
                            : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      booking.payment.paymentStatus.toUpperCase(),
                      style: TextStyle(
                        color: booking.payment.paymentStatus == 'completed'
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.bookings.tr()),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _selectStatus(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      bookingProvider.startDate != null &&
                              bookingProvider.endDate != null
                          ? '${DateFormat('MMM dd').format(bookingProvider.startDate!)} - ${DateFormat('MMM dd').format(bookingProvider.endDate!)}'
                          : LocaleKeys.select_date_range.tr(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ),
                if (bookingProvider.startDate != null ||
                    bookingProvider.statusFilter != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () async {
                      bookingProvider.clearFilters();
                      await bookingProvider.fetchBookings();
                    },
                  ),
              ],
            ),
          ),
          if (bookingProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (bookingProvider.error != null)
            Expanded(
              child: Center(
                child: Text(
                  bookingProvider.error!,
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            )
          else if (bookingProvider.bookings.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      LocaleKeys.no_bookings_found.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBookings,
                child: ListView.builder(
                  itemCount: bookingProvider.bookings.length,
                  itemBuilder: (context, index) =>
                      _buildBookingCard(bookingProvider.bookings[index]),
                ),
              ),
            ),
          if (bookingProvider.totalPages > 1)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: bookingProvider.hasPrevPage
                        ? () => bookingProvider.previousPage()
                        : null,
                    child: Text(LocaleKeys.previous.tr()),
                  ),
                  Text(
                    LocaleKeys.page_value_of_value.tr(args: [
                      "${bookingProvider.currentPage}",
                      "${bookingProvider.totalPages}"
                    ]),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  TextButton(
                    onPressed: bookingProvider.hasNextPage
                        ? () => bookingProvider.nextPage()
                        : null,
                    child: Text(LocaleKeys.next.tr()),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
