import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/services/bill_service.dart';
import '../core/services/student_service.dart';
import '../widgets/common_widgets.dart';
import 'package:dio/dio.dart';

class KeuanganPage extends StatefulWidget {
  const KeuanganPage({super.key});

  @override
  State<KeuanganPage> createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _billService = BillService();
  final _studentService = StudentService();

  List<BillApi> _bills = [];
  List<SiswaApi> _students = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'Semua';

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
        _billService.fetchAll(),
        _studentService.fetchAll(),
      ]);
      if (mounted) {
        setState(() {
          _bills = results[0] as List<BillApi>;
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

  List<BillApi> get _filteredBills {
    if (_filterStatus == 'Semua') return _bills;
    return _bills.where((b) {
      switch (_filterStatus) {
        case 'Lunas': return b.status == BillStatus.paid;
        case 'Belum Bayar': return b.status == BillStatus.unpaid;
        case 'Terlambat': return b.status == BillStatus.overdue;
        case 'Cicilan': return b.status == BillStatus.partial;
        default: return true;
      }
    }).toList();
  }

  List<BillApi> get _paidBills => _bills.where((b) => b.status == BillStatus.paid).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Manajemen Keuangan',
                subtitle: 'Tagihan & riwayat pembayaran',
                action: PrimaryButton(
                  label: 'Buat Tagihan',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () => _showBuatTagihanDialog(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400),
                tabs: const [
                  Tab(icon: Icon(Icons.receipt_rounded, size: 18), text: 'Daftar Tagihan'),
                  Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'Riwayat Lunas'),
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
                        _buildDaftarTagihan(),
                        _buildRiwayatPembayaran(),
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

  Widget _buildSummaryRow() {
    final total = _bills.length;
    final lunas = _bills.where((b) => b.status == BillStatus.paid).length;
    final belum = _bills.where((b) => b.status == BillStatus.unpaid).length;
    final terlambat = _bills.where((b) => b.status == BillStatus.overdue).length;
    final totalAmount = _paidBills.fold<double>(0, (s, b) => s + b.amount);

    return Row(
      children: [
        Expanded(child: _summaryCard('Total Tagihan', '$total', AppColors.info, AppColors.infoSurface, Icons.receipt_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Lunas', '$lunas', AppColors.success, AppColors.successSurface, Icons.check_circle_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Belum Bayar', '$belum', AppColors.error, AppColors.errorSurface, Icons.cancel_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Terlambat', '$terlambat', AppColors.warning, AppColors.warningSurface, Icons.warning_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Total Diterima', _formatCurrency(totalAmount), AppColors.primary, AppColors.primarySurface, Icons.account_balance_wallet_rounded)),
      ],
    );
  }

  Widget _summaryCard(String label, String val, Color c, Color bg, IconData icon) {
    return Container(
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
                Text(label, style: GoogleFonts.outfit(fontSize: 10, color: c.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarTagihan() {
    final filtered = _filteredBills;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: ['Semua', 'Lunas', 'Belum Bayar', 'Terlambat', 'Cicilan']
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
                  _tableHeader(),
                  ...filtered.map((t) => _tagihanRow(t)),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: EmptyState(message: 'Tidak ada tagihan', icon: Icons.receipt_long_outlined),
                    ),
                ],
              ),
            ),
          ],
        ),
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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _th('Nama Santri', 3),
          _th('Judul Tagihan', 3),
          _th('Jumlah', 2),
          _th('Jatuh Tempo', 2),
          _th('Status', 2),
          _th('Aksi', 1),
        ],
      ),
    );
  }

  Widget _th(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
    );
  }

  Widget _tagihanRow(BillApi t) {
    Color sc, sbg;
    switch (t.status) {
      case BillStatus.paid:
        sc = AppColors.success; sbg = AppColors.successSurface;
        break;
      case BillStatus.overdue:
        sc = AppColors.warning; sbg = AppColors.warningSurface;
        break;
      case BillStatus.partial:
        sc = AppColors.info; sbg = AppColors.infoSurface;
        break;
      case BillStatus.unpaid:
        sc = AppColors.error; sbg = AppColors.errorSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(t.studentNama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(t.title, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
            flex: 2,
            child: Text(
              _formatCurrency(t.amount),
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              t.dueDate != null ? _formatDate(t.dueDate!) : '-',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(flex: 2, child: StatusBadge(label: t.statusLabel, color: sc, bgColor: sbg)),
          Expanded(
            flex: 1,
            child: t.status != BillStatus.paid
                ? TextButton(
                    onPressed: () => _showVerifikasiDialog(context, t),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('Verifikasi', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatPembayaran() {
    final paid = _paidBills;
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
              const Padding(
                padding: EdgeInsets.all(20),
                child: SectionHeader(
                  title: 'Riwayat Pembayaran Lunas',
                  subtitle: 'Semua tagihan yang berhasil dilunasi',
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surfaceVariant,
                child: Row(children: [_th('Nama Santri', 3), _th('Judul', 3), _th('Jumlah', 2), _th('Tanggal Lunas', 2)]),
              ),
              ...paid.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.successSurface,
                              child: Text(t.studentNama.isNotEmpty ? t.studentNama[0] : '?',
                                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                            ),
                            const SizedBox(width: 8),
                            Text(t.studentNama, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                        Expanded(flex: 3, child: Text(t.title, style: GoogleFonts.outfit(fontSize: 12))),
                        Expanded(
                          flex: 2,
                          child: Text(_formatCurrency(t.amount),
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(t.paidAt != null ? _formatDate(t.paidAt!) : '-',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  )),
              if (paid.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: EmptyState(message: 'Belum ada pembayaran lunas', icon: Icons.receipt_long_outlined),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final text = amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return 'Rp ${buffer.toString()}';
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  void _showBuatTagihanDialog(BuildContext context) {
    String? selectedStudentId;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dueDateCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Tagihan Baru', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                // Pilih santri
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Pilih Santri', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                  items: _students
                      .map((s) => DropdownMenuItem(value: s.id.toString(), child: Text('${s.nama} (${s.kelas})', style: GoogleFonts.outfit(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => selectedStudentId = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: 'Judul Tagihan', hintText: 'Contoh: SPP April 2026', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Jumlah (Rp)', hintText: '500000', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dueDateCtrl,
                  decoration: InputDecoration(labelText: 'Jatuh Tempo', hintText: 'YYYY-MM-DD', labelStyle: GoogleFonts.outfit(fontSize: 13)),
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text('Batal', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (selectedStudentId == null || titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Lengkapi semua field wajib'), backgroundColor: AppColors.error));
                                  return;
                                }
                                setDs(() => isSaving = true);
                                try {
                                  await _billService.create(
                                    title: titleCtrl.text,
                                    amount: double.tryParse(amountCtrl.text) ?? 0,
                                    studentId: int.parse(selectedStudentId!),
                                    dueDate: dueDateCtrl.text.isNotEmpty ? dueDateCtrl.text : null,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tagihan berhasil dibuat'), backgroundColor: AppColors.success));
                                    _loadData();
                                  }
                                } on DioException catch (e) {
                                  setDs(() => isSaving = false);
                                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal: ${e.response?.data['message'] ?? 'Error'}'), backgroundColor: AppColors.error));
                                }
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Buat Tagihan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVerifikasiDialog(BuildContext context, BillApi t) {
    bool isSaving = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Verifikasi Pembayaran', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _verifyRow('Santri', t.studentNama),
              _verifyRow('Tagihan', t.title),
              _verifyRow('Jumlah', _formatCurrency(t.amount)),
              const SizedBox(height: 8),
              Text('Tandai tagihan ini sebagai LUNAS?', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      setDs(() => isSaving = true);
                      try {
                        await _billService.markPaid(t.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tagihan berhasil diverifikasi sebagai Lunas'), backgroundColor: AppColors.success));
                          _loadData();
                        }
                      } on DioException catch (e) {
                        setDs(() => isSaving = false);
                        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal: ${e.response?.data['message'] ?? 'Error'}'), backgroundColor: AppColors.error));
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0),
              child: isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Verifikasi Lunas', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary))),
          Text(': ', style: GoogleFonts.outfit(fontSize: 12)),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
