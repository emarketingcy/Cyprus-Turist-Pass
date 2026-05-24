import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_service.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

enum _AuthMode { login, register }

enum _RegRole { tourist, merchant }

const _kTypes = ['RESTAURANT', 'HOTEL', 'ACTIVITY', 'TOUR', 'SPA'];
const _kCities = [
  'Paphos',
  'Limassol',
  'Larnaca',
  'Nicosia',
  'Ayia Napa',
  'Protaras',
  'Troodos',
];

const _kDemos = [
  (label: 'Tourist', email: 'tourist@example.com', pass: 'password123'),
  (label: 'Merchant', email: 'ocean@merchant.com', pass: 'password123'),
  (label: 'Admin', email: 'admin@cypruspass.com', pass: 'password123'),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  _AuthMode _mode = _AuthMode.login;
  _RegRole _role = _RegRole.tourist;
  bool _hidePass = true;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _bizCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  String? _bizType;
  String? _city;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _bizCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final notifier = ref.read(authStateProvider.notifier);
    if (_mode == _AuthMode.login) {
      await notifier.login(_emailCtrl.text.trim(), _passCtrl.text);
      return;
    }

    await notifier.register({
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
      'firstName': _firstCtrl.text.trim(),
      'lastName': _lastCtrl.text.trim(),
      'role': _role == _RegRole.tourist ? 'CUSTOMER' : 'MERCHANT',
      if (_role == _RegRole.merchant) ...{
        'businessName': _bizCtrl.text.trim(),
        'businessType': _bizType,
        'city': _city,
        'address': _addrCtrl.text.trim(),
      },
    });
  }

  void _fillDemo(String email, String pass) {
    _emailCtrl.text = email;
    _passCtrl.text = pass;
    if (_mode != _AuthMode.login) setState(() => _mode = _AuthMode.login);
    ref.read(authStateProvider.notifier).clearError();
  }

  void _switchMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
    });
    ref.read(authStateProvider.notifier).clearError();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    // Biometric lock screen takes priority over the login form.
    if (auth.biometricPending) {
      return _BiometricLockScreen(
        onUnlock: () => ref.read(authStateProvider.notifier).unlockWithBiometric(),
        onUsePassword: () => ref.read(authStateProvider.notifier).cancelBiometric(),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF312E81), // indigo-900
              Color(0xFF0F172A), // slate-900
              Color(0xFF1E293B), // slate-800
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildCard(auth),
                    const SizedBox(height: 24),
                    _buildDemoAccounts(),
                    const SizedBox(height: 16),
                    _buildBranding(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() => Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.location_on_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tourist Pass Cyprus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Exclusive discounts at local merchants',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      );

  // ── Form card ─────────────────────────────────────────────────────────────

  Widget _buildCard(AuthState auth) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModeToggle(),
              const SizedBox(height: 24),
              if (_mode == _AuthMode.register) ...[
                _buildRoleSelector(),
                const SizedBox(height: 20),
              ],
              _buildFormFields(),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorBanner(auth.error!),
              ],
              const SizedBox(height: 20),
              _buildSubmitButton(auth.isLoading),
              const SizedBox(height: 16),
              _buildModeSwitch(),
            ],
          ),
        ),
      );

  // ── Mode toggle ───────────────────────────────────────────────────────────

  Widget _buildModeToggle() => Container(
        decoration: BoxDecoration(
          color: AppColors.surface100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [_tab('Sign In', _AuthMode.login), _tab('Register', _AuthMode.register)],
        ),
      );

  Widget _tab(String label, _AuthMode mode) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.surface800 : AppColors.surface500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Role selector ─────────────────────────────────────────────────────────

  Widget _buildRoleSelector() => Row(
        children: [
          Expanded(child: _roleCard(_RegRole.tourist)),
          const SizedBox(width: 12),
          Expanded(child: _roleCard(_RegRole.merchant)),
        ],
      );

  Widget _roleCard(_RegRole role) {
    final isTourist = role == _RegRole.tourist;
    final selected = _role == role;
    final accent = isTourist ? AppColors.primary : AppColors.success;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withAlpha(15) : AppColors.surface50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? accent : AppColors.surface200,
              width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(
              isTourist ? Icons.person_rounded : Icons.storefront_rounded,
              color: selected ? accent : AppColors.surface400,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              isTourist ? 'Tourist' : 'Merchant',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? accent : AppColors.surface600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form fields ───────────────────────────────────────────────────────────

  Widget _buildFormFields() => Column(
        children: [
          if (_mode == _AuthMode.register) ...[
            Row(
              children: [
                Expanded(child: _field(_firstCtrl, 'First Name', required: true)),
                const SizedBox(width: 12),
                Expanded(child: _field(_lastCtrl, 'Last Name', required: true)),
              ],
            ),
            const SizedBox(height: 14),
          ],
          _field(_emailCtrl, 'Email Address',
              type: TextInputType.emailAddress,
              required: true,
              validator: _validateEmail),
          const SizedBox(height: 14),
          _field(
            _passCtrl,
            'Password',
            obscure: _hidePass,
            required: true,
            validator: _validatePassword,
            suffix: IconButton(
              icon: Icon(
                _hidePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.surface400,
                size: 20,
              ),
              onPressed: () => setState(() => _hidePass = !_hidePass),
            ),
          ),
          if (_mode == _AuthMode.register && _role == _RegRole.merchant) ...[
            const SizedBox(height: 14),
            _field(_bizCtrl, 'Business Name', required: true),
            const SizedBox(height: 14),
            _dropdown(
              value: _bizType,
              label: 'Business Type',
              items: _kTypes,
              displayFn: _formatType,
              onChanged: (v) => setState(() => _bizType = v),
            ),
            const SizedBox(height: 14),
            _dropdown(
              value: _city,
              label: 'City',
              items: _kCities,
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 14),
            _field(_addrCtrl, 'Address', required: true),
          ],
        ],
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    bool required = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        obscureText: obscure,
        textInputAction: TextInputAction.next,
        onChanged: (_) {
          if (ref.read(authStateProvider).error != null) {
            ref.read(authStateProvider.notifier).clearError();
          }
        },
        decoration: InputDecoration(labelText: label, suffixIcon: suffix),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? '$label is required'
                    : null
                : null),
      );

  Widget _dropdown({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? displayFn,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((e) => DropdownMenuItem(
                value: e, child: Text(displayFn?.call(e) ?? e)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? '$label is required' : null,
      );

  // ── Validators ────────────────────────────────────────────────────────────

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false);
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Error / submit / misc ─────────────────────────────────────────────────

  Widget _buildErrorBanner(String message) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13, height: 1.4)),
            ),
          ],
        ),
      );

  Widget _buildSubmitButton(bool loading) => ElevatedButton(
        onPressed: loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _mode == _AuthMode.login
              ? AppColors.primary
              : AppColors.success,
          disabledBackgroundColor: AppColors.surface300,
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(_mode == _AuthMode.login
                ? 'Sign In'
                : _role == _RegRole.merchant
                    ? 'Create Merchant Account'
                    : 'Create Tourist Account'),
      );

  Widget _buildModeSwitch() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _mode == _AuthMode.login
                ? "Don't have an account? "
                : 'Already have an account? ',
            style: const TextStyle(color: AppColors.surface500, fontSize: 13),
          ),
          GestureDetector(
            onTap: () => _switchMode(
              _mode == _AuthMode.login ? _AuthMode.register : _AuthMode.login,
            ),
            child: Text(
              _mode == _AuthMode.login ? 'Register' : 'Sign In',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );

  Widget _buildDemoAccounts() => Column(
        children: [
          const Text('Demo accounts',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _kDemos
                .map((d) => ActionChip(
                      label: Text(d.label),
                      labelStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      backgroundColor: Colors.white.withAlpha(20),
                      side: BorderSide(color: Colors.white.withAlpha(51)),
                      onPressed: () => _fillDemo(d.email, d.pass),
                    ))
                .toList(),
          ),
        ],
      );

  Widget _buildBranding() => const Text(
        'By Malaka Cyprus · malaka.cy',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF475569), fontSize: 11),
      );

  String _formatType(String t) => switch (t) {
        'RESTAURANT' => 'Restaurant',
        'HOTEL' => 'Hotel',
        'ACTIVITY' => 'Activity',
        'TOUR' => 'Tour',
        'SPA' => 'Spa',
        _ => t,
      };
}

// ─── Biometric lock screen ────────────────────────────────────────────────────

class _BiometricLockScreen extends ConsumerStatefulWidget {
  const _BiometricLockScreen({
    required this.onUnlock,
    required this.onUsePassword,
  });

  final VoidCallback onUnlock;
  final VoidCallback onUsePassword;

  @override
  ConsumerState<_BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<_BiometricLockScreen> {
  String _bioLabel = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _loadLabel();
    // Trigger biometric prompt automatically on first show.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onUnlock());
  }

  Future<void> _loadLabel() async {
    final label = await ref.read(biometricServiceProvider).label();
    if (mounted) setState(() => _bioLabel = label);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF312E81), Color(0xFF0F172A), Color(0xFF1E293B)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.white.withAlpha(40), width: 1.5),
                    ),
                    child: const Icon(Icons.fingerprint_rounded,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Tourist Pass Cyprus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock with $_bioLabel to continue',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : widget.onUnlock,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.fingerprint_rounded),
                      label: Text('Unlock with $_bioLabel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onUsePassword,
                    child: const Text(
                      'Use password instead',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
