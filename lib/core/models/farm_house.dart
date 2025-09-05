// class FarmHouse {
//   final String id;
//   final String farmhouseId; // ✅ Newly added field
//   final BasicInfo basicInfo;
//   final Location location;
//   final Pricing pricing;
//   final Timings timings;
//   final List<String> amenities;
//   final HouseRules houseRules;
//   final Media media;
//   final OwnerInfo ownerInfo;
//   final String status;
//   final Statistics statistics;
//   final List<dynamic> recentBookings;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   FarmHouse({
//     required this.id,
//     required this.farmhouseId, // ✅ Constructor updated
//     required this.basicInfo,
//     required this.location,
//     required this.pricing,
//     required this.timings,
//     required this.amenities,
//     required this.houseRules,
//     required this.media,
//     required this.ownerInfo,
//     required this.status,
//     required this.statistics,
//     required this.recentBookings,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory FarmHouse.fromJson(Map<String, dynamic> json) {
//     return FarmHouse(
//       id: json['id'] ?? '',
//       farmhouseId: json['farmhouseid'] ?? '', // ✅ Parse from JSON
//       basicInfo: BasicInfo.fromJson(json['basicInfo'] ?? {}),
//       location: Location.fromJson(json['location'] ?? {}),
//       pricing: Pricing.fromJson(json['pricing'] ?? {}),
//       timings: Timings.fromJson(json['timings'] ?? {}),
//       amenities: List<String>.from(json['amenities'] ?? []),
//       houseRules: HouseRules.fromJson(json['houseRules'] ?? {}),
//       media: Media.fromJson(json['media'] ?? {}),
//       ownerInfo: OwnerInfo.fromJson(json['ownerInfo'] ?? {}),
//       status: json['status'] ?? '',
//       statistics: Statistics.fromJson(json['statistics'] ?? {}),
//       recentBookings: json['recentBookings'] ?? [],
//       createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
//       updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
//     );
//   }
// }
//
// class BasicInfo {
//   final String name;
//   final String description;
//   final String propertyType;
//   final int area;
//   final int bedrooms;
//   final int capacity;
//
//   BasicInfo({
//     required this.name,
//     required this.description,
//     required this.propertyType,
//     required this.area,
//     required this.bedrooms,
//     required this.capacity,
//   });
//
//   factory BasicInfo.fromJson(Map<String, dynamic> json) {
//     return BasicInfo(
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       propertyType: json['propertyType'] ?? '',
//       area: json['area'] ?? 0,
//       bedrooms: json['bedrooms'] ?? 0,
//       capacity: json['capacity'] ?? 0,
//     );
//   }
// }
//
// class Location {
//   final Coordinates coordinates;
//
//   Location({required this.coordinates});
//
//   factory Location.fromJson(Map<String, dynamic> json) {
//     return Location(
//       coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
//     );
//   }
// }
//
// class Coordinates {
//   final String type;
//   final double latitude;
//   final double longitude;
//
//   Coordinates({
//     required this.type,
//     required this.latitude,
//     required this.longitude,
//   });
//
//   factory Coordinates.fromJson(Map<String, dynamic> json) {
//     return Coordinates(
//       type: json['type'] ?? '',
//       latitude: json['latitude'] ?? 0.0,
//       longitude: json['longitude'] ?? 0.0,
//     );
//   }
// }
//
// class Pricing {
//   final Price normal;
//   final Price holiday;
//
//   Pricing({
//     required this.normal,
//     required this.holiday,
//   });
//
//   factory Pricing.fromJson(Map<String, dynamic> json) {
//     return Pricing(
//       normal: Price.fromJson(json['normal'] ?? {}),
//       holiday: Price.fromJson(json['holiday'] ?? {}),
//     );
//   }
// }
//
// class Price {
//   final double originalPrice;
//   final double discountedPrice;
//   final double discountPercent;
//   final double deposit;
//
//   Price({
//     required this.originalPrice,
//     required this.discountedPrice,
//     required this.discountPercent,
//     required this.deposit,
//   });
//
//   factory Price.fromJson(Map<String, dynamic> json) {
//     return Price(
//       originalPrice: (json['originalPrice'] ?? 0).toDouble(),
//       discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
//       discountPercent: (json['discountPercent'] ?? 0).toDouble(),
//       deposit: (json['deposit'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class Timings {
//   final String checkIn;
//   final String checkOut;
//
//   Timings({
//     required this.checkIn,
//     required this.checkOut,
//   });
//
//   factory Timings.fromJson(Map<String, dynamic> json) {
//     return Timings(
//       checkIn: json['checkIn'] ?? '',
//       checkOut: json['checkOut'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'checkIn': checkIn,
//       'checkOut': checkOut,
//     };
//   }
// }
//
//
// class HouseRules {
//   final bool couples;
//   final bool pets;
//   final bool nonVeg;
//   final bool smoking;
//   final bool decoration;
//   final bool bachelors;
//
//   HouseRules({
//     required this.couples,
//     required this.pets,
//     required this.nonVeg,
//     required this.smoking,
//     required this.decoration,
//     required this.bachelors,
//   });
//
//   factory HouseRules.fromJson(Map<String, dynamic> json) {
//     return HouseRules(
//       couples: json['couples'] ?? false,
//       pets: json['pets'] ?? false,
//       nonVeg: json['nonVeg'] ?? false,
//       smoking: json['smoking'] ?? false,
//       decoration: json['decoration'] ?? false,
//       bachelors: json['bachelors'] ?? false,
//     );
//   }
// }
//
// class Media {
//   final List<String> images;
//   final String? video;
//
//   Media({
//     required this.images,
//     this.video,
//   });
//
//   factory Media.fromJson(Map<String, dynamic> json) {
//     return Media(
//       images: List<String>.from(json['images'] ?? []),
//       video: json['video'],
//     );
//   }
// }
//
// class OwnerInfo {
//   final String name;
//   final String phone;
//   final String email;
//
//   OwnerInfo({
//     required this.name,
//     required this.phone,
//     required this.email,
//   });
//
//   factory OwnerInfo.fromJson(Map<String, dynamic> json) {
//     return OwnerInfo(
//       name: json['name'] ?? '',
//       phone: json['phone'] ?? '',
//       email: json['email'] ?? '',
//     );
//   }
// }
//
// class Statistics {
//   final Bookings bookings;
//   final double totalRevenue;
//
//   Statistics({
//     required this.bookings,
//     required this.totalRevenue,
//   });
//
//   factory Statistics.fromJson(Map<String, dynamic> json) {
//     return Statistics(
//       bookings: Bookings.fromJson(json['bookings'] ?? {}),
//       totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class Bookings {
//   final int total;
//   final int pending;
//   final int confirmed;
//   final int completed;
//   final int cancelled;
//
//   Bookings({
//     required this.total,
//     required this.pending,
//     required this.confirmed,
//     required this.completed,
//     required this.cancelled,
//   });
//
//   factory Bookings.fromJson(Map<String, dynamic> json) {
//     return Bookings(
//       total: json['total'] ?? 0,
//       pending: json['pending'] ?? 0,
//       confirmed: json['confirmed'] ?? 0,
//       completed: json['completed'] ?? 0,
//       cancelled: json['cancelled'] ?? 0,
//     );
//   }
// }

