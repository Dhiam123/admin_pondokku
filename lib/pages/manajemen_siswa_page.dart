import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/services/student_service.dart';
import '../widgets/common_widgets.dart';
import 'package:dio/dio.dart';

class ManajemenSiswaPage extends StatefulWidget {
  const ManajemenSiswaPage({super.key});

  @override
  State<ManajemenSiswaPage> createState() => _ManajemenSiswaPageState();
}

class _ManajemenSiswaPageState extends State<ManajemenSiswaPage> {
  final _service = StudentService();
  final _searchCtrl = TextEditingController();

  List<SiswaApi> _siswaList = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'Semua';
  SiswaApi? _selectedSiswa;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      bool? isActiveFilter;
      if (_filterStatus == 'Aktif') isActiveFilter = true;
      if (_filterStatus == 'Non-Aktif') isActiveFilter = false;

      final data = await _service.fetchAll(
        search: _searchCtrl.text.trim(),
        isActive: isActiveFilter,
      );
      if (mounted) setState(() => _siswaList = data);
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _error =
            'Gagal memuat data: ${e.response?.data['message'] ?? e.message}');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Terjadi kesalahan tidak terduga.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: _selectedSiswa != null ? 2 : 1,
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Manajemen Siswa',
                    subtitle: _isLoading
                        ? 'Memuat data...'
                        : '${_siswaList.length} santri terdaftar',
                    action: PrimaryButton(
                      label: 'Tambah Siswa',
                      icon: Icons.person_add_rounded,
                      onPressed: () => _showAddDialog(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 16),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
        if (_selectedSiswa != null) ...[
          Container(width: 1, color: AppColors.border),
          Expanded(
            flex: 1,
            child: _buildDetailPanel(_selectedSiswa!),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: AppColors.error)),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Coba Lagi', icon: Icons.refresh_rounded, onPressed: _loadData),
            ],
          ),
        ),
      );
    }
    return _buildTable();
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _loadData(),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS... (Enter untuk cari)',
                hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: AppColors.textMuted,
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadData();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: false,
              ),
              style: GoogleFonts.outfit(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ...['Semua', 'Aktif', 'Non-Aktif'].map((f) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _filterChip(f),
            )),
      ],
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label;
          _selectedSiswa = null;
        });
        _loadData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return AdminCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _tableHeader('Nama Siswa', flex: 3),
                _tableHeader('NIS', flex: 2),
                _tableHeader('Kelas', flex: 2),
                _tableHeader('Asrama', flex: 2),
                _tableHeader('Status', flex: 1),
                _tableHeader('Aksi', flex: 1),
              ],
            ),
          ),
          ..._siswaList.map((s) => _tableRow(s)),
          if (_siswaList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: EmptyState(
                  message: 'Tidak ada santri ditemukan',
                  icon: Icons.people_outline_rounded),
            ),
        ],
      ),
    );
  }

  Widget _tableHeader(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.3)),
    );
  }

  Widget _tableRow(SiswaApi s) {
    final isSelected = _selectedSiswa?.id == s.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSiswa = isSelected ? null : s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      s.nama.isNotEmpty ? s.nama[0] : '?',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.nama,
                        style: GoogleFonts.outfit(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Text(s.nis,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppColors.textSecondary))),
            Expanded(
                flex: 2,
                child: Text(s.kelas, style: GoogleFonts.outfit(fontSize: 12))),
            Expanded(
                flex: 2,
                child: Text(s.asrama ?? '-',
                    style: GoogleFonts.outfit(fontSize: 12))),
            Expanded(
              flex: 1,
              child: StatusBadge(
                label: s.isActive ? 'Aktif' : 'Non-Aktif',
                color: s.isActive ? AppColors.success : AppColors.textMuted,
                bgColor: s.isActive ? AppColors.successSurface : AppColors.surfaceVariant,
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    color: AppColors.textSecondary,
                    onPressed: () => _showEditDialog(context, s),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: Icon(
                      s.isActive ? Icons.person_off_rounded : Icons.person_rounded,
                      size: 16,
                    ),
                    color: s.isActive ? AppColors.warning : AppColors.success,
                    onPressed: () => _toggleStatus(s),
                    tooltip: s.isActive ? 'Nonaktifkan' : 'Aktifkan',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(SiswaApi s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Detail Santri',
                  style: GoogleFonts.outfit(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedSiswa = null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminCard(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      s.nama.isNotEmpty ? s.nama[0] : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(s.nama,
                    style: GoogleFonts.outfit(
                        fontSize: 17, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                Text('NIS: ${s.nis}',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                StatusBadge(
                  label: s.isActive ? 'Aktif' : 'Non-Aktif',
                  color: s.isActive ? AppColors.success : AppColors.textMuted,
                  bgColor: s.isActive ? AppColors.successSurface : AppColors.surfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AdminCard(
            child: Column(
              children: [
                _detailRow(Icons.school_rounded, 'Kelas', s.kelas),
                _detailRow(Icons.bed_rounded, 'Asrama', s.asrama ?? '-'),
                _detailRow(Icons.calendar_today_rounded, 'Terdaftar',
                    s.createdAt != null
                        ? '${s.createdAt!.day}/${s.createdAt!.month}/${s.createdAt!.year}'
                        : '-'),
              ],
            ),
          ),
          if (s.namaWali != null) ...[
            const SizedBox(height: 16),
            Text('Informasi Wali',
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            AdminCard(
              child: _detailRow(
                  Icons.person_rounded, 'Akun Wali', s.namaWali!),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditDialog(context, s),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text('Edit Data Santri',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(SiswaApi s) async {
    try {
      if (s.isActive) {
        await _service.deactivate(s.id);
      } else {
        await _service.activate(s.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              s.isActive ? 'Santri berhasil dinonaktifkan' : 'Santri berhasil diaktifkan'),
          backgroundColor: s.isActive ? AppColors.warning : AppColors.success,
        ));
        setState(() => _selectedSiswa = null);
        _loadData();
      }
    } on DioException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal mengubah status santri'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  void _showAddDialog(BuildContext context) => _showSiswaDialog(context, null);
  void _showEditDialog(BuildContext context, SiswaApi s) => _showSiswaDialog(context, s);

  void _showSiswaDialog(BuildContext context, SiswaApi? s) {
    final namaCtrl = TextEditingController(text: s?.nama ?? '');
    final nisCtrl = TextEditingController(text: s?.nis ?? '');
    final kelasCtrl = TextEditingController(text: s?.kelas ?? '');
    final asramaCtrl = TextEditingController(text: s?.asrama ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s == null ? 'Tambah Santri Baru' : 'Edit Data Santri',
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _dialogField('Nama Lengkap', namaCtrl, Icons.person_rounded, 'Masukkan nama santri'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _dialogField('NIS', nisCtrl, Icons.badge_rounded, 'Nomor Induk Santri')),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogField('Kelas', kelasCtrl, Icons.school_rounded, 'Contoh: X IPA 1')),
                  ],
                ),
                const SizedBox(height: 12),
                _dialogField('Asrama', asramaCtrl, Icons.bed_rounded, 'Nama asrama (opsional)'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Batal', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setDialogState(() => isSaving = true);
                                try {
                                  if (s == null) {
                                    await _service.create(
                                      nis: nisCtrl.text,
                                      nama: namaCtrl.text,
                                      kelas: kelasCtrl.text,
                                      asrama: asramaCtrl.text,
                                    );
                                  } else {
                                    await _service.update(s.id, {
                                      'nis': nisCtrl.text,
                                      'nama': namaCtrl.text,
                                      'kelas': kelasCtrl.text,
                                      'asrama': asramaCtrl.text,
                                    });
                                  }
                                   if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(s == null
                                          ? 'Santri baru berhasil ditambahkan'
                                          : 'Data santri berhasil diperbarui'),
                                      backgroundColor: AppColors.success,
                                    ));
                                    setState(() => _selectedSiswa = null);
                                    _loadData();
                                  }
                                } on DioException catch (e) {
                                  setDialogState(() => isSaving = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                      content: Text(
                                          'Gagal: ${e.response?.data['message'] ?? 'Cek koneksi'}'),
                                      backgroundColor: AppColors.error,
                                    ));
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(s == null ? 'Tambahkan' : 'Simpan',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
            hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
          ),
          style: GoogleFonts.outfit(fontSize: 13),
        ),
      ],
    );
  }
}
