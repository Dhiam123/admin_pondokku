import '../network/api_service.dart';

// ──────────────────────────────────────────────
// Model yang menyesuaikan response JSON backend
// ──────────────────────────────────────────────

class SiswaApi {
  final int id;
  final String nis;
  final String nama;
  final String kelas;
  final String? asrama;
  final bool isActive;
  final int? waliId;
  final String? namaWali;
  final String? noHpWali;
  final DateTime? createdAt;

  SiswaApi({
    required this.id,
    required this.nis,
    required this.nama,
    required this.kelas,
    this.asrama,
    required this.isActive,
    this.waliId,
    this.namaWali,
    this.noHpWali,
    this.createdAt,
  });

  factory SiswaApi.fromJson(Map<String, dynamic> json) {
    final wali = json['wali'] as Map<String, dynamic>?;
    return SiswaApi(
      id: json['id'] as int,
      nis: json['nis'] as String,
      nama: json['nama'] as String,
      kelas: json['kelas'] as String,
      asrama: json['asrama'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      waliId: json['waliId'] as int?,
      namaWali: wali?['username'] as String?,
      noHpWali: null, // backend belum expose noHp di endpoint ini
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

// ──────────────────────────────────────────────
// Service layer untuk semua request /students
// ──────────────────────────────────────────────

class StudentService {
  final _api = ApiService();

  /// Ambil semua santri (Admin). Support filter search & status.
  Future<List<SiswaApi>> fetchAll({String? search, bool? isActive}) async {
    final Map<String, dynamic> params = {};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (isActive != null) params['isActive'] = isActive;

    final response = await _api.dio.get(
      '/students',
      queryParameters: params.isNotEmpty ? params : null,
    );

    // Backend membungkus dengan format { success, statusCode, data: { data: [...] } }
    final raw = response.data;
    final List<dynamic> list =
        (raw['data'] is Map ? raw['data']['data'] : raw['data']) as List? ?? [];
    return list
        .map((e) => SiswaApi.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah santri baru
  Future<SiswaApi> create({
    required String nis,
    required String nama,
    required String kelas,
    String? asrama,
    int? waliId,
  }) async {
    final response = await _api.dio.post('/students', data: {
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      if (asrama != null && asrama.isNotEmpty) 'asrama': asrama,
      if (waliId != null) 'waliId': waliId,
    });
    return SiswaApi.fromJson(
        (response.data['data'] ?? response.data) as Map<String, dynamic>);
  }

  /// Update data santri
  Future<SiswaApi> update(int id, Map<String, dynamic> data) async {
    final response = await _api.dio.patch('/students/$id', data: data);
    return SiswaApi.fromJson(
        (response.data['data'] ?? response.data) as Map<String, dynamic>);
  }

  /// Nonaktifkan santri
  Future<void> deactivate(int id) async {
    await _api.dio.patch('/students/$id/deactivate');
  }

  /// Aktifkan kembali santri
  Future<void> activate(int id) async {
    await _api.dio.patch('/students/$id/activate');
  }

  /// Hapus santri
  Future<void> delete(int id) async {
    await _api.dio.delete('/students/$id');
  }
}