class FarmHouse {
  final String id;
  final String farmhouseId;
  final BasicInfo basicInfo;
  final Location location;
  final Pricing pricing;
  final Timings timings;
  final List<String> amenities;
  final HouseRules houseRules;
  final Media media;
  final OwnerInfo ownerInfo;
  final String status;
  final Statistics statistics;
  final List<Booking> recentBookings;
  final DateTime createdAt;
  final DateTime updatedAt;

  FarmHouse({
    required this.id,
    required this.farmhouseId,
    required this.basicInfo,
    required this.location,
    required this.pricing,
    required this.timings,
    required this.amenities,
    required this.houseRules,
    required this.media,
    required this.ownerInfo,
    required this.status,
    required this.statistics,
    required this.recentBookings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmHouse.fromJson(Map<String, dynamic> json) {
    return FarmHouse(
      id: json['id'] ?? '',
      farmhouseId: json['farmhouseid'] ?? '',
      basicInfo: BasicInfo.fromJson(json['basicInfo'] ?? {}),
      location: Location.fromJson(json['location'] ?? {}),
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      timings: Timings.fromJson(json['timings'] ?? {}),
      amenities: List<String>.from(json['amenities'] ?? []),
      houseRules: HouseRules.fromJson(json['houseRules'] ?? {}),
      media: Media.fromJson(json['media'] ?? {}),
      ownerInfo: OwnerInfo.fromJson(json['ownerInfo'] ?? {}),
      status: json['status'] ?? '',
      statistics: Statistics.fromJson(json['statistics'] ?? {}),
      recentBookings: (json['recentBookings'] as List<dynamic>?)
          ?.map((e) => Booking.fromJson(e))
          .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

class BasicInfo {
  final String name;
  final String description;
  final String propertyType;
  final int area;
  final int bedrooms;
  final int capacity;

  BasicInfo({
    required this.name,
    required this.description,
    required this.propertyType,
    required this.area,
    required this.bedrooms,
    required this.capacity,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      propertyType: json['propertyType'] ?? '',
      area: json['area'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      capacity: json['capacity'] ?? 0,
    );
  }
}

class Location {
  final Address address;
  final Coordinates coordinates;

  Location({
    required this.address,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: Address.fromJson(json['address'] ?? {}),
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zipCode'] ?? '',
    );
  }
}

class Coordinates {
  final String type;
  final double latitude;
  final double longitude;

  Coordinates({
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      type: json['type'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class Pricing {
  final Price normal;
  final Price holiday;

  Pricing({
    required this.normal,
    required this.holiday,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      normal: Price.fromJson(json['normal'] ?? {}),
      holiday: Price.fromJson(json['holiday'] ?? {}),
    );
  }
}

class Price {
  final double originalPrice;
  final double discountedPrice;
  final double discountPercent;
  final double deposit;

  Price({
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.deposit,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
    );
  }
}

class Timings {
  final String checkIn;
  final String checkOut;

  Timings({
    required this.checkIn,
    required this.checkOut,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      checkIn: json['checkIn'] ?? '',
      checkOut: json['checkOut'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
    };
  }
}

class HouseRules {
  final bool couples;
  final bool pets;
  final bool nonVeg;
  final bool smoking;
  final bool decoration;
  final bool bachelors;

  HouseRules({
    required this.couples,
    required this.pets,
    required this.nonVeg,
    required this.smoking,
    required this.decoration,
    required this.bachelors,
  });

  factory HouseRules.fromJson(Map<String, dynamic> json) {
    return HouseRules(
      couples: json['couples'] ?? false,
      pets: json['pets'] ?? false,
      nonVeg: json['nonVeg'] ?? false,
      smoking: json['smoking'] ?? false,
      decoration: json['decoration'] ?? false,
      bachelors: json['bachelors'] ?? false,
    );
  }
}

class Media {
  final List<String> images;
  final String? video;

  Media({
    required this.images,
    this.video,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      images: List<String>.from(json['images'] ?? []),
      video: json['video'],
    );
  }
}

class OwnerInfo {
  final String name;
  final String phone;
  final String email;

  OwnerInfo({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Statistics {
  final Bookings bookings;
  final double totalRevenue;

  Statistics({
    required this.bookings,
    required this.totalRevenue,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      bookings: Bookings.fromJson(json['bookings'] ?? {}),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class Bookings {
  final int total;
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;

  Bookings({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
  });

  factory Bookings.fromJson(Map<String, dynamic> json) {
    return Bookings(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

class Booking {
  final String id;
  final DateTime checkInDate;
  final String checkInTime;
  final DateTime checkOutDate;
  final String checkOutTime;
  final String status;

  Booking({
    required this.id,
    required this.checkInDate,
    required this.checkInTime,
    required this.checkOutDate,
    required this.checkOutTime,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      checkInDate: DateTime.parse(json['checkIn']['date']),
      checkInTime: json['checkIn']['time'] ?? '',
      checkOutDate: DateTime.parse(json['checkOut']['date']),
      checkOutTime: json['checkOut']['time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
