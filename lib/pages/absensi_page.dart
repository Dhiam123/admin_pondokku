import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedKelas = 'Semua';

  List<String> get _kelasList {
    final list = DummyData.siswaList.map((e) => e.kelas).toSet().toList();
    list.sort();
    return ['Semua', ...list];
  }

  List<Absensi> get _filteredAbsensi {
    final dateFormat = DateFormat('yyyy-MM-dd').format(_selectedDate);
    // Since dummy data uses fixed date, let's just make it show for 2026-04-14
    final isDummyDate = dateFormat == '2026-04-14';

    if (!isDummyDate) return [];

    return DummyData.absensiList.where((a) {
      if (_selectedKelas != 'Semua' && a.kelas != _selectedKelas) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Manajemen Absensi',
            subtitle: 'Catat dan pantau kehadiran siswa',
            action: PrimaryButton(
              label: 'Catat Absensi',
              icon: Icons.fact_check_rounded,
              onPressed: () => _showAbsensiForm(),
            ),
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 20),
          _buildAbsensiList(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 720;
          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    _buildClassFilter(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildDatePicker()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildClassFilter()),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal',
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
                const Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter Kelas',
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedKelas,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted),
              items: _kelasList.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Text(k,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedKelas = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiList() {
    return AdminCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 740;
          return Column(
            children: [
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Nama Siswa',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Kelas',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Status',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Keterangan',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                      SizedBox(
                        width: 76,
                        child: Text('Aksi',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ..._filteredAbsensi.map((a) =>
                  isMobile ? _buildAbsensiCard(a) : _buildAbsensiRow(a)),
              if (_filteredAbsensi.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: EmptyState(
                    message: 'Belum ada data absensi untuk tanggal ini',
                    icon: Icons.event_busy_rounded,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAbsensiRow(Absensi a) {
    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (a.status) {
      case AbsensiStatus.hadir:
        statusColor = AppColors.success;
        statusBg = AppColors.successSurface;
        statusLabel = 'Hadir';
        break;
      case AbsensiStatus.izin:
        statusColor = AppColors.info;
        statusBg = AppColors.infoSurface;
        statusLabel = 'Izin';
        break;
      case AbsensiStatus.sakit:
        statusColor = AppColors.warning;
        statusBg = AppColors.warningSurface;
        statusLabel = 'Sakit';
        break;
      case AbsensiStatus.alpha:
        statusColor = AppColors.error;
        statusBg = AppColors.errorSurface;
        statusLabel = 'Alpha';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    a.siswaNama[0],
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(a.siswaNama,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(a.kelas,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: statusLabel,
                color: statusColor,
                bgColor: statusBg,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(a.keterangan ?? '-',
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: 76,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Edit nama siswa',
                onPressed: () => _showEditNamaDialog(a),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditNamaDialog(Absensi a) async {
    final controller = TextEditingController(text: a.siswaNama);
    final formKey = GlobalKey<FormState>();

    final updatedNama = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Nama Absensi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nama Siswa',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: Text('Simpan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (updatedNama != null && updatedNama != a.siswaNama) {
      final index = DummyData.absensiList.indexWhere((item) => item.id == a.id);
      if (index >= 0) {
        setState(() {
          DummyData.absensiList[index] = Absensi(
            id: a.id,
            siswaId: a.siswaId,
            siswaNama: updatedNama,
            kelas: a.kelas,
            tanggal: a.tanggal,
            status: a.status,
            keterangan: a.keterangan,
          );
        });
      }
    }
  }

  Widget _buildAbsensiCard(Absensi a) {
    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (a.status) {
      case AbsensiStatus.hadir:
        statusColor = AppColors.success;
        statusBg = AppColors.successSurface;
        statusLabel = 'Hadir';
        break;
      case AbsensiStatus.izin:
        statusColor = AppColors.info;
        statusBg = AppColors.infoSurface;
        statusLabel = 'Izin';
        break;
      case AbsensiStatus.sakit:
        statusColor = AppColors.warning;
        statusBg = AppColors.warningSurface;
        statusLabel = 'Sakit';
        break;
      case AbsensiStatus.alpha:
        statusColor = AppColors.error;
        statusBg = AppColors.errorSurface;
        statusLabel = 'Alpha';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primarySurface,
                child: Text(a.siswaNama[0],
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.siswaNama,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(a.kelas,
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusBadge(label: statusLabel, color: statusColor, bgColor: statusBg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(a.keterangan ?? '-',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                color: AppColors.primary,
                tooltip: 'Edit nama siswa',
                onPressed: () => _showEditNamaDialog(a),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAbsensiForm() {
    showDialog(
      context: context,
      builder: (ctx) => const FormAbsensiDialog(),
    );
  }
}

class FormAbsensiDialog extends StatefulWidget {
  const FormAbsensiDialog({super.key});

  @override
  State<FormAbsensiDialog> createState() => _FormAbsensiDialogState();
}

class _FormAbsensiDialogState extends State<FormAbsensiDialog> {
  String _selectedKelas = 'Kelas 1 Ula';
  final Map<String, AbsensiStatus> _absensiData = {};
  final Map<String, String> _keteranganData = {};

  List<String> get _kelasList {
    final list = DummyData.siswaList.map((e) => e.kelas).toSet().toList();
    list.sort();
    return list;
  }

  List<Siswa> get _siswaByKelas {
    return DummyData.siswaList
        .where((s) => s.kelas == _selectedKelas && s.aktif)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _initAbsensi();
  }

  void _initAbsensi() {
    _absensiData.clear();
    for (var s in DummyData.siswaList) {
      _absensiData[s.id] = AbsensiStatus.hadir;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Catat Absensi',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy').format(DateTime.now()),
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih Kelas',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedKelas,
                            isExpanded: true,
                            items: _kelasList.map((k) {
                              return DropdownMenuItem(
                                value: k,
                                child: Text(k,
                                    style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedKelas = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Daftar Siswa',
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.separated(
                  itemCount: _siswaByKelas.length,
                  separatorBuilder: (c, i) => const Divider(
                      height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final s = _siswaByKelas[index];
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(s.nama,
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: AbsensiStatus.values.map((status) {
                                return _buildStatusRadio(s.id, status);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Keterangan',
                                hintStyle: GoogleFonts.outfit(
                                    fontSize: 11, color: AppColors.textMuted),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              style: GoogleFonts.outfit(fontSize: 12),
                              onChanged: (v) => _keteranganData[s.id] = v,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Batal',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Absensi berhasil disimpan'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Simpan Absensi',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRadio(String siswaId, AbsensiStatus status) {
    Color activeColor;
    String label;
    switch (status) {
      case AbsensiStatus.hadir:
        activeColor = AppColors.success;
        label = 'H';
        break;
      case AbsensiStatus.izin:
        activeColor = AppColors.info;
        label = 'I';
        break;
      case AbsensiStatus.sakit:
        activeColor = AppColors.warning;
        label = 'S';
        break;
      case AbsensiStatus.alpha:
        activeColor = AppColors.error;
        label = 'A';
        break;
    }

    final isSelected = _absensiData[siswaId] == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _absensiData[siswaId] = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? activeColor : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
