import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class ManajemenSiswaPage extends StatefulWidget {
  const ManajemenSiswaPage({super.key});

  @override
  State<ManajemenSiswaPage> createState() => _ManajemenSiswaPageState();
}

class _ManajemenSiswaPageState extends State<ManajemenSiswaPage> {
  String _search = '';
  String _filterStatus = 'Semua';
  Siswa? _selectedSiswa;

  List<Siswa> get _filtered {
    var list = DummyData.siswaList.where((s) {
      final matchSearch = s.nama.toLowerCase().contains(_search.toLowerCase()) ||
          s.nis.contains(_search);
      final matchStatus = _filterStatus == 'Semua' ||
          (_filterStatus == 'Aktif' && s.aktif) ||
          (_filterStatus == 'Non-Aktif' && !s.aktif);
      return matchSearch && matchStatus;
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List panel
        Expanded(
          flex: _selectedSiswa != null ? 2 : 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Manajemen Siswa',
                  subtitle: '${DummyData.siswaList.length} siswa terdaftar',
                  action: PrimaryButton(
                    label: 'Tambah Siswa',
                    icon: Icons.person_add_rounded,
                    onPressed: () => _showAddDialog(context),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilters(),
                const SizedBox(height: 16),
                _buildTable(),
              ],
            ),
          ),
        ),
        // Detail panel
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
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS...',
                hintStyle: GoogleFonts.outfit(
                    fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 18, color: AppColors.textMuted),
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
      onTap: () => setState(() => _filterStatus = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
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
          // Header
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
                _tableHeader('Kamar', flex: 2),
                _tableHeader('Status', flex: 1),
                _tableHeader('Aksi', flex: 1),
              ],
            ),
          ),
          ..._filtered.map((s) => _tableRow(s)),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: EmptyState(
                  message: 'Tidak ada siswa ditemukan',
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

  Widget _tableRow(Siswa s) {
    final isSelected = _selectedSiswa?.id == s.id;
    return GestureDetector(
      onTap: () => setState(() =>
          _selectedSiswa = isSelected ? null : s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : Colors.transparent,
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
                    backgroundColor: s.jenisKelamin == 'L'
                        ? AppColors.primarySurface
                        : AppColors.secondarySurface,
                    child: Text(
                      s.nama[0],
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: s.jenisKelamin == 'L'
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.nama,
                            style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        Text(s.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
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
                child: Text(s.kelas,
                    style: GoogleFonts.outfit(fontSize: 12))),
            Expanded(
                flex: 2,
                child: Text(s.kamar,
                    style: GoogleFonts.outfit(fontSize: 12))),
            Expanded(
              flex: 1,
              child: StatusBadge(
                label: s.aktif ? 'Aktif' : 'Non-Aktif',
                color: s.aktif ? AppColors.success : AppColors.textMuted,
                bgColor: s.aktif ? AppColors.successSurface : AppColors.surfaceVariant,
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
                    icon: const Icon(Icons.delete_rounded, size: 16),
                    color: AppColors.error,
                    onPressed: () => _showDeleteDialog(context, s),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(Siswa s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Detail Siswa',
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
                // Avatar large
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: s.jenisKelamin == 'L'
                          ? [AppColors.primary, AppColors.primaryLight]
                          : [AppColors.secondary, AppColors.secondaryLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(s.nama[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
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
                  label: s.aktif ? 'Aktif' : 'Non-Aktif',
                  color: s.aktif ? AppColors.success : AppColors.textMuted,
                  bgColor: s.aktif ? AppColors.successSurface : AppColors.surfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AdminCard(
            child: Column(
              children: [
                _detailRow(Icons.school_rounded, 'Kelas', s.kelas),
                _detailRow(Icons.bed_rounded, 'Kamar', s.kamar),
                _detailRow(Icons.calendar_today_rounded, 'Tgl Masuk', s.tanggalMasuk),
                _detailRow(Icons.location_on_rounded, 'Alamat', s.alamat),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Informasi Wali',
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AdminCard(
            child: Column(
              children: [
                _detailRow(Icons.person_rounded, 'Nama Wali', s.namaWali),
                _detailRow(Icons.phone_rounded, 'No. HP', s.noHpWali),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showEditDialog(context, s),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text('Edit Data Siswa',
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

  void _showAddDialog(BuildContext context) {
    _showSiswaDialog(context, null);
  }

  void _showEditDialog(BuildContext context, Siswa s) {
    _showSiswaDialog(context, s);
  }

  void _showSiswaDialog(BuildContext context, Siswa? s) {
    final namaCtrl = TextEditingController(text: s?.nama ?? '');
    final nisCtrl = TextEditingController(text: s?.nis ?? '');
    final kelasCtrl = TextEditingController(text: s?.kelas ?? '');
    final kamarCtrl = TextEditingController(text: s?.kamar ?? '');
    final waliCtrl = TextEditingController(text: s?.namaWali ?? '');
    final hpCtrl = TextEditingController(text: s?.noHpWali ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s == null ? 'Tambah Siswa Baru' : 'Edit Data Siswa',
                  style: GoogleFonts.outfit(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _dialogField('Nama Lengkap', namaCtrl,
                  Icons.person_rounded, 'Masukkan nama siswa'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dialogField('NIS', nisCtrl,
                        Icons.badge_rounded, 'Nomor Induk Santri'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dialogField('Kelas', kelasCtrl,
                        Icons.school_rounded, 'Contoh: Kelas 1 Ula'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _dialogField('Kamar', kamarCtrl,
                  Icons.bed_rounded, 'Nomor kamar'),
              const SizedBox(height: 12),
              _dialogField('Nama Wali', waliCtrl,
                  Icons.family_restroom_rounded, 'Nama orang tua/wali'),
              const SizedBox(height: 12),
              _dialogField('No. HP Wali', hpCtrl,
                  Icons.phone_rounded, 'Nomor WhatsApp wali'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Batal',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s == null
                                ? 'Siswa baru berhasil ditambahkan'
                                : 'Data siswa berhasil diperbarui'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(s == null ? 'Tambahkan' : 'Simpan',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(
      String label, TextEditingController ctrl, IconData icon, String hint) {
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
            hintStyle:
                GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
          ),
          style: GoogleFonts.outfit(fontSize: 13),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Siswa s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Data Siswa',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "${s.nama}"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data siswa berhasil dihapus'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Hapus',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
