import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../services/customer_service.dart';

final transactionListProvider =
    AutoDisposeFutureProvider<List<Transaction>>((ref) {
  return ref.watch(customerServiceProvider).getTransactions();
});
