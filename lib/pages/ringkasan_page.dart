import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/data/data.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RingkasanPage extends StatelessWidget {
  const RingkasanPage({super.key});

  String _formatRp(double amount) {
    return NumberFormat.currency(
            locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Laporan Ikhtisar',
            subtitle: 'Ringkasan komprehensif keuangan, SDM, dan akademik pondok',
          ),
          const SizedBox(height: 32),

          // Keuangan Section
          _buildSectionTitle('Indikator Keuangan', Icons.account_balance_wallet_rounded, AppColors.primary),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _financeCard(
                  'Saldo Keseluruhan', DummyData.saldoKeseluruhan, Icons.account_balance_rounded, AppColors.primary),
              _financeCard(
                  'Saldo Infaq', DummyData.saldoInfaq, Icons.volunteer_activism_rounded, AppColors.success),
              _financeCard(
                  'Saldo Operasional', DummyData.saldoOperasional, Icons.domain_rounded, AppColors.secondary),
            ],
          ),
          
          const SizedBox(height: 40),

          // Akademik & SDM Section
          _buildSectionTitle('Akademik & SDM', Icons.school_rounded, AppColors.info),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _summaryCard('Siswa Aktif', DummyData.siswaList.length.toString(), Icons.people_alt_rounded, AppColors.info),
              _summaryCard('Total Guru', DummyData.guruList.length.toString(), Icons.person_rounded, AppColors.warning),
              _summaryCard('Tendik / Staff', '12', Icons.badge_rounded, AppColors.secondary),
            ],
          ),

          const SizedBox(height: 40),

          // Aktivitas Harian Section
          _buildSectionTitle('Aktivitas & Catatan', Icons.fact_check_rounded, AppColors.success),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _summaryCard('Absen Hari Ini', DummyData.absensiList.length.toString(), Icons.event_available_rounded, AppColors.primary),
              _summaryCard('Rekap Nilai Tersimpan', DummyData.nilaiList.length.toString(), Icons.menu_book_rounded, AppColors.success),
              _summaryCard('Pengumuman Aktif', DummyData.pengumumanList.where((p) => p.published).length.toString(), Icons.campaign_rounded, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _financeCard(String title, double amount, IconData icon, Color color) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
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
                const SizedBox(height: 6),
                Text(_formatRp(amount),
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: 200,
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
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
                Text(count,
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
}
