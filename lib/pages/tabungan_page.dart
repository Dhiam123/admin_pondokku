import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final totalSaldo = DummyData.tabunganSiswaList.fold(0.0, (s, t) => s + t.saldo);
    final pendingTopup = DummyData.mutasiList.where((m) => m.status == TopupStatus.menunggu).length;

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
                title: 'Tabungan & Top-Up',
                subtitle: 'Kelola saldo tabungan santri dan verifikasi top-up',
                action: PrimaryButton(
                  label: 'Input Manual',
                  icon: Icons.add_rounded,
                  onPressed: () => _showInputManualDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(totalSaldo, pendingTopup),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                tabs: [
                  const Tab(icon: Icon(Icons.savings_rounded, size: 18), text: 'Saldo Santri'),
                  Tab(
                    icon: Stack(
                      children: [
                        const Icon(Icons.pending_actions_rounded, size: 18),
                        if (pendingTopup > 0)
                          Positioned(
                            right: -2, top: -2,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    text: 'Verifikasi Top-Up ($pendingTopup)',
                  ),
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
              _buildSaldoSantri(),
              _buildVerifikasiTopup(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(double totalSaldo, int pending) {
    return Row(
      children: [
        _summaryCard('Total Saldo Tabungan', _formatCurrency(totalSaldo), AppColors.primary, AppColors.primarySurface, Icons.account_balance_wallet_rounded),
        const SizedBox(width: 12),
        _summaryCard('Santri Menabung', '${DummyData.tabunganSiswaList.length}', AppColors.info, AppColors.infoSurface, Icons.people_rounded),
        const SizedBox(width: 12),
        _summaryCard('Menunggu Verifikasi', '$pending', pending > 0 ? AppColors.warning : AppColors.success,
            pending > 0 ? AppColors.warningSurface : AppColors.successSurface, Icons.pending_rounded),
      ],
    );
  }

  Widget _summaryCard(String label, String val, Color c, Color bg, IconData icon) {
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
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(val, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c)),
                  Text(label, style: GoogleFonts.outfit(fontSize: 11, color: c.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 1: Saldo Santri ───
  Widget _buildSaldoSantri() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AdminCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _tableHeader(['Santri', 'Kelas', 'Saldo', 'Terakhir Diperbarui', 'Aksi'], [3, 2, 2, 2, 2]),
            ...DummyData.tabunganSiswaList.map((t) => _saldoRow(t)),
          ],
        ),
      ),
    );
  }

  Widget _saldoRow(TabunganSiswa t) {
    final isLow = t.saldo < 100000;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isLow ? AppColors.warningSurface : null,
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
                  child: Text(t.siswaNama[0],
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(t.siswaNama,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(t.kelas, style: GoogleFonts.outfit(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(_formatCurrency(t.saldo),
                    style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: isLow ? AppColors.warning : AppColors.primary)),
                if (isLow) ...[
                  const SizedBox(width: 6),
                  const Tooltip(
                    message: 'Saldo rendah!',
                    child: Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(t.lastUpdate,
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showMutasiDialog(context, t),
                  icon: const Icon(Icons.history_rounded, size: 14),
                  label: Text('Mutasi', style: GoogleFonts.outfit(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: Verifikasi Top-Up ───
  Widget _buildVerifikasiTopup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: SectionHeader(
                    title: 'Permintaan Top-Up & Penarikan',
                    subtitle: 'Setujui atau tolak permintaan santri',
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                _tableHeader(['Santri', 'Tipe', 'Jumlah', 'Tanggal', 'Keterangan', 'Status', 'Aksi'],
                    [2, 1, 2, 2, 3, 2, 2]),
                ...DummyData.mutasiList.map((m) => _mutasiRow(m)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mutasiRow(MutasiTabungan m) {
    Color sc, sbg;
    String sl;
    switch (m.status) {
      case TopupStatus.menunggu:
        sc = AppColors.warning; sbg = AppColors.warningSurface; sl = 'Menunggu';
        break;
      case TopupStatus.disetujui:
        sc = AppColors.success; sbg = AppColors.successSurface; sl = 'Disetujui';
        break;
      case TopupStatus.ditolak:
        sc = AppColors.error; sbg = AppColors.errorSurface; sl = 'Ditolak';
        break;
    }

    final isTopup = m.tipe == 'topup';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: m.status == TopupStatus.menunggu ? AppColors.warningSurface.withValues(alpha: 0.4) : null,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(m.siswaNama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isTopup ? AppColors.successSurface : AppColors.infoSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(isTopup ? '↑ Top-Up' : '↓ Tarik',
                  style: GoogleFonts.outfit(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: isTopup ? AppColors.success : AppColors.info)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(m.jumlah),
              style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isTopup ? AppColors.success : AppColors.info),
            ),
          ),
          Expanded(flex: 2, child: Text(m.tanggal, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            flex: 3,
            child: Text(m.keterangan ?? '-',
                style: GoogleFonts.outfit(fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(flex: 2, child: StatusBadge(label: sl, color: sc, bgColor: sbg)),
          Expanded(
            flex: 2,
            child: m.status == TopupStatus.menunggu
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        onPressed: () => _showVerifikasiDialog(context, m, true),
                        tooltip: 'Setujui',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                        onPressed: () => _showVerifikasiDialog(context, m, false),
                        tooltip: 'Tolak',
                      ),
                    ],
                  )
                : const Icon(Icons.remove, color: AppColors.textMuted, size: 16),
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

  void _showMutasiDialog(BuildContext context, TabunganSiswa t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Riwayat Mutasi – ${t.siswaNama}', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Saldo Saat Ini', style: GoogleFonts.outfit(fontSize: 12)),
                    Text(_formatCurrency(t.saldo),
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
              ...DummyData.mutasiList
                  .where((m) => m.siswaId == t.siswaId)
                  .map((m) => _mutasiHistoryItem(m)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _mutasiHistoryItem(MutasiTabungan m) {
    final isTopup = m.tipe == 'topup';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isTopup ? AppColors.successSurface : AppColors.infoSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isTopup ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isTopup ? AppColors.success : AppColors.info, size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isTopup ? 'Top-Up Saldo' : 'Penarikan Saldo',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(m.keterangan ?? '-', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                Text(m.tanggal, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${isTopup ? '+' : '-'} ${_formatCurrency(m.jumlah)}',
            style: GoogleFonts.outfit(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isTopup ? AppColors.success : AppColors.info),
          ),
        ],
      ),
    );
  }

  void _showVerifikasiDialog(BuildContext context, MutasiTabungan m, bool approve) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(approve ? '✅ Setujui Top-Up' : '❌ Tolak Top-Up',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          approve
              ? 'Setujui ${m.tipe} sebesar ${_formatCurrency(m.jumlah)} dari ${m.siswaNama}?'
              : 'Tolak permintaan ${m.tipe} dari ${m.siswaNama}? Berikan alasan penolakan.',
          style: GoogleFonts.outfit(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(approve ? 'Top-Up berhasil disetujui!' : 'Top-Up ditolak.'),
                  backgroundColor: approve ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white, elevation: 0,
            ),
            child: Text(approve ? 'Setujui' : 'Tolak', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showInputManualDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Input Mutasi Manual', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Santri', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                items: DummyData.siswaList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nama))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Tipe', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                items: ['Top-Up', 'Penarikan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                decoration: InputDecoration(labelText: 'Keterangan', labelStyle: GoogleFonts.outfit(fontSize: 13)),
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
                const SnackBar(content: Text('Mutasi berhasil dicatat'), backgroundColor: AppColors.success),
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
