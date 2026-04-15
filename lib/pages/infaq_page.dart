import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class InfaqPage extends StatefulWidget {
  const InfaqPage({super.key});

  @override
  State<InfaqPage> createState() => _InfaqPageState();
}

class _InfaqPageState extends State<InfaqPage> {
  String _filterJenis = 'Semua';
  final _months = ['Semua', 'April 2026', 'Maret 2026'];
  String _filterBulan = 'Semua';

  String _formatCurrency(double amount) {
    final text = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final pos = text.length - i;
      buf.write(text[i]);
      if (pos > 1 && pos % 3 == 1) buf.write('.');
    }
    return 'Rp ${buf.toString()}';
  }

  List<Infaq> get _filtered {
    return DummyData.infaqList.where((i) {
      final jenisMatch = _filterJenis == 'Semua' ||
          (_filterJenis == 'Wajib' && i.jenis == InfaqJenis.wajib) ||
          (_filterJenis == 'Sukarela' && i.jenis == InfaqJenis.sukarela) ||
          (_filterJenis == 'Program' && i.jenis == InfaqJenis.program);
      return jenisMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalInfaq = DummyData.infaqList.fold(0.0, (s, i) => s + i.jumlah);
    final wajib = DummyData.infaqList
        .where((i) => i.jenis == InfaqJenis.wajib)
        .fold(0.0, (s, i) => s + i.jumlah);
    final sukarela = DummyData.infaqList
        .where((i) => i.jenis == InfaqJenis.sukarela)
        .fold(0.0, (s, i) => s + i.jumlah);
    final program = DummyData.infaqList
        .where((i) => i.jenis == InfaqJenis.program)
        .fold(0.0, (s, i) => s + i.jumlah);

    return Column(
      children: [
        // Header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Donasi & Infaq',
                subtitle: 'Rekap pemasukan infaq santri dan umum',
                action: PrimaryButton(
                  label: 'Catat Infaq',
                  icon: Icons.volunteer_activism_rounded,
                  onPressed: () => _showCatatInfaqDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(totalInfaq, wajib, sukarela, program),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chips
                Row(
                  children: [
                    Wrap(
                      spacing: 8,
                      children: ['Semua', 'Wajib', 'Sukarela', 'Program']
                          .map((f) => _filterChip(
                                f,
                                _filterJenis,
                                (v) => setState(() => _filterJenis = v),
                              ))
                          .toList(),
                    ),
                    const SizedBox(width: 16),
                    const Spacer(),
                    // Month filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterBulan,
                          items: _months
                              .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m,
                                      style: GoogleFonts.outfit(fontSize: 12))))
                              .toList(),
                          onChanged: (v) => setState(() => _filterBulan = v!),
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table
                AdminCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _tableHeader(
                        [
                          'Donatur',
                          'Jenis',
                          'Jumlah',
                          'Tanggal',
                          'Keterangan',
                          'Dicatat Oleh',
                          'Aksi'
                        ],
                        [3, 2, 2, 2, 3, 2, 1],
                      ),
                      if (_filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.inbox_rounded,
                                    size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                Text('Tidak ada data infaq',
                                    style: GoogleFonts.outfit(
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filtered.map((i) => _infaqRow(i)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Ringkasan chart area
                _buildRingkasanCard(totalInfaq, wajib, sukarela, program),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
      double total, double wajib, double sukarela, double program) {
    return Row(
      children: [
        _summaryCard(
            'Total Infaq Bulan Ini',
            _formatCurrency(total),
            AppColors.primary,
            AppColors.primarySurface,
            Icons.volunteer_activism_rounded),
        const SizedBox(width: 12),
        _summaryCard('Infaq Wajib', _formatCurrency(wajib), AppColors.success,
            AppColors.successSurface, Icons.check_circle_outline_rounded),
        const SizedBox(width: 12),
        _summaryCard(
            'Sukarela + Program',
            _formatCurrency(sukarela + program),
            AppColors.secondary,
            AppColors.secondarySurface,
            Icons.favorite_rounded),
      ],
    );
  }

  Widget _summaryCard(
      String label, String val, Color c, Color bg, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(val,
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w700, color: c)),
                  Text(label,
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: c.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infaqRow(Infaq i) {
    Color jc, jbg;
    String jlabel;
    IconData jicon;
    switch (i.jenis) {
      case InfaqJenis.wajib:
        jc = AppColors.success;
        jbg = AppColors.successSurface;
        jlabel = 'Wajib';
        jicon = Icons.verified_rounded;
        break;
      case InfaqJenis.sukarela:
        jc = AppColors.secondary;
        jbg = AppColors.secondarySurface;
        jlabel = 'Sukarela';
        jicon = Icons.favorite_rounded;
        break;
      case InfaqJenis.program:
        jc = AppColors.info;
        jbg = AppColors.infoSurface;
        jlabel = 'Program';
        jicon = Icons.campaign_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: jbg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(jicon, size: 16, color: jc),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(i.dariNama,
                      style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(label: jlabel, color: jc, bgColor: jbg),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(i.jumlah),
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
          Expanded(
              flex: 2,
              child: Text(i.tanggal,
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            flex: 3,
            child: Text(i.keterangan ?? '-',
                style: GoogleFonts.outfit(fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
              flex: 2,
              child: Text(i.dicatatOleh,
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
              onPressed: () {},
              tooltip: 'Hapus',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCard(
      double total, double wajib, double sukarela, double program) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Distribusi Infaq', subtitle: 'Komposisi jenis donasi'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _progressBar('Wajib', wajib, total, AppColors.success),
                    const SizedBox(height: 12),
                    _progressBar(
                        'Sukarela', sukarela, total, AppColors.secondary),
                    const SizedBox(height: 12),
                    _progressBar('Program', program, total, AppColors.info),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Terkumpul',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_formatCurrency(total),
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('April 2026',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar(String label, double amount, double total, Color color) {
    final pct = total == 0 ? 0.0 : (amount / total).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(_formatCurrency(amount),
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _tableHeader(List<String> headers, List<int> flexes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: List.generate(
            headers.length,
            (i) => Expanded(
                  flex: flexes[i],
                  child: Text(headers[i],
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                )),
      ),
    );
  }

  Widget _filterChip(
      String label, String current, void Function(String) onTap) {
    final isSelected = current == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  void _showCatatInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Catat Infaq Baru',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: 'Nama Donatur',
                    labelStyle: GoogleFonts.outfit(fontSize: 13)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'Jenis Infaq',
                    labelStyle: GoogleFonts.outfit(fontSize: 13)),
                items: ['Wajib', 'Sukarela', 'Program']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Keterangan (opsional)',
                    labelStyle: GoogleFonts.outfit(fontSize: 13)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Infaq berhasil dicatat'),
                    backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0),
            child: Text('Simpan',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
