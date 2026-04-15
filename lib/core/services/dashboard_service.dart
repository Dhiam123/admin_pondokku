import '../network/api_service.dart';

// ──────────────────────────────────────────────
// Dashboard Stats Model
// ──────────────────────────────────────────────

class DashboardStats {
  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents;
  final int paidBills;
  final int unpaidBills;
  final int overdueBills;
  final double totalUnpaidAmount;
  final int totalWallets;
  final double totalWalletBalance;
  final int totalUsers;
  final List<RecentTransaction> recentTransactions;

  DashboardStats({
    required this.totalStudents,
    required this.activeStudents,
    required this.inactiveStudents,
    required this.paidBills,
    required this.unpaidBills,
    required this.overdueBills,
    required this.totalUnpaidAmount,
    required this.totalWallets,
    required this.totalWalletBalance,
    required this.totalUsers,
    required this.recentTransactions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final students = json['students'] as Map<String, dynamic>? ?? {};
    final bills = json['bills'] as Map<String, dynamic>? ?? {};
    final wallets = json['wallets'] as Map<String, dynamic>? ?? {};
    final users = json['users'] as Map<String, dynamic>? ?? {};
    final txList = json['recentTransactions'] as List<dynamic>? ?? [];

    return DashboardStats(
      totalStudents: students['total'] as int? ?? 0,
      activeStudents: students['active'] as int? ?? 0,
      inactiveStudents: students['inactive'] as int? ?? 0,
      paidBills: bills['paid'] as int? ?? 0,
      unpaidBills: bills['unpaid'] as int? ?? 0,
      overdueBills: bills['overdue'] as int? ?? 0,
      totalUnpaidAmount: (bills['totalUnpaidAmount'] as num?)?.toDouble() ?? 0,
      totalWallets: wallets['total'] as int? ?? 0,
      totalWalletBalance: (wallets['totalBalance'] as num?)?.toDouble() ?? 0,
      totalUsers: users['total'] as int? ?? 0,
      recentTransactions: txList
          .map((e) => RecentTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Fallback kosong saat error
  factory DashboardStats.empty() {
    return DashboardStats(
      totalStudents: 0, activeStudents: 0, inactiveStudents: 0,
      paidBills: 0, unpaidBills: 0, overdueBills: 0, totalUnpaidAmount: 0,
      totalWallets: 0, totalWalletBalance: 0, totalUsers: 0,
      recentTransactions: [],
    );
  }
}

class RecentTransaction {
  final int id;
  final String type; // CREDIT | DEBIT
  final double amount;
  final String? description;
  final String? studentNama;
  final String? studentKelas;
  final DateTime? createdAt;

  RecentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.studentNama,
    this.studentKelas,
    this.createdAt,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    final wallet = json['wallet'] as Map<String, dynamic>?;
    final student = wallet?['student'] as Map<String, dynamic>?;
    return RecentTransaction(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'CREDIT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      studentNama: student?['nama'] as String?,
      studentKelas: student?['kelas'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

// ──────────────────────────────────────────────
// Service
// ──────────────────────────────────────────────

class DashboardService {
  final _api = ApiService();

  Future<DashboardStats> fetchStats() async {
    final response = await _api.dio.get('/dashboard');
    final raw = response.data['data'] ?? response.data;
    return DashboardStats.fromJson(raw as Map<String, dynamic>);
  }
}
