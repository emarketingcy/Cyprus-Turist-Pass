import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qr_token_model.dart';
import '../services/customer_service.dart';

class QrNotifier extends AutoDisposeAsyncNotifier<QrToken?> {
  @override
  Future<QrToken?> build() async => null;

  Future<void> generate(int merchantId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(customerServiceProvider).createQrToken(merchantId),
    );
  }

  void clear() => state = const AsyncData(null);
}

final qrProvider =
    AutoDisposeAsyncNotifierProvider<QrNotifier, QrToken?>(QrNotifier.new);
