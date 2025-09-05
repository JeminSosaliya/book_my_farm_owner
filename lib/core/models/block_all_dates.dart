class BlockAllDates {
  final String farmId;
  final String farmName;
  final List<BookedDate> bookedDates;

  BlockAllDates({
    required this.farmId,
    required this.farmName,
    required this.bookedDates,
  });

  factory BlockAllDates.fromJson(Map<String, dynamic> json) {
    return BlockAllDates(
      farmId: json['farmId'] ?? '',
      farmName: json['farmName'] ?? '',
      bookedDates: (json['bookedDates'] as List<dynamic>)
          .map((e) => BookedDate.fromJson(e))
          .toList(),
    );
  }
}

class BookedDate {
  final BookingTime checkIn;
  final BookingTime checkOut;
  final bool isBlocked;
  final String? reason;

  BookedDate({
    required this.checkIn,
    required this.checkOut,
    this.isBlocked = false,
    this.reason,
  });

  factory BookedDate.fromJson(Map<String, dynamic> json) {
    return BookedDate(
      checkIn: BookingTime.fromJson(json['checkIn']),
      checkOut: BookingTime.fromJson(json['checkOut']),
      isBlocked: json['isBlocked'] ?? false,
      reason: json['reason'],
    );
  }
}

class BookingTime {
  final DateTime date;
  final String time;

  BookingTime({
    required this.date,
    required this.time,
  });

  factory BookingTime.fromJson(Map<String, dynamic> json) {
    return BookingTime(
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
    );
  }
}
