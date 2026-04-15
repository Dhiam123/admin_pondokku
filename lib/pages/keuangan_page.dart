import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with tabs
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Manajemen Keuangan',
                subtitle: 'Tagihan, riwayat pembayaran & pengaturan biaya',
                action: PrimaryButton(
                  label: 'Buat Tagihan',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () => _showBuatTagihanDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildBalanceRow(),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400),
                tabs: const [
                  Tab(icon: Icon(Icons.receipt_rounded, size: 18), text: 'Daftar Tagihan'),
                  Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'Riwayat Pembayaran'),
                  Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Atur Biaya'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDaftarTagihan(),
              _buildRiwayatPembayaran(),
              _buildAturBiaya(),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────── Tab 1: Daftar Tagihan ───────────────────
  Widget _buildDaftarTagihan() {
    final filtered = _filterStatus == 'Semua'
        ? DummyData.tagihanList
        : DummyData.tagihanList.where((t) {
            switch (_filterStatus) {
              case 'Lunas':
                return t.status == PaymentStatus.lunas;
              case 'Belum Bayar':
                return t.status == PaymentStatus.belumBayar;
              case 'Terlambat':
                return t.status == PaymentStatus.terlambat;
              case 'Cicilan':
                return t.status == PaymentStatus.cicilan;
              default:
                return true;
            }
          }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _summaryCard('Total Tagihan', '${DummyData.tagihanList.length}', AppColors.info, AppColors.infoSurface, Icons.receipt_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Lunas', '${DummyData.tagihanList.where((t) => t.status == PaymentStatus.lunas).length}', AppColors.success, AppColors.successSurface, Icons.check_circle_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Belum Bayar', '${DummyData.tagihanList.where((t) => t.status == PaymentStatus.belumBayar).length}', AppColors.error, AppColors.errorSurface, Icons.cancel_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Terlambat', '${DummyData.tagihanList.where((t) => t.status == PaymentStatus.terlambat).length}', AppColors.warning, AppColors.warningSurface, Icons.warning_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard('Cicilan', '${DummyData.tagihanList.where((t) => t.status == PaymentStatus.cicilan).length}', AppColors.info, const Color(0xFFF0F9FF), Icons.splitscreen_rounded)),
            ],
          ),
          const SizedBox(height: 20),

          // Filter
          Row(
            children: ['Semua', 'Lunas', 'Belum Bayar', 'Terlambat', 'Cicilan']
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _filterChip(f),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Table
          AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tableHeader(),
                ...filtered.map((t) => _tagihanRow(t)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Saldo Keseluruhan',
            _formatCurrency(DummyData.saldoKeseluruhan),
            AppColors.primary,
            AppColors.primarySurface,
            Icons.pie_chart_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Saldo Infaq',
            _formatCurrency(DummyData.saldoInfaq),
            AppColors.success,
            AppColors.successSurface,
            Icons.volunteer_activism_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Saldo Operasional',
            _formatCurrency(DummyData.saldoOperasional),
            AppColors.info,
            AppColors.infoSurface,
            Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final text = amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  Widget _summaryCard(
      String label, String val, Color c, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val,
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w700, color: c)),
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 11, color: c.withOpacity(0.8))),
            ],
          ),
        ],
      ),
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
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            )),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
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
          _th('Nama Siswa', 3),
          _th('Jenis', 2),
          _th('Jumlah', 2),
          _th('Bulan', 2),
          _th('Status', 2),
          _th('Aksi', 1),
        ],
      ),
    );
  }

  Widget _th(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary)),
    );
  }

  Widget _tagihanRow(Tagihan t) {
    Color sc, sbg;
    String sl;
    switch (t.status) {
      case PaymentStatus.lunas:
        sc = AppColors.success; sbg = AppColors.successSurface; sl = 'Lunas'; break;
      case PaymentStatus.belumBayar:
        sc = AppColors.error; sbg = AppColors.errorSurface; sl = 'Belum Bayar'; break;
      case PaymentStatus.terlambat:
        sc = AppColors.warning; sbg = AppColors.warningSurface; sl = 'Terlambat'; break;
      case PaymentStatus.cicilan:
        sc = AppColors.info; sbg = AppColors.infoSurface; sl = 'Cicilan'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(t.siswaNama,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
              flex: 2,
              child: Text(t.jenis, style: GoogleFonts.outfit(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Text(
              'Rp ${t.jumlah.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
              style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          Expanded(flex: 2, child: Text(t.bulan, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            flex: 2,
            child: StatusBadge(label: sl, color: sc, bgColor: sbg),
          ),
          Expanded(
            flex: 1,
            child: (t.status != PaymentStatus.lunas)
                ? (t.status == PaymentStatus.cicilan
                    ? TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text('Detail Cicil',
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600)),
                      )
                    : TextButton(
                        onPressed: () => _showVerifikasiDialog(context, t),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text('Verifikasi',
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ))
                : const Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: AppColors.success),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Tab 2: Riwayat ───────────────────
  Widget _buildRiwayatPembayaran() {
    final lunasOnly = DummyData.tagihanList
        .where((t) => t.status == PaymentStatus.lunas)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: AdminCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: SectionHeader(
                title: 'Riwayat Pembayaran Lunas',
                subtitle: 'Semua transaksi yang berhasil diverifikasi',
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.surfaceVariant,
              child: Row(
                children: [
                  _th('Nama Siswa', 3),
                  _th('Jenis', 2),
                  _th('Jumlah', 2),
                  _th('Tanggal Bayar', 2),
                  _th('Metode', 2),
                ],
              ),
            ),
            ...lunasOnly.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.successSurface,
                              child: Text(t.siswaNama[0],
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success)),
                            ),
                            const SizedBox(width: 8),
                            Text(t.siswaNama,
                                style: GoogleFonts.outfit(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(t.jenis, style: GoogleFonts.outfit(fontSize: 12))),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rp ${(t.jumlah / 1000).toStringAsFixed(0)}rb',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Text(t.tanggalBayar ?? '-',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(
                              t.metodeBayar == 'Transfer Bank'
                                  ? Icons.account_balance_rounded
                                  : Icons.money_rounded,
                              size: 14, color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(t.metodeBayar ?? '-',
                                style: GoogleFonts.outfit(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ─────────────────── Tab 3: Atur Biaya ───────────────────
  Widget _buildAturBiaya() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Pengaturan Biaya',
            subtitle: 'Atur nominal biaya yang berlaku',
            action: PrimaryButton(
              label: 'Tambah Item Biaya',
              icon: Icons.add_rounded,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      _th('Nama Biaya', 3),
                      _th('Jumlah', 2),
                      _th('Kategori', 2),
                      _th('Status', 1),
                      _th('Aksi', 1),
                    ],
                  ),
                ),
                ...DummyData.biayaList.map((b) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.border))),
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
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.payments_rounded,
                                      size: 16,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                                Text(b.nama,
                                    style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Rp ${b.jumlah.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(b.kategori,
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Switch(
                              value: b.aktif,
                              onChanged: (_) {},
                              activeColor: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      size: 16),
                                  color: AppColors.textSecondary,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded,
                                      size: 16),
                                  color: AppColors.error,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBuatTagihanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Buat Tagihan Baru',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Jenis Tagihan',
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
                items: ['Syahriyah', 'Biaya Admin', 'Tabungan']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Bulan',
                  hintText: 'Contoh: April 2026',
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tagihan berhasil dibuat untuk semua siswa'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Buat Tagihan',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showVerifikasiDialog(BuildContext context, Tagihan t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Verifikasi Pembayaran',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _verifyRow('Siswa', t.siswaNama),
            _verifyRow('Jenis', t.jenis),
            _verifyRow('Jumlah', 'Rp ${(t.jumlah / 1000).toStringAsFixed(0)}rb'),
            _verifyRow('Bulan', t.bulan),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Metode Pembayaran',
                labelStyle: GoogleFonts.outfit(fontSize: 13),
              ),
              items: ['Transfer Bank', 'Cash', 'QRIS']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pembayaran berhasil diverifikasi'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Verifikasi',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _verifyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Text(': ', style: GoogleFonts.outfit(fontSize: 12)),
          Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
