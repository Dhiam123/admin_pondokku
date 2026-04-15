import '../network/api_service.dart';

// ──────────────────────────────────────────────
// Models
// ──────────────────────────────────────────────

enum BillStatus { unpaid, paid, overdue, partial }

class BillApi {
  final int id;
  final String title;
  final double amount;
  final int studentId;
  final String studentNama;
  final BillStatus status;
  final String? dueDate;
  final String? paidAt;
  final DateTime? createdAt;

  BillApi({
    required this.id,
    required this.title,
    required this.amount,
    required this.studentId,
    required this.studentNama,
    required this.status,
    this.dueDate,
    this.paidAt,
    this.createdAt,
  });

  factory BillApi.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'UNPAID';
    BillStatus status;
    switch (statusStr.toUpperCase()) {
      case 'PAID':
        status = BillStatus.paid;
        break;
      case 'OVERDUE':
        status = BillStatus.overdue;
        break;
      case 'PARTIAL':
        status = BillStatus.partial;
        break;
      default:
        status = BillStatus.unpaid;
    }

    final student = json['student'] as Map<String, dynamic>?;
    return BillApi(
      id: json['id'] as int,
      title: json['title'] as String? ?? '-',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      studentId: json['studentId'] as int? ?? 0,
      studentNama: student?['nama'] as String? ?? '-',
      status: status,
      dueDate: json['dueDate'] as String?,
      paidAt: json['paidAt'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case BillStatus.paid:
        return 'Lunas';
      case BillStatus.overdue:
        return 'Terlambat';
      case BillStatus.partial:
        return 'Cicilan';
      case BillStatus.unpaid:
        return 'Belum Bayar';
    }
  }
}

// ──────────────────────────────────────────────
// Service
// ──────────────────────────────────────────────

class BillService {
  final _api = ApiService();

  Future<List<BillApi>> fetchAll({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null && status != 'Semua') params['status'] = status.toUpperCase();

    final response = await _api.dio.get('/bills', queryParameters: params.isNotEmpty ? params : null);
    final raw = response.data;
    final List<dynamic> list =
        (raw['data'] is Map ? raw['data']['data'] : raw['data']) as List? ?? [];
    return list.map((e) => BillApi.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BillApi> create({
    required String title,
    required double amount,
    required int studentId,
    String? dueDate,
  }) async {
    final response = await _api.dio.post('/bills', data: {
      'title': title,
      'amount': amount,
      'studentId': studentId,
      if (dueDate != null) 'dueDate': dueDate,
    });
    return BillApi.fromJson(
        (response.data['data'] ?? response.data) as Map<String, dynamic>);
  }

  Future<void> markPaid(int billId) async {
    await _api.dio.patch('/bills/$billId', data: {'status': 'PAID'});
  }

  Future<void> delete(int billId) async {
    await _api.dio.delete('/bills/$billId');
  }
}
