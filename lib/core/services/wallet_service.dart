import '../network/api_service.dart';

// ──────────────────────────────────────────────
// Models
// ──────────────────────────────────────────────

class WalletApi {
  final int id;
  final int studentId;
  final String studentNama;
  final String studentKelas;
  final double balance;
  final DateTime? updatedAt;

  WalletApi({
    required this.id,
    required this.studentId,
    required this.studentNama,
    required this.studentKelas,
    required this.balance,
    this.updatedAt,
  });

  factory WalletApi.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    return WalletApi(
      id: json['id'] as int,
      studentId: json['studentId'] as int? ?? 0,
      studentNama: student?['nama'] as String? ?? '-',
      studentKelas: student?['kelas'] as String? ?? '-',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class TransactionApi {
  final int id;
  final int walletId;
  final String type; // DEBIT | CREDIT
  final double amount;
  final String? description;
  final DateTime? createdAt;

  TransactionApi({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.description,
    this.createdAt,
  });

  factory TransactionApi.fromJson(Map<String, dynamic> json) {
    return TransactionApi(
      id: json['id'] as int,
      walletId: json['walletId'] as int? ?? 0,
      type: json['type'] as String? ?? 'CREDIT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

// ──────────────────────────────────────────────
// Service
// ──────────────────────────────────────────────

class WalletService {
  final _api = ApiService();

  Future<List<WalletApi>> fetchAll() async {
    final response = await _api.dio.get('/wallets');
    final raw = response.data;
    final List<dynamic> list =
        (raw['data'] is Map ? raw['data']['data'] : raw['data']) as List? ?? [];
    return list.map((e) => WalletApi.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WalletApi> getByStudent(int studentId) async {
    final response = await _api.dio.get('/wallets/student/$studentId');
    return WalletApi.fromJson(
        (response.data['data'] ?? response.data) as Map<String, dynamic>);
  }

  Future<WalletApi> create(int studentId) async {
    final response = await _api.dio.post('/wallets', data: {'studentId': studentId});
    return WalletApi.fromJson(
        (response.data['data'] ?? response.data) as Map<String, dynamic>);
  }

  double get totalBalance => 0; // Dihitung dari daftar wallet di UI
}
