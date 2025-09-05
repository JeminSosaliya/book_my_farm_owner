class Booking {
  final String id;
  final String bookingId;
  final UserInfo user;
  final String farmId;
  final String farmName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int numberOfGuests;
  final PaymentInfo payment;
  final String specialRequest;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.bookingId,
    required this.user,
    required this.farmId,
    required this.farmName,
    required this.checkIn,
    required this.checkOut,
    required this.numberOfGuests,
    required this.payment,
    required this.specialRequest,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      bookingId: json['id'] ?? '',
      user: UserInfo.fromJson(json['userId'] ?? {}),
      farmId: json['farmId'] ?? '',
      farmName: json['farmName'] ?? '',
      checkIn: DateTime.parse(json['checkIn']['date'] ?? DateTime.now().toIso8601String()),
      checkOut: DateTime.parse(json['checkOut']['date'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['numberOfGuests'] ?? 0,
      payment: PaymentInfo.fromJson(json['payment'] ?? {}),
      specialRequest: json['specialRequest'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class UserInfo {
  final String id;
  final String name;

  UserInfo({
    required this.id,
    required this.name,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PaymentInfo {
  final double totalAmount;
  final double securityDeposit;
  final double remainingAmount;
  final String paymentStatus;
  final String paymentId;
  final String paymentMethod;
  final String transactionId;

  PaymentInfo({
    required this.totalAmount,
    required this.securityDeposit,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.paymentId,
    required this.paymentMethod,
    required this.transactionId,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      securityDeposit: (json['securityDeposit'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      paymentId: json['paymentId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
    );
  }
} 