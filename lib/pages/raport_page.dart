import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class RaportPage extends StatefulWidget {
  const RaportPage({super.key});

  @override
  State<RaportPage> createState() => _RaportPageState();
}

class _RaportPageState extends State<RaportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterSemester = 'Semua';
  Raport? _selectedRaport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Raport & Penilaian',
                subtitle: 'Manajemen nilai akademik santri per semester',
                action: PrimaryButton(
                  label: 'Input Nilai',
                  icon: Icons.add_rounded,
                  onPressed: () => _showInputNilaiDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              // Summary row
              _buildSummaryRow(),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Daftar Raport'),
                  Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Rekap Prestasi'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDaftarRaport(),
              _buildRekapPrestasi(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final total = DummyData.raportList.length;
    final published = DummyData.raportList.where((r) => r.published).length;
    final draft = total - published;

    return Row(
      children: [
        _statCard('Total Raport', '$total', AppColors.primary, AppColors.primarySurface, Icons.school_rounded),
        const SizedBox(width: 12),
        _statCard('Dipublikasikan', '$published', AppColors.success, AppColors.successSurface, Icons.check_circle_rounded),
        const SizedBox(width: 12),
        _statCard('Draft', '$draft', AppColors.warning, AppColors.warningSurface, Icons.edit_note_rounded),
      ],
    );
  }

  Widget _statCard(String label, String val, Color c, Color bg, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: c)),
                Text(label, style: GoogleFonts.outfit(fontSize: 11, color: c.withOpacity(0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 1: Daftar Raport ───
  Widget _buildDaftarRaport() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isWide && _selectedRaport != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRaportList()),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: _buildRaportDetail(_selectedRaport!)),
                ],
              )
            : Column(
                children: [
                  _buildRaportList(),
                  if (_selectedRaport != null) ...[
                    const SizedBox(height: 20),
                    _buildRaportDetail(_selectedRaport!),
                  ],
                ],
              ),
      );
    });
  }

  Widget _buildRaportList() {
    // Filter chips
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['Semua', 'Genap 2025/2026', 'Ganjil 2025/2026']
              .map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _filterChip(f),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),

        AdminCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _tableHeader(['Santri', 'Kelas', 'Semester', 'Rata-rata', 'Status', 'Aksi'],
                  [3, 2, 2, 2, 2, 2]),
              ...DummyData.raportList.map((r) => _raportRow(r)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _raportRow(Raport r) {
    final rata = r.rataRata;
    Color gradeColor;
    String gradeLabel;
    if (rata >= 85) { gradeColor = AppColors.success; gradeLabel = 'A'; }
    else if (rata >= 75) { gradeColor = AppColors.info; gradeLabel = 'B'; }
    else if (rata >= 65) { gradeColor = AppColors.warning; gradeLabel = 'C'; }
    else { gradeColor = AppColors.error; gradeLabel = 'D'; }

    final isSelected = _selectedRaport?.id == r.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedRaport = isSelected ? null : r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : null,
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
                    child: Text(r.siswaNama[0],
                        style: GoogleFonts.outfit(
                            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(r.siswaNama,
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(r.kelas, style: GoogleFonts.outfit(fontSize: 12))),
            Expanded(flex: 2, child: Text('${r.semester} ${r.tahunAjaran}', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary))),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('$gradeLabel  ${rata.toStringAsFixed(1)}',
                        style: GoogleFonts.outfit(
                            fontSize: 12, fontWeight: FontWeight.w700, color: gradeColor)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: StatusBadge(
                label: r.published ? 'Published' : 'Draft',
                color: r.published ? AppColors.success : AppColors.warning,
                bgColor: r.published ? AppColors.successSurface : AppColors.warningSurface,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility_rounded, size: 16,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary),
                    onPressed: () => setState(() => _selectedRaport = isSelected ? null : r),
                    tooltip: 'Lihat Detail',
                  ),
                  IconButton(
                    icon: Icon(
                      r.published ? Icons.unpublished_rounded : Icons.publish_rounded,
                      size: 16, color: r.published ? AppColors.warning : AppColors.success,
                    ),
                    onPressed: () {},
                    tooltip: r.published ? 'Batalkan Publikasi' : 'Publikasikan',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaportDetail(Raport r) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detail Raport', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${r.siswaNama} · ${r.kelas} · ${r.semester} ${r.tahunAjaran}',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedRaport = null),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          // Nilai table
          Row(
            children: [
              _th2('Mata Pelajaran', 3),
              _th2('Harian', 1),
              _th2('UTS', 1),
              _th2('UAS', 1),
              _th2('Akhir', 1),
              _th2('Grade', 1),
            ],
          ),
          const SizedBox(height: 8),
          ...r.mapelList.map((m) {
            Color gc;
            if (m.nilaiAkhir >= 85) {
              gc = AppColors.success;
            } else if (m.nilaiAkhir >= 75) {
              gc = AppColors.info;
            } else if (m.nilaiAkhir >= 65) {
              gc = AppColors.warning;
            } else {
              gc = AppColors.error;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(m.mataPelajaran, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500))),
                  Expanded(flex: 1, child: Text('${m.nilaiHarian}', style: GoogleFonts.outfit(fontSize: 12))),
                  Expanded(flex: 1, child: Text('${m.nilaiUTS}', style: GoogleFonts.outfit(fontSize: 12))),
                  Expanded(flex: 1, child: Text('${m.nilaiUAS}', style: GoogleFonts.outfit(fontSize: 12))),
                  Expanded(
                    flex: 1,
                    child: Text('${m.nilaiAkhir}',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: gc)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: gc.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        m.nilaiAkhir >= 85 ? 'A' : m.nilaiAkhir >= 75 ? 'B' : m.nilaiAkhir >= 65 ? 'C' : 'D',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: gc),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: AppColors.border, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rata-rata Keseluruhan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(r.rataRata.toStringAsFixed(2),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          if (r.catatanWaliKelas != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catatan Wali Kelas', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(r.catatanWaliKelas!, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _th2(String t, int flex) => Expanded(
        flex: flex,
        child: Text(t, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      );

  // ─── Tab 2: Rekap Prestasi ───
  Widget _buildRekapPrestasi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Rekap Prestasi Akademik',
            subtitle: 'Semester Genap 2025/2026',
          ),
          const SizedBox(height: 16),
          AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tableHeader(['Peringkat', 'Santri', 'Kelas', 'Rata-rata', 'Grade', 'Status Raport'], [1, 3, 2, 2, 1, 2]),
                ...() {
                  final sorted = DummyData.raportList.toList()
                    ..sort((a, b) => b.rataRata.compareTo(a.rataRata));
                  return sorted.asMap().entries.map((e) => _rankRow(e.key + 1, e.value)).toList();
                }(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankRow(int rank, Raport r) {
    final rata = r.rataRata;
    Color gc = rata >= 85 ? AppColors.success : rata >= 75 ? AppColors.info : AppColors.warning;
    String grade = rata >= 85 ? 'A' : rata >= 75 ? 'B' : 'C';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: rank == 1 ? AppColors.secondary : rank == 2 ? AppColors.textSecondary.withOpacity(0.3) : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$rank',
                    style: GoogleFonts.outfit(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: rank <= 2 ? Colors.white : AppColors.textPrimary)),
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(r.siswaNama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(r.kelas, style: GoogleFonts.outfit(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Text(rata.toStringAsFixed(2),
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: gc)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: gc.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(grade, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: gc)),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(
              label: r.published ? 'Published' : 'Draft',
              color: r.published ? AppColors.success : AppColors.warning,
              bgColor: r.published ? AppColors.successSurface : AppColors.warningSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(List<String> headers, List<int> flexes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: List.generate(headers.length, (i) => Expanded(
          flex: flexes[i],
          child: Text(headers[i], style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        )),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterSemester == label;
    return GestureDetector(
      onTap: () => setState(() => _filterSemester = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  void _showInputNilaiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Input Nilai Raport', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Pilih Santri', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                items: DummyData.siswaList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nama))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Semester', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                      items: ['Ganjil', 'Genap'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Tahun Ajaran', hintText: '2025/2026', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(labelText: 'Catatan Wali Kelas', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Raport berhasil disimpan'), backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
            child: Text('Simpan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
