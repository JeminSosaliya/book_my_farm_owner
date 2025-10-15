import 'package:book_my_farm_owner/core/models/booking.dart';
import 'package:book_my_farm_owner/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/app_colors.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    if (!mounted) return;
    final BookingProvider bookingProvider = context.read<BookingProvider>();
    await bookingProvider.fetchBookingDetails(widget.bookingId);
  }

  @override
  void dispose() {
    context.read<BookingProvider>().clearSelectedBooking();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: Colors.grey),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    IconData icon;
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        icon = Icons.hourglass_top;
        color = Colors.orange;
        break;
      case 'confirmed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'completed':
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPaymentInfo(Booking? booking) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.payment_details.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            LocaleKeys.total_amount.tr(),
            '₹${booking?.payment.totalAmount ?? 0}',
          ),
          _buildInfoRow(
            LocaleKeys.security_deposit.tr(),
            '₹${booking?.payment.securityDeposit ?? 0}',
          ),
          _buildInfoRow(
            LocaleKeys.remaining_amount.tr(),
            '₹${booking?.payment.remainingAmount ?? 0}',
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       LocaleKeys.payment_status.tr(),
          //       style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          //     ),
          //     _buildStatusChip(booking?.payment.paymentStatus ?? ""),
          //   ],
          // ),
          // SizedBox(height: 8.h),
          _buildInfoRow(
            LocaleKeys.payment_method.tr(),
            (booking?.payment.paymentMethod ?? "").toUpperCase(),
            icon: Icons.credit_card,
          ),
          _buildInfoRow(
            LocaleKeys.transaction_id.tr(),
            booking?.payment.transactionId ?? "",
            icon: Icons.receipt,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BookingProvider bookingProvider = context.watch<BookingProvider>();
    final Booking? booking = bookingProvider.selectedBooking;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.booking_details.tr()),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          // : bookingProvider.error != null
          //     ? Center(
          //         child: Text(
          //           bookingProvider.error!,
          //           style: TextStyle(
          //             color: AppColors.errorColor,
          //             fontSize: 16.sp,
          //           ),
          //         ),
          //       )
          : booking == null
              ? Center(child: Text(LocaleKeys.no_booking_details_found.tr()))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  booking.bookingId,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildStatusChip(booking.status),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildInfoRow(
                              LocaleKeys.guest_name.tr(),
                              booking.user.name,
                              icon: Icons.person,
                            ),
                            _buildInfoRow(
                              LocaleKeys.farm_name.tr(),
                              booking.farmName,
                              icon: Icons.home,
                            ),
                            _buildInfoRow(
                              LocaleKeys.check_in_date.tr(),
                              DateFormat('MMM dd, yyyy')
                                  .format(booking.checkIn),
                              icon: Icons.login,
                            ),
                            _buildInfoRow(
                              LocaleKeys.check_out_date.tr(),
                              DateFormat('MMM dd, yyyy')
                                  .format(booking.checkOut),
                              icon: Icons.logout,
                            ),
                            _buildInfoRow(
                              LocaleKeys.number_of_guests.tr(),
                              booking.numberOfGuests.toString(),
                              icon: Icons.people,
                            ),
                            if (booking.specialRequest.isNotEmpty)
                              _buildInfoRow(
                                LocaleKeys.special_request.tr(),
                                booking.specialRequest,
                                icon: Icons.note_alt,
                              ),
                          ],
                        ),
                      ),
                      _buildPaymentInfo(booking),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timeline,
                                    color: AppColors.primaryColor, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  LocaleKeys.booking_timeline.tr(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildInfoRow(
                              LocaleKeys.created_at.tr(),
                              DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(booking.createdAt),
                              icon: Icons.access_time,
                            ),
                            _buildInfoRow(
                              LocaleKeys.last_updated.tr(),
                              DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(booking.updatedAt),
                              icon: Icons.update,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
