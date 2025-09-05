class FarmOwnerProfile {
  final String id;
  final String name;
  final String mobileNumber;
  final bool isVerified;
  final bool isProfileComplete;
  final bool isActive;
  final List<String> farms;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime updatedAt;

  FarmOwnerProfile({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.isVerified,
    required this.isProfileComplete,
    required this.isActive,
    required this.farms,
    this.fcmToken,
    required this.createdAt,
    required this.lastLogin,
    required this.updatedAt,
  });

  factory FarmOwnerProfile.fromJson(Map<String, dynamic> json) {
    return FarmOwnerProfile(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isProfileComplete: json['isProfileComplete'] ?? false,
      isActive: json['isActive'] ?? false,
      farms: List<String>.from(json['farms'] ?? []),
      fcmToken: json['fcmToken'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
      'isActive': isActive,
      'farms': farms,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 