import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../widgets/common_widgets.dart';

class PesanPage extends StatefulWidget {
  const PesanPage({super.key});

  @override
  State<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  Pesan? _selected;
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = DummyData.pesanList
        .where((m) => m.status == MessageStatus.unread)
        .length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inbox list
        Container(
          width: 340,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Pesan Masuk',
                            style: GoogleFonts.outfit(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$unread baru',
                                style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(Icons.search_rounded,
                              size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Text('Cari pesan...',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.pesanList.length,
                  itemBuilder: (_, i) => _inboxItem(DummyData.pesanList[i]),
                ),
              ),
            ],
          ),
        ),

        // Chat / Detail area
        Expanded(
          child: _selected == null
              ? const Center(
                  child: EmptyState(
                    message: 'Pilih pesan untuk membaca',
                    icon: Icons.inbox_rounded,
                  ),
                )
              : _buildChatView(_selected!),
        ),
      ],
    );
  }

  Widget _inboxItem(Pesan m) {
    final isSelected = _selected?.id == m.id;
    final isUnread = m.status == MessageStatus.unread;

    return GestureDetector(
      onTap: () => setState(() => _selected = m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : isUnread
                  ? AppColors.infoSurface.withOpacity(0.5)
                  : Colors.transparent,
          border: const Border(
              bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isUnread
                      ? AppColors.primarySurface
                      : AppColors.surfaceVariant,
                  child: Text(
                    m.dariNama[0],
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isUnread ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
                if (isUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.dariNama,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(m.waktu,
                          style: GoogleFonts.outfit(
                              fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(m.subjek,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(m.isi,
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(Pesan m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  m.dariNama[0],
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.dariNama,
                        style: GoogleFonts.outfit(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(m.subjek,
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Row(
                children: [
                  _actionBtn(Icons.archive_rounded, 'Arsipkan', AppColors.textSecondary),
                  const SizedBox(width: 4),
                  _actionBtn(Icons.delete_rounded, 'Hapus', AppColors.error),
                ],
              ),
            ],
          ),
        ),

        // Messages area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Received message
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          m.dariNama[0],
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.isi,
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      height: 1.5)),
                              const SizedBox(height: 6),
                              Text(m.waktu,
                                  style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Admin reply sample
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Baik, sudah kami terima dan cek konfirmasinya. Terima kasih.',
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: Colors.white,
                                    height: 1.5),
                              ),
                              const SizedBox(height: 6),
                              Text('Admin · 5 menit lalu',
                                  style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: Text('A',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Reply input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis balasan...',
                    hintStyle: GoogleFonts.outfit(
                        fontSize: 13, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  style: GoogleFonts.outfit(fontSize: 13),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: () {
                    if (_replyCtrl.text.trim().isNotEmpty) {
                      _replyCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Balasan terkirim'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String tooltip, Color color) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
    );
  }
}
