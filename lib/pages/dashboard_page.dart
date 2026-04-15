import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ─── Data Calculations ───
    final totalSiswa = DummyData.siswaList.length;
    final totalGuru = DummyData.guruList.length;
    final absenHariIni = DummyData.absensiList.length;
    final tagihanLunas = DummyData.tagihanList
        .where((t) => t.status == PaymentStatus.lunas)
        .length;
    final tagihanBelum = DummyData.tagihanList
        .where((t) => t.status != PaymentStatus.lunas)
        .length;
    final pendapatanBulanIni = DummyData.tagihanList
        .where((t) => t.status == PaymentStatus.lunas)
        .fold(0.0, (sum, t) => sum + t.jumlah);

    final pesanBelumDibaca = DummyData.pesanList
        .where((m) => m.status == MessageStatus.unread)
        .length;
    final topupMenunggu = DummyData.mutasiList
        .where((m) => m.status == TopupStatus.menunggu)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1200;
        final isMedium = constraints.maxWidth > 850;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Welcome Banner Premium
                  _buildWelcomeBanner(pesanBelumDibaca, topupMenunggu),
                  const SizedBox(height: 24),

                  // 2. Metrik Utama (Akademik & SDM)
                  _buildSectionLabel(
                      'Indikator Akademik & SDM', Icons.school_rounded),
                  _buildPrimaryMetrics(
                      totalSiswa, totalGuru, absenHariIni, isMedium),

                  const SizedBox(height: 32),

                  // 3. Keuangan & Tagihan Overview
                  _buildSectionLabel('Ringkasan Keuangan & Tagihan Bulan Ini',
                      Icons.account_balance_wallet_rounded),
                  _buildFinanceOverview(
                      DummyData.saldoKeseluruhan,
                      DummyData.saldoInfaq,
                      DummyData.saldoOperasional,
                      isMedium),
                  const SizedBox(height: 16),
                  _buildStatCards(
                      tagihanLunas, tagihanBelum, pendapatanBulanIni, isMedium),

                  const SizedBox(height: 32),

                  // 4. Analitik Chart
                  if (isWide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _buildRevenueChart()),
                          const SizedBox(width: 20),
                          Expanded(
                              flex: 2,
                              child: _buildPaymentStatusChart(
                                  tagihanLunas, tagihanBelum)),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildRevenueChart(),
                        const SizedBox(height: 20),
                        _buildPaymentStatusChart(tagihanLunas, tagihanBelum),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // 5. Tabel Histori & Notifikasi Terkini
                  if (isMedium)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _buildRecentPayments()),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: _buildRecentNotifications()),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildRecentPayments(),
                        const SizedBox(height: 20),
                        _buildRecentNotifications(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // 1. Welcome Banner
  // ────────────────────────────────────────────────────────────
  Widget _buildWelcomeBanner(int unreadPesan, int pendingTopup) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahlan wa Sahlan, Admin 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ikhtisar sistem Pondok Pesantren Darussalam hari ini.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (unreadPesan > 0)
                      _quickBadge('$unreadPesan Pesan Baru', Icons.mail_rounded,
                          Colors.white.withOpacity(0.2)),
                    if (pendingTopup > 0)
                      _quickBadge('$pendingTopup Verifikasi Top-Up',
                          Icons.payments_rounded, const Color(0x33FFB020)),
                    _quickBadge('3 Tagihan Jatuh Tempo',
                        Icons.warning_amber_rounded, const Color(0x33FF3B30)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.mosque_rounded, size: 56, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _quickBadge(String label, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // 2. Metrik Utama (Akademik & SDM)
  // ────────────────────────────────────────────────────────────
  Widget _buildPrimaryMetrics(int siswa, int guru, int absen, bool isMedium) {
    final cards = [
      _metricCard('Santri Aktif', '$siswa', 'Orang', Icons.people_alt_rounded,
          AppColors.info, AppColors.infoSurface),
      _summaryCardRich('Tenaga Pendidik', '$guru Ustadz/Ah',
          Icons.person_rounded, AppColors.warning),
      _summaryCardRich('Absensi Hari Ini', '$absen Santri Hadir',
          Icons.fact_check_rounded, AppColors.success),
    ];

    if (isMedium) {
      return Row(
          children: cards
              .map((c) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 16), child: c)))
              .toList());
    } else {
      return Column(
          children: cards
              .map((c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c))
              .toList());
    }
  }

  Widget _metricCard(String title, String val, String suffix, IconData icon,
      Color c, Color bg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: c, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(val,
                        style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(suffix,
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCardRich(
      String label, String val, IconData icon, Color color) {
    return _metricCard(
        label,
        val.split(' ')[0],
        val.split(' ').length > 1 ? val.split(' ')[1] : '',
        icon,
        color,
        color.withOpacity(0.12));
  }

  // ────────────────────────────────────────────────────────────
  // 3. Keuangan & Tagihan
  // ────────────────────────────────────────────────────────────
  Widget _buildFinanceOverview(
      double total, double infaq, double operasional, bool isMedium) {
    final cards = [
      _financeVaultCard('Kas Keseluruhan', total, Icons.account_balance_rounded,
          AppColors.primary),
      _financeVaultCard('Dana Infaq', infaq, Icons.volunteer_activism_rounded,
          AppColors.success),
      _financeVaultCard('Dana Operasional', operasional, Icons.domain_rounded,
          AppColors.secondary),
    ];
    if (isMedium) {
      return Row(
          children: cards
              .map((c) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 16), child: c)))
              .toList());
    } else {
      return Column(
          children: cards
              .map((c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c))
              .toList());
    }
  }

  Widget _financeVaultCard(
      String title, double amount, IconData icon, Color c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 26),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              Text('Rp ${(amount / 1000000).toStringAsFixed(1)} Juta',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(
      int lunas, int belum, double pendapatan, bool isMedium) {
    final cards = [
      StatCard(
          title: 'Tagihan Berhasil',
          value: '$lunas',
          subtitle: 'Bulan April 2026',
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          iconBg: AppColors.successSurface,
          trend: '80%',
          trendUp: true),
      StatCard(
          title: 'Pendapatan Diterima',
          value: 'Rp ${(pendapatan / 1000).toStringAsFixed(0)}rb',
          subtitle: 'April 2026',
          icon: Icons.receipt_long_rounded,
          iconColor: AppColors.secondary,
          iconBg: AppColors.secondarySurface,
          trend: '+12%',
          trendUp: true),
      StatCard(
          title: 'Menunggak',
          value: '$belum',
          subtitle: 'Perlu ditagih',
          icon: Icons.pending_actions_rounded,
          iconColor: AppColors.error,
          iconBg: AppColors.errorSurface,
          trend: '20%',
          trendUp: false),
    ];
    if (isMedium) {
      return Row(
          children: cards
              .map((c) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 16), child: c)))
              .toList());
    } else {
      return Column(
          children: cards
              .map((c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c))
              .toList());
    }
  }

  // ────────────────────────────────────────────────────────────
  // 4. Analitik Chart
  // ────────────────────────────────────────────────────────────
  Widget _buildRevenueChart() {
    final spots = [
      const FlSpot(1, 1.8),
      const FlSpot(2, 2.1),
      const FlSpot(3, 1.9),
      const FlSpot(4, 2.4),
      const FlSpot(5, 2.2),
      const FlSpot(6, 2.8)
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Trend Pendapatan',
              subtitle: '6 Bulan Terakhir (Juta Rupiah)'),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.surfaceVariant, strokeWidth: 1.5),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) => Text(
                            '${v.toStringAsFixed(1)}M',
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: AppColors.textMuted))),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const months = [
                            '',
                            'Okt',
                            'Nov',
                            'Des',
                            'Jan',
                            'Feb',
                            'Mar'
                          ];
                          if (v.toInt() < 1 || v.toInt() > 6)
                            return const SizedBox();
                          return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(months[v.toInt()],
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600)));
                        }),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.01)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                  ),
                ],
                minX: 1,
                maxX: 6,
                minY: 1.0,
                maxY: 3.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(int lunas, int drpdLunas) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Distribusi Tagihan', subtitle: 'Bulan April 2026'),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                      value: 5,
                      color: AppColors.success,
                      title: '5',
                      radius: 55,
                      titleStyle: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  PieChartSectionData(
                      value: 1,
                      color: AppColors.info,
                      title: '1',
                      radius: 50,
                      titleStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  PieChartSectionData(
                      value: 2,
                      color: AppColors.error,
                      title: '2',
                      radius: 55,
                      titleStyle: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
                sectionsSpace: 4,
                centerSpaceRadius: 35,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _legendItem(AppColors.success, 'Lunas', '5'),
          const SizedBox(height: 6),
          _legendItem(AppColors.info, 'Cicilan', '1'),
          const SizedBox(height: 6),
          _legendItem(AppColors.error, 'Belum Bayar/Tunggak', '2'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String count) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary))),
        Text(count,
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // 5. Histori & Notifikasi Terkini
  // ────────────────────────────────────────────────────────────
  Widget _buildRecentPayments() {
    final recent = DummyData.tagihanList.take(5).toList();
    return AdminCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SectionHeader(
              title: 'Riwayat Pembayaran Terbaru',
              action: TextButton(
                  onPressed: () {},
                  child: Text('Semua',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700))),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...recent.map((t) => _paymentRow(t)),
        ],
      ),
    );
  }

  Widget _paymentRow(Tagihan t) {
    Color sc, sbg;
    String sl;
    switch (t.status) {
      case PaymentStatus.lunas:
        sc = AppColors.success;
        sbg = AppColors.successSurface;
        sl = 'Lunas';
        break;
      case PaymentStatus.belumBayar:
        sc = AppColors.error;
        sbg = AppColors.errorSurface;
        sl = 'Belum';
        break;
      case PaymentStatus.terlambat:
        sc = AppColors.warning;
        sbg = AppColors.warningSurface;
        sl = 'Terlambat';
        break;
      case PaymentStatus.cicilan:
        sc = AppColors.info;
        sbg = AppColors.infoSurface;
        sl = 'Cicilan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySurface,
            child: Text(t.siswaNama[0],
                style: GoogleFonts.outfit(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.siswaNama,
                    style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${t.jenis} · ${t.bulan}',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text('Rp ${(t.jumlah / 1000).toStringAsFixed(0)}rb',
              style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          StatusBadge(label: sl, color: sc, bgColor: sbg),
        ],
      ),
    );
  }

  Widget _buildRecentNotifications() {
    return AdminCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.all(20),
              child: SectionHeader(title: 'Notifikasi & Log Sistem')),
          const Divider(height: 1, color: AppColors.border),
          ...DummyData.notifikasiList.take(5).map((n) => _notifRow(n)),
        ],
      ),
    );
  }

  Widget _notifRow(Notifikasi n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: n.dibaca ? null : n.warna.withOpacity(0.04),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: n.warna.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(n.ikon, size: 18, color: n.warna),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.judul,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight:
                            n.dibaca ? FontWeight.w600 : FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(n.isi,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(n.waktu,
                    style: GoogleFonts.outfit(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
