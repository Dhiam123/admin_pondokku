import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../core/services/dashboard_service.dart';
import '../widgets/common_widgets.dart';
import 'package:dio/dio.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _service = DashboardService();
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final stats = await _service.fetchStats();
      if (mounted) setState(() => _stats = stats);
    } on DioException catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat: ${e.response?.data['message'] ?? e.message}');
    } catch (_) {
      if (mounted) setState(() => _error = 'Terjadi kesalahan tidak terduga.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.outfit(color: AppColors.error, fontSize: 14)),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Coba Lagi', icon: Icons.refresh_rounded, onPressed: _loadData),
          ],
        ),
      );
    }

    final s = _stats ?? DashboardStats.empty();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1200;
        final isMedium = constraints.maxWidth > 850;

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome Banner
                    _buildWelcomeBanner(s),
                    const SizedBox(height: 24),

                    // 2. Metrik Utama
                    _buildSectionLabel('Indikator Akademik & SDM', Icons.school_rounded),
                    _buildPrimaryMetrics(s, isMedium),
                    const SizedBox(height: 32),

                    // 3. Keuangan Overview
                    _buildSectionLabel('Ringkasan Keuangan & Tagihan', Icons.account_balance_wallet_rounded),
                    _buildFinanceOverview(s, isMedium),
                    const SizedBox(height: 16),
                    _buildBillStatCards(s, isMedium),
                    const SizedBox(height: 32),

                    // 4. Chart & Distribusi
                    if (isWide)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 2, child: _buildBillDistChart(s)),
                            const SizedBox(width: 20),
                            Expanded(flex: 3, child: _buildRecentTransactions(s)),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _buildBillDistChart(s),
                          const SizedBox(height: 20),
                          _buildRecentTransactions(s),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(DashboardStats s) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahlan wa Sahlan, Admin 👋',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Ikhtisar sistem Pondok Pesantren Darussalam.',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _quickBadge('${s.activeStudents} Santri Aktif', Icons.people_rounded, Colors.white.withValues(alpha: 0.2)),
                    if (s.overdueBills > 0)
                      _quickBadge('${s.overdueBills} Tagihan Lewat Tempo', Icons.warning_amber_rounded, const Color(0x33FF3B30)),
                    if (s.unpaidBills > 0)
                      _quickBadge('${s.unpaidBills} Belum Dibayar', Icons.receipt_long_rounded, const Color(0x33FFB020)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.mosque_rounded, size: 56, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _quickBadge(String label, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPrimaryMetrics(DashboardStats s, bool isMedium) {
    final cards = [
      _metricCard('Santri Aktif', '${s.activeStudents}', 'Orang', Icons.people_alt_rounded, AppColors.info, AppColors.infoSurface),
      _metricCard('Total Pengguna', '${s.totalUsers}', 'Akun', Icons.person_rounded, AppColors.warning, AppColors.warningSurface),
      _metricCard('Dompet Aktif', '${s.totalWallets}', 'Dompet', Icons.account_balance_wallet_rounded, AppColors.success, AppColors.successSurface),
    ];

    return isMedium
        ? Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList())
        : Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
  }

  Widget _metricCard(String title, String val, String suffix, IconData icon, Color c, Color bg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: c, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(val, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(suffix, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceOverview(DashboardStats s, bool isMedium) {
    final cards = [
      _financeCard('Total Saldo Dompet', s.totalWalletBalance, Icons.savings_rounded, AppColors.primary),
      _financeCard('Tagihan Belum Lunas', s.totalUnpaidAmount, Icons.pending_actions_rounded, AppColors.error),
      _financeCard('Tagihan Jatuh Tempo', s.overdueBills.toDouble(), Icons.warning_amber_rounded, AppColors.warning, isCurrency: false, suffix: 'Tagihan'),
    ];

    return isMedium
        ? Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList())
        : Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
  }

  Widget _financeCard(String title, double amount, IconData icon, Color c, {bool isCurrency = true, String suffix = ''}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c.withValues(alpha: 0.05), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 26),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text(
                isCurrency ? _fmt(amount) : '${amount.toInt()} $suffix',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillStatCards(DashboardStats s, bool isMedium) {
    final cards = [
      StatCard(title: 'Tagihan Lunas', value: '${s.paidBills}', subtitle: 'Total semua waktu', icon: Icons.check_circle_rounded, iconColor: AppColors.success, iconBg: AppColors.successSurface, trend: '', trendUp: true),
      StatCard(title: 'Belum Dibayar', value: '${s.unpaidBills}', subtitle: 'Perlu tindak lanjut', icon: Icons.pending_actions_rounded, iconColor: AppColors.warning, iconBg: AppColors.warningSurface, trend: '', trendUp: false),
      StatCard(title: 'Tagihan Jatuh Tempo', value: '${s.overdueBills}', subtitle: 'Sudah lewat deadline', icon: Icons.warning_rounded, iconColor: AppColors.error, iconBg: AppColors.errorSurface, trend: '', trendUp: false),
    ];

    return isMedium
        ? Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList())
        : Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
  }

  Widget _buildBillDistChart(DashboardStats s) {
    final total = s.paidBills + s.unpaidBills + s.overdueBills;
    if (total == 0) {
      return const AdminCard(
        child: Center(
          child: Padding(padding: EdgeInsets.all(40), child: EmptyState(message: 'Belum ada data tagihan', icon: Icons.receipt_long_outlined)),
        ),
      );
    }

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Distribusi Tagihan', subtitle: 'Semua waktu'),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(PieChartData(
              sections: [
                if (s.paidBills > 0)
                  PieChartSectionData(value: s.paidBills.toDouble(), color: AppColors.success, title: '${s.paidBills}', radius: 55, titleStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                if (s.unpaidBills > 0)
                  PieChartSectionData(value: s.unpaidBills.toDouble(), color: AppColors.warning, title: '${s.unpaidBills}', radius: 50, titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                if (s.overdueBills > 0)
                  PieChartSectionData(value: s.overdueBills.toDouble(), color: AppColors.error, title: '${s.overdueBills}', radius: 55, titleStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
              sectionsSpace: 4,
              centerSpaceRadius: 35,
            )),
          ),
          const SizedBox(height: 16),
          _legendItem(AppColors.success, 'Lunas', '${s.paidBills}'),
          const SizedBox(height: 6),
          _legendItem(AppColors.warning, 'Belum Bayar', '${s.unpaidBills}'),
          const SizedBox(height: 6),
          _legendItem(AppColors.error, 'Jatuh Tempo', '${s.overdueBills}'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String count) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
        Text(count, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildRecentTransactions(DashboardStats s) {
    return AdminCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(20), child: SectionHeader(title: 'Transaksi Dompet Terkini')),
          const Divider(height: 1, color: AppColors.border),
          ...s.recentTransactions.map((t) => _txRow(t)),
          if (s.recentTransactions.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: EmptyState(message: 'Belum ada transaksi', icon: Icons.swap_horiz_rounded)),
        ],
      ),
    );
  }

  Widget _txRow(RecentTransaction t) {
    final isCredit = t.type == 'CREDIT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isCredit ? AppColors.successSurface : AppColors.infoSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 18,
              color: isCredit ? AppColors.success : AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.studentNama ?? 'Tidak Diketahui', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(t.description ?? (isCredit ? 'Top-Up Saldo' : 'Pembayaran'), style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${_fmt(t.amount)}',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: isCredit ? AppColors.success : AppColors.info),
          ),
        ],
      ),
    );
  }

  String _fmt(double amount) {
    final text = amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return 'Rp ${buffer.toString()}';
  }
}