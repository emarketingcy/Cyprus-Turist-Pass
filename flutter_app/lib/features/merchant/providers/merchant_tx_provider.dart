import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../customer/models/transaction_model.dart';
import '../services/merchant_service.dart';

final merchantTxProvider = AutoDisposeFutureProvider<List<Transaction>>((ref) {
  return ref.watch(merchantServiceProvider).getTransactions();
});
