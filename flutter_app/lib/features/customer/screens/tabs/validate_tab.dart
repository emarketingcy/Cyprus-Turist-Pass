import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/models/user_model.dart';
import '../../providers/contract_provider.dart';

class ValidateTab extends ConsumerStatefulWidget {
  const ValidateTab({super.key});

  @override
  ConsumerState<ValidateTab> createState() => _ValidateTabState();
}

class _ValidateTabState extends ConsumerState<ValidateTab> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(contractProvider.notifier).validate(_ctrl.text.trim().toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final contractAsync = ref.watch(contractProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInputCard(),
          const SizedBox(height: 20),
          contractAsync.when(
            data: (contract) => contract != null
                ? _buildContractCard(contract)
                : _buildEmptyHint(),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => _buildErrorCard(e.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Tourist Pass',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.surface800,
                letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'Validate your rental contract to unlock discounts.',
            style: TextStyle(color: AppColors.surface500, fontSize: 14),
          ),
        ],
      );

  Widget _buildInputCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Rental Contract Number',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.surface700),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'e.g. TEST12345 or HZ98765',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a contract number' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _validate,
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text('Validate Contract'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildContractCard(ContractInfo contract) {
    final fmt = DateFormat('d MMM yyyy');
    final valid = contract.isValid;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: valid ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: valid ? AppColors.successSurface : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: valid
                          ? AppColors.success.withAlpha(80)
                          : AppColors.error.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        valid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 14,
                        color: valid ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        valid ? 'Active' : 'Expired',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: valid ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  contract.agencyName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.surface800),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _row(Icons.confirmation_number_outlined, 'Contract',
                contract.contractNumber),
            const SizedBox(height: 10),
            _row(Icons.directions_car_rounded, 'Vehicle',
                contract.vehicleClass),
            const SizedBox(height: 10),
            _row(Icons.calendar_today_rounded, 'Period',
                '${fmt.format(contract.startDate)} – ${fmt.format(contract.endDate)}'),
            if (valid) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.discount_rounded,
                        color: AppColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Discounts are unlocked. Go to Discover!',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.surface400),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.surface500, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.surface700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );

  Widget _buildEmptyHint() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surface200),
        ),
        child: Column(
          children: [
            Icon(Icons.card_travel_rounded,
                size: 48, color: AppColors.surface300),
            const SizedBox(height: 12),
            const Text(
              'No contract validated yet',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.surface600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your rental contract number above to activate your discounts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.surface500, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );

  Widget _buildErrorCard(String message) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.replaceAll('Exception: ', ''),
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}
