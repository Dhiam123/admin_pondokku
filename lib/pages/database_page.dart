import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Database Akademik',
                subtitle: 'Siswa, guru, absensi, dan nilai tersimpan',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _summaryCard('Siswa', DummyData.siswaList.length, Icons.school),
                  _summaryCard('Guru', DummyData.guruList.length, Icons.person_rounded),
                  _summaryCard('Absensi', DummyData.absensiList.length, Icons.fact_check_rounded),
                  _summaryCard('Nilai', DummyData.nilaiList.length, Icons.menu_book_rounded),
                ],
              ),
              const SizedBox(height: 24),
              AdminCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w400),
                      tabs: const [
                        Tab(text: 'Siswa'),
                        Tab(text: 'Guru'),
                        Tab(text: 'Absensi'),
                        Tab(text: 'Nilai'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: isMobile ? 820 : 620,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSiswaTable(isMobile: isMobile),
                          _buildGuruTable(isMobile: isMobile),
                          _buildAbsensiTable(isMobile: isMobile),
                          _buildNilaiTable(isMobile: isMobile),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSiswaTable({required bool isMobile}) {
    return _buildTable(
      columns: ['Nama', 'NIS', 'Kelas', 'Wali'],
      rows: DummyData.siswaList.map((s) => [
            s.nama,
            s.nis,
            s.kelas,
            s.namaWali,
          ]).toList(),
      isMobile: isMobile,
    );
  }

  Widget _buildGuruTable({required bool isMobile}) {
    return _buildTable(
      columns: ['Nama', 'Mapel', 'Email', 'Status'],
      rows: DummyData.guruList.map((g) => [
            g.nama,
            g.mataPelajaran,
            g.email,
            g.aktif ? 'Aktif' : 'Tidak aktif',
          ]).toList(),
      isMobile: isMobile,
    );
  }

  Widget _buildAbsensiTable({required bool isMobile}) {
    return _buildTable(
      columns: ['Nama', 'Kelas', 'Status', 'Keterangan'],
      rows: DummyData.absensiList.map((a) => [
            a.siswaNama,
            a.kelas,
            _absensiLabel(a.status),
            a.keterangan ?? '-',
          ]).toList(),
      isMobile: isMobile,
    );
  }

  Widget _buildNilaiTable({required bool isMobile}) {
    return _buildTable(
      columns: ['Nama', 'Mapel', 'Nilai', 'Semester'],
      rows: DummyData.nilaiList.map((n) => [
            n.siswaNama,
            n.mataPelajaran,
            n.nilai.toString(),
            n.semester,
          ]).toList(),
      isMobile: isMobile,
    );
  }

  String _absensiLabel(AbsensiStatus status) {
    switch (status) {
      case AbsensiStatus.hadir:
        return 'Hadir';
      case AbsensiStatus.izin:
        return 'Izin';
      case AbsensiStatus.sakit:
        return 'Sakit';
      case AbsensiStatus.alpha:
        return 'Alpha';
    }
  }

  Widget _buildMobileCard(List<String> columns, List<String> rowData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < columns.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(columns[i],
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Text(rowData[i],
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, int count, IconData icon) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text('$count',
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable({
    required List<String> columns,
    required List<List<String>> rows,
    required bool isMobile,
  }) {
    if (isMobile) {
      return SingleChildScrollView(
        child: Column(
          children: rows
              .map((rowData) => _buildMobileCard(columns, rowData))
              .toList(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: columns.length * 160.0),
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                headingTextStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                dataTextStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                columns: columns
                    .map((label) => DataColumn(label: Text(label)))
                    .toList(),
                rows: rows
                    .map(
                      (cells) => DataRow(
                        cells: cells
                            .map((value) => DataCell(Text(value)))
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Tidak ada data',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }
}
