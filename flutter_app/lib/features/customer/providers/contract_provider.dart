import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/customer_service.dart';

class ContractNotifier extends AutoDisposeAsyncNotifier<ContractInfo?> {
  @override
  Future<ContractInfo?> build() async {
    // Pre-hydrated from /auth/me
    final fromAuth = ref.read(authStateProvider).user?.contract;
    if (fromAuth != null) return fromAuth;
    return ref.read(customerServiceProvider).getContractStatus();
  }

  Future<void> validate(String contractNumber) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(customerServiceProvider).validateContract(contractNumber),
    );
  }

  void reset() => state = const AsyncData(null);
}

final contractProvider =
    AutoDisposeAsyncNotifierProvider<ContractNotifier, ContractInfo?>(
  ContractNotifier.new,
);
