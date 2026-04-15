import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  Pengumuman? _selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Pengumuman & Notifikasi',
                  subtitle: '${DummyData.pengumumanList.length} pengumuman',
                  action: PrimaryButton(
                    label: 'Buat Pengumuman',
                    icon: Icons.campaign_rounded,
                    onPressed: () => _showBuatDialog(context),
                  ),
                ),
                const SizedBox(height: 20),
                ...DummyData.pengumumanList
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _pengumumanCard(p),
                        )),
              ],
            ),
          ),
        ),

        // Detail
        if (_selected != null) ...[
          Container(width: 1, color: AppColors.border),
          Expanded(
            flex: 1,
            child: _buildDetail(_selected!),
          ),
        ],
      ],
    );
  }

  Color _tipeColor(AnnouncementType t) {
    switch (t) {
      case AnnouncementType.umum: return AppColors.info;
      case AnnouncementType.keuangan: return AppColors.warning;
      case AnnouncementType.kegiatan: return AppColors.primary;
      case AnnouncementType.darurat: return AppColors.error;
    }
  }

  String _tipeLabel(AnnouncementType t) {
    switch (t) {
      case AnnouncementType.umum: return 'Umum';
      case AnnouncementType.keuangan: return 'Keuangan';
      case AnnouncementType.kegiatan: return 'Kegiatan';
      case AnnouncementType.darurat: return 'Darurat';
    }
  }

  IconData _tipeIcon(AnnouncementType t) {
    switch (t) {
      case AnnouncementType.umum: return Icons.info_rounded;
      case AnnouncementType.keuangan: return Icons.account_balance_wallet_rounded;
      case AnnouncementType.kegiatan: return Icons.event_rounded;
      case AnnouncementType.darurat: return Icons.warning_rounded;
    }
  }

  Widget _pengumumanCard(Pengumuman p) {
    final isSelected = _selected?.id == p.id;
    final tc = _tipeColor(p.tipe);

    return GestureDetector(
      onTap: () => setState(() => _selected = isSelected ? null : p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tc.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_tipeIcon(p.tipe), size: 16, color: tc),
                ),
                const SizedBox(width: 10),
                StatusBadge(
                  label: _tipeLabel(p.tipe),
                  color: tc,
                  bgColor: tc.withOpacity(0.1),
                ),
                const Spacer(),
                StatusBadge(
                  label: p.published ? 'Published' : 'Draft',
                  color: p.published ? AppColors.success : AppColors.textMuted,
                  bgColor: p.published
                      ? AppColors.successSurface
                      : AppColors.surfaceVariant,
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_rounded, size: 16), const SizedBox(width: 8), Text('Edit', style: GoogleFonts.outfit(fontSize: 13))])),
                    PopupMenuItem(value: p.published ? 'unpublish' : 'publish', child: Row(children: [Icon(p.published ? Icons.visibility_off_rounded : Icons.publish_rounded, size: 16), const SizedBox(width: 8), Text(p.published ? 'Unpublish' : 'Publish', style: GoogleFonts.outfit(fontSize: 13))])),
                    PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_rounded, size: 16, color: AppColors.error), const SizedBox(width: 8), Text('Hapus', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.error))])),
                  ],
                  onSelected: (v) {
                    if (v == 'delete') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengumuman dihapus'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(p.judul,
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(p.isi,
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(p.tanggal,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline_rounded,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(p.penulis,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(Pengumuman p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Detail Pengumuman',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selected = null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(
                      label: _tipeLabel(p.tipe),
                      color: _tipeColor(p.tipe),
                      bgColor: _tipeColor(p.tipe).withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: p.published ? 'Published' : 'Draft',
                      color: p.published ? AppColors.success : AppColors.textMuted,
                      bgColor: p.published ? AppColors.successSurface : AppColors.surfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(p.judul,
                    style: GoogleFonts.outfit(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${p.tanggal} · ${p.penulis}',
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),
                Text(p.isi,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showBuatDialog(context, p: p),
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: Text('Edit',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(p.published
                            ? 'Pengumuman disembunyikan'
                            : 'Pengumuman dipublikasikan'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: Icon(
                    p.published ? Icons.visibility_off_rounded : Icons.publish_rounded,
                    size: 15,
                  ),
                  label: Text(
                    p.published ? 'Unpublish' : 'Publish',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.published ? AppColors.warning : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBuatDialog(BuildContext context, {Pengumuman? p}) {
    final judulCtrl = TextEditingController(text: p?.judul ?? '');
    final isiCtrl = TextEditingController(text: p?.isi ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p == null ? 'Buat Pengumuman Baru' : 'Edit Pengumuman',
                  style: GoogleFonts.outfit(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: judulCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul Pengumuman',
                  prefixIcon: const Icon(Icons.title_rounded, size: 18),
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
                style: GoogleFonts.outfit(fontSize: 13),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AnnouncementType>(
                initialValue: p?.tipe ?? AnnouncementType.umum,
                decoration: InputDecoration(
                  labelText: 'Tipe Pengumuman',
                  prefixIcon: const Icon(Icons.label_rounded, size: 18),
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
                items: AnnouncementType.values.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(_tipeLabel(t),
                          style: GoogleFonts.outfit(fontSize: 13)),
                    )).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextField(
                controller: isiCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Isi Pengumuman',
                  alignLabelWithHint: true,
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
                style: GoogleFonts.outfit(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Simpan Draft',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengumuman berhasil dipublikasikan'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Publikasikan',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
