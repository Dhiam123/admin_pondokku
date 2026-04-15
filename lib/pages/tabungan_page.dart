import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/services/wallet_service.dart';
import '../core/services/student_service.dart';
import '../widgets/common_widgets.dart';
import 'package:dio/dio.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _walletService = WalletService();
  final _studentService = StudentService();

  List<WalletApi> _wallets = [];
  List<SiswaApi> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _walletService.fetchAll(),
        _studentService.fetchAll(),
      ]);
      if (mounted) {
        setState(() {
          _wallets = results[0] as List<WalletApi>;
          _students = results[1] as List<SiswaApi>;
        });
      }
    } on DioException catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat: ${e.response?.data['message'] ?? e.message}');
    } catch (_) {
      if (mounted) setState(() => _error = 'Terjadi kesalahan tidak terduga.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    final totalSaldo = _wallets.fold<double>(0, (s, w) => s + w.balance);

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Tabungan & Dompet',
                subtitle: 'Kelola saldo dompet santri',
                action: PrimaryButton(
                  label: 'Buat Dompet',
                  icon: Icons.add_rounded,
                  onPressed: () => _showBuatDompetDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _summaryCard('Total Saldo', _formatCurrency(totalSaldo), AppColors.primary, AppColors.primarySurface, Icons.account_balance_wallet_rounded),
                  const SizedBox(width: 12),
                  _summaryCard('Santri Punya Dompet', '${_wallets.length}', AppColors.info, AppColors.infoSurface, Icons.people_rounded),
                  const SizedBox(width: 12),
                  _summaryCard('Saldo Rendah (<100rb)', '${_wallets.where((w) => w.balance < 100000).length}', AppColors.warning, AppColors.warningSurface, Icons.warning_amber_rounded),
                ],
              ),
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
                  Tab(icon: Icon(Icons.savings_rounded, size: 18), text: 'Saldo Santri'),
                  Tab(icon: Icon(Icons.info_outline_rounded, size: 18), text: 'Santri Tanpa Dompet'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSaldoSantri(),
                        _buildSantriTanpaDompet(),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error!, style: GoogleFonts.outfit(color: AppColors.error)),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Coba Lagi', icon: Icons.refresh_rounded, onPressed: _loadData),
        ],
      ),
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

  Widget _buildSaldoSantri() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: AdminCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _tableHeader(['Santri', 'Kelas', 'Saldo', 'Terakhir Diperbarui'], [3, 2, 2, 3]),
              ..._wallets.map((w) => _saldoRow(w)),
              if (_wallets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: EmptyState(message: 'Belum ada dompet terdaftar', icon: Icons.account_balance_wallet_outlined),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saldoRow(WalletApi w) {
    final isLow = w.balance < 100000;
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
                  child: Text(w.studentNama.isNotEmpty ? w.studentNama[0] : '?',
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(w.studentNama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(w.studentKelas, style: GoogleFonts.outfit(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(_formatCurrency(w.balance),
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: isLow ? AppColors.warning : AppColors.primary)),
                if (isLow) ...[
                  const SizedBox(width: 6),
                  const Tooltip(message: 'Saldo rendah!', child: Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning)),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              w.updatedAt != null ? '${w.updatedAt!.day}/${w.updatedAt!.month}/${w.updatedAt!.year}' : '-',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriTanpaDompet() {
    final walletStudentIds = _wallets.map((w) => w.studentId).toSet();
    final tanpaDompet = _students.where((s) => !walletStudentIds.contains(s.id) && s.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: AdminCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SectionHeader(
                  title: 'Santri Belum Punya Dompet',
                  subtitle: '${tanpaDompet.length} santri aktif belum memiliki dompet',
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              _tableHeader(['Santri', 'NIS', 'Kelas', 'Aksi'], [3, 2, 2, 1]),
              ...tanpaDompet.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(s.nama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500))),
                        Expanded(flex: 2, child: Text(s.nis, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(flex: 2, child: Text(s.kelas, style: GoogleFonts.outfit(fontSize: 12))),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 20),
                            tooltip: 'Buat dompet',
                            onPressed: () async {
                              try {
                                await _walletService.create(s.id);
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dompet untuk ${s.nama} berhasil dibuat'), backgroundColor: AppColors.success));
                                  _loadData();
                                }
                              } on DioException catch (e) {
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.response?.data['message'] ?? 'Error'}'), backgroundColor: AppColors.error));
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
              if (tanpaDompet.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: EmptyState(message: 'Semua santri aktif sudah punya dompet!', icon: Icons.celebration_rounded),
                ),
            ],
          ),
        ),
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

  void _showBuatDompetDialog(BuildContext context) {
    String? selectedStudentId;
    bool isSaving = false;

    final walletStudentIds = _wallets.map((w) => w.studentId).toSet();
    final eligible = _students.where((s) => !walletStudentIds.contains(s.id) && s.isActive).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Buat Dompet Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 400,
            child: eligible.isEmpty
                ? Text('Semua santri aktif sudah memiliki dompet!', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary))
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Pilih Santri', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                    items: eligible.map((s) => DropdownMenuItem(value: s.id.toString(), child: Text('${s.nama} (${s.kelas})', style: GoogleFonts.outfit(fontSize: 13)))).toList(),
                    onChanged: (v) => selectedStudentId = v,
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            if (eligible.isNotEmpty)
              ElevatedButton(
                onPressed: isSaving || selectedStudentId == null
                    ? null
                    : () async {
                        setDs(() => isSaving = true);
                        try {
                          await _walletService.create(int.parse(selectedStudentId!));
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dompet berhasil dibuat'), backgroundColor: AppColors.success));
                            _loadData();
                          }
                        } on DioException catch (e) {
                          setDs(() => isSaving = false);
                          if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal: ${e.response?.data['message'] ?? 'Error'}'), backgroundColor: AppColors.error));
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
                child: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Buat', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}
