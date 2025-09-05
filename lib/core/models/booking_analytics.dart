class BookingAnalytics {
  final int totalBookings;
  final double totalRevenue;
  final StatusBreakdown statusBreakdown;
  final RevenueByStatus revenueByStatus;
  final Map<String, FarmBookingStats> bookingsByFarm;
  final List<RecentBooking> recentBookings;

  BookingAnalytics({
    required this.totalBookings,
    required this.totalRevenue,
    required this.statusBreakdown,
    required this.revenueByStatus,
    required this.bookingsByFarm,
    required this.recentBookings,
  });

  factory BookingAnalytics.fromJson(Map<String, dynamic> json) {
    final Map<String, FarmBookingStats> farmStats = {};
    json['bookingsByFarm']?.forEach((key, value) {
      farmStats[key] = FarmBookingStats. fromJson(value);
    });

    return BookingAnalytics(
      totalBookings: json['totalBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      statusBreakdown: StatusBreakdown.fromJson(json['statusBreakdown'] ?? {}),
      revenueByStatus: RevenueByStatus.fromJson(json['revenueByStatus'] ?? {}),
      bookingsByFarm: farmStats,
      recentBookings: (json['recentBookings'] ?? [])
          .map<RecentBooking>((booking) => RecentBooking.fromJson(booking))
          .toList(),
    );
  }
}

class StatusBreakdown {
  final int confirmed;
  final int completed;
  final int cancelled;

  StatusBreakdown({
    required this.confirmed,
    required this.completed,
    required this.cancelled,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      confirmed: json['confirmed'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

class RevenueByStatus {
  final double confirmed;
  final double completed;

  RevenueByStatus({
    required this.confirmed,
    required this.completed,
  });

  factory RevenueByStatus.fromJson(Map<String, dynamic> json) {
    return RevenueByStatus(
      confirmed: (json['confirmed'] ?? 0).toDouble(),
      completed: (json['completed'] ?? 0).toDouble(),
    );
  }
}

class FarmBookingStats {
  final String farmName;
  final int totalBookings;
  final double revenue;
  final StatusBreakdown statusBreakdown;

  FarmBookingStats({
    required this.farmName,
    required this.totalBookings,
    required this.revenue,
    required this.statusBreakdown,
  });

  factory FarmBookingStats.fromJson(Map<String, dynamic> json) {
    return FarmBookingStats(
      farmName: json['farmName'] ?? '',
      totalBookings: json['totalBookings'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      statusBreakdown: StatusBreakdown.fromJson(json['statusBreakdown'] ?? {}),
    );
  }
}

class RecentBooking {
  final String bookingId;
  final String farmId;
  final String farmName;
  final String status;
  final double amount;
  final DateTime createdAt;

  RecentBooking({
    required this.bookingId,
    required this.farmId,
    required this.farmName,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      bookingId: json['bookingId'] ?? '',
      farmId: json['farmId'] ?? '',
      farmName: json['farmName'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
} 