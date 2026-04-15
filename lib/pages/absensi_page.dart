import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/services/student_service.dart';
import '../widgets/common_widgets.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedKelas = 'Semua';
  final _studentService = StudentService();
  List<SiswaApi> _allStudents = [];

  List<String> get _kelasList {
    final list = _allStudents.map((e) => e.kelas).toSet().toList();
    list.sort();
    return ['Semua', ...list];
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final data = await _studentService.fetchAll(isActive: true);
      if (mounted) setState(() => _allStudents = data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Manajemen Absensi',
            subtitle: 'Catat dan pantau kehadiran siswa',
            action: PrimaryButton(
              label: 'Catat Absensi',
              icon: Icons.fact_check_rounded,
              onPressed: () => _showAbsensiForm(),
            ),
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 20),
          _buildAbsensiInfo(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 720;
          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    _buildClassFilter(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildDatePicker()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildClassFilter()),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter Kelas',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _kelasList.contains(_selectedKelas) ? _selectedKelas : _kelasList.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              items: _kelasList.map((k) => DropdownMenuItem(value: k, child: Text(k, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)))).toList(),
              onChanged: (v) { if (v != null) setState(() => _selectedKelas = v); },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiInfo() {
    final siswaTerpilih = _selectedKelas == 'Semua'
        ? _allStudents
        : _allStudents.where((s) => s.kelas == _selectedKelas).toList();

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
              const SizedBox(width: 10),
              Text('Informasi Absensi', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: ${DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate)}',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
                const SizedBox(height: 8),
                Text('Kelas: $_selectedKelas | Total Santri: ${siswaTerpilih.length} orang',
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.info)),
                const SizedBox(height: 12),
                Text(
                  'Sistem fitur Absensi harian belum terhubung ke endpoint API khusus Admin. Gunakan tombol "Catat Absensi" untuk mencatat kehadiran santri.',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_allStudents.isEmpty)
            const Center(child: CircularProgressIndicator())
          else ...[
            Text('Daftar Santri (${siswaTerpilih.length})',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            ...siswaTerpilih.take(10).map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(s.nama.isNotEmpty ? s.nama[0] : '?',
                            style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s.nama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500))),
                      Text('${s.kelas} • ${s.asrama ?? '-'}',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                )),
            if (siswaTerpilih.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('... dan ${siswaTerpilih.length - 10} santri lainnya', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMuted)),
              ),
          ],
        ],
      ),
    );
  }

  void _showAbsensiForm() {
    showDialog(
      context: context,
      builder: (ctx) => FormAbsensiDialog(students: _allStudents),
    );
  }
}

class FormAbsensiDialog extends StatefulWidget {
  final List<SiswaApi> students;
  const FormAbsensiDialog({super.key, required this.students});

  @override
  State<FormAbsensiDialog> createState() => _FormAbsensiDialogState();
}

class _FormAbsensiDialogState extends State<FormAbsensiDialog> {
  String? _selectedKelas;
  final Map<int, String> _absensiData = {};
  final Map<int, String> _keteranganData = {};

  List<String> get _kelasList {
    final list = widget.students.map((e) => e.kelas).toSet().toList();
    list.sort();
    return list;
  }

  List<SiswaApi> get _siswaByKelas {
    return widget.students.where((s) => s.kelas == _selectedKelas && s.isActive).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.students.isNotEmpty) {
      _selectedKelas = widget.students.first.kelas;
      for (var s in widget.students) {
        _absensiData[s.id] = 'H';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Catat Absensi',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                        child: Text(DateFormat('dd MMMM yyyy').format(DateTime.now()),
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih Kelas', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                        child: _kelasList.isEmpty
                            ? const SizedBox(height: 44, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedKelas,
                                  isExpanded: true,
                                  items: _kelasList.map((k) => DropdownMenuItem(value: k, child: Text(k, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)))).toList(),
                                  onChanged: (v) { if (v != null) setState(() => _selectedKelas = v); },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Daftar Siswa', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: _siswaByKelas.isEmpty
                    ? const Center(child: EmptyState(message: 'Pilih kelas terlebih dahulu', icon: Icons.person_off_rounded))
                    : ListView.separated(
                        itemCount: _siswaByKelas.length,
                        separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final s = _siswaByKelas[index];
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(s.nama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600))),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: ['H', 'I', 'S', 'A'].map((code) => _buildRadio(s.id, code)).toList(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Keterangan',
                                      hintStyle: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    style: GoogleFonts.outfit(fontSize: 12),
                                    onChanged: (v) => _keteranganData[s.id] = v,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text('Batal', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Absensi berhasil dicatat'), backgroundColor: AppColors.success),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text('Simpan Absensi', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(int siswaId, String code) {
    Color color;
    switch (code) {
      case 'H': color = AppColors.success; break;
      case 'I': color = AppColors.info; break;
      case 'S': color = AppColors.warning; break;
      case 'A': color = AppColors.error; break;
      default: color = AppColors.textMuted;
    }
    final isSelected = _absensiData[siswaId] == code;
    return GestureDetector(
      onTap: () => setState(() => _absensiData[siswaId] = code),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Center(
          child: Text(code, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? color : AppColors.textMuted)),
        ),
      ),
    );
  }
}
