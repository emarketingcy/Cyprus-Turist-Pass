import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/merchant_model.dart';
import '../services/customer_service.dart';

class MerchantNotifier extends AutoDisposeAsyncNotifier<List<Merchant>> {
  String _search = '';
  String? _typeFilter;
  String? _cityFilter;

  @override
  Future<List<Merchant>> build() {
    return ref.read(customerServiceProvider).getMerchants(
          search: _search,
          type: _typeFilter,
          city: _cityFilter,
        );
  }

  Future<void> search(String query) async {
    _search = query;
    ref.invalidateSelf();
  }

  Future<void> filterType(String? type) async {
    _typeFilter = type;
    ref.invalidateSelf();
  }

  Future<void> filterCity(String? city) async {
    _cityFilter = city;
    ref.invalidateSelf();
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

final merchantListProvider =
    AutoDisposeAsyncNotifierProvider<MerchantNotifier, List<Merchant>>(
  MerchantNotifier.new,
);
