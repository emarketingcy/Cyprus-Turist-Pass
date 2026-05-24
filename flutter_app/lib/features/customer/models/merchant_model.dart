import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

@immutable
class Merchant {
  const Merchant({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.discountRate,
    required this.status,
    this.platformFeeRate = 10.0,
    this.description,
    this.imageUrl,
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
  final String? city;
  final String? address;

  Color get typeColor => switch (businessType) {
        'RESTAURANT' => AppColors.restaurant,
        'HOTEL' => AppColors.hotel,
        'ACTIVITY' => AppColors.activity,
        'SPA' => AppColors.spa,
        'TOUR' => AppColors.tour,
        _ => AppColors.primary,
      };

  String get typeLabel => switch (businessType) {
        'RESTAURANT' => 'Restaurant',
        'HOTEL' => 'Hotel',
        'ACTIVITY' => 'Activity',
        'SPA' => 'Spa',
        'TOUR' => 'Tour',
        _ => businessType,
      };

  factory Merchant.fromJson(Map<String, dynamic> j) => Merchant(
        id: j['id'] as int,
        businessName: j['businessName'] as String,
        businessType: j['businessType'] as String,
        discountRate: (j['discountRate'] as num).toDouble(),
        status: j['status'] as String? ?? 'APPROVED',
        platformFeeRate: (j['platformFeeRate'] as num?)?.toDouble() ?? 10.0,
        description: j['description'] as String?,
        imageUrl: j['imageUrl'] as String?,
        city: j['city'] as String?,
        address: j['address'] as String?,
      );
}
