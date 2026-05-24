import 'package:flutter/foundation.dart';

enum UserRole { customer, merchant, admin }

extension UserRoleX on UserRole {
  static UserRole fromString(String s) => switch (s.toUpperCase()) {
        'MERCHANT' => UserRole.merchant,
        'ADMIN' => UserRole.admin,
        _ => UserRole.customer,
      };

  String get displayName => switch (this) {
        UserRole.customer => 'Tourist',
        UserRole.merchant => 'Merchant',
        UserRole.admin => 'Admin',
      };
}

@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.merchantProfile,
    this.contract,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final MerchantProfile? merchantProfile;
  final ContractInfo? contract;

  String get displayName => '$firstName $lastName'.trim();
  bool get hasActiveContract => contract?.isValid ?? false;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        role: UserRoleX.fromString(json['role'] as String? ?? 'CUSTOMER'),
        merchantProfile: json['merchantProfile'] != null
            ? MerchantProfile.fromJson(
                json['merchantProfile'] as Map<String, dynamic>)
            : null,
        contract: json['contract'] != null
            ? ContractInfo.fromJson(json['contract'] as Map<String, dynamic>)
            : null,
      );
}

@immutable
class MerchantProfile {
  const MerchantProfile({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.discountRate,
    required this.status,
    this.platformFeeRate = 10.0,
    this.description,
    this.imageUrl,
    this.menuUrl,
    this.city,
    this.address,
  });

  final int id;
  final String businessName;
  final String businessType;
  final double discountRate;
  final String status;
  final double platformFeeRate;
  final String? description;
  final String? imageUrl;
  final String? menuUrl;
  final String? city;
  final String? address;

  bool get isApproved => status == 'APPROVED';
  bool get isPending => status == 'PENDING';

  factory MerchantProfile.fromJson(Map<String, dynamic> json) =>
      MerchantProfile(
        id: json['id'] as int,
        businessName: json['businessName'] as String,
        businessType: json['businessType'] as String,
        discountRate: (json['discountRate'] as num).toDouble(),
        status: json['status'] as String,
        platformFeeRate:
            (json['platformFeeRate'] as num?)?.toDouble() ?? 10.0,
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        menuUrl: json['menuUrl'] as String?,
        city: json['city'] as String?,
        address: json['address'] as String?,
      );
}

@immutable
class ContractInfo {
  const ContractInfo({
    required this.contractNumber,
    required this.agencyName,
    required this.vehicleClass,
    required this.startDate,
    required this.endDate,
  });

  final String contractNumber;
  final String agencyName;
  final String vehicleClass;
  final DateTime startDate;
  final DateTime endDate;

  bool get isValid => endDate.isAfter(DateTime.now());

  factory ContractInfo.fromJson(Map<String, dynamic> json) => ContractInfo(
        contractNumber: json['contractNumber'] as String,
        agencyName: json['agencyName'] as String,
        vehicleClass: json['vehicleClass'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
      );
}
