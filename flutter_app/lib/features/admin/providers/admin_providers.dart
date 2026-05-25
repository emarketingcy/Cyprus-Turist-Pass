import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_service.dart';

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>(
  (ref) => ref.watch(adminServiceProvider).getStats(),
);

final adminMerchantsProvider =
    FutureProvider.autoDispose<List<AdminMerchant>>(
  (ref) => ref.watch(adminServiceProvider).getMerchants(),
);

final adminTransactionsProvider =
    FutureProvider.autoDispose<AdminTransactionsPage>(
  (ref) => ref.watch(adminServiceProvider).getTransactions(),
);
