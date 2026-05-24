abstract final class ApiConstants {
  // Injected via --dart-define=API_BASE_URL=https://your-wp.com/wp-json
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-wp-site.com/wp-json',
  );
  static const _ns = 'ctp/v1';
  static const apiBase = '$baseUrl/$_ns';

  // ── Auth ──────────────────────────────────────────────────────────
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const me = '/auth/me';

  // ── Rental ────────────────────────────────────────────────────────
  static const rentalPreCheck = '/rental/pre-check';
  static const rentalValidate = '/rental/validate';
  static const rentalStatus = '/rental/status';
  static const rentalAgencies = '/rental/agencies';

  // ── Merchants ─────────────────────────────────────────────────────
  static const merchants = '/merchants';
  static const merchantProfile = '/merchants/profile';

  // ── Payment ───────────────────────────────────────────────────────
  static const createQr = '/payment/create-qr';
  static const validateQr = '/payment/validate-qr';
  static const processPayment = '/payment/process';
  static const transactions = '/payment/transactions';

  // ── Admin ─────────────────────────────────────────────────────────
  static const adminStats = '/admin/stats';
  static const adminMerchants = '/admin/merchants';
  static const adminTransactions = '/admin/transactions';
  static const adminCustomers = '/admin/customers';
  static const adminSettings = '/admin/settings';
  static const adminAgencies = '/admin/agencies';

  // ── Storage keys ──────────────────────────────────────────────────
  static const jwtKey = 'ctp_jwt';
  static const userRoleKey = 'ctp_role';
  static const biometricKey = 'ctp_biometric_enabled';
}
