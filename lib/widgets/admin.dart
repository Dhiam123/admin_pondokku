import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/models/models.dart';
import '../pages/dashboard_page.dart';
import '../pages/manajemen_siswa_page.dart';
import '../pages/keuangan_page.dart';
import '../pages/pengumuman_page.dart';
import '../pages/pesan_page.dart';
import '../pages/pengaturan_page.dart';
import '../pages/absensi_page.dart';
import '../pages/database_page.dart';
import '../pages/raport_page.dart';
import '../pages/tabungan_page.dart';
import '../pages/infaq_page.dart';
import 'sidebar.dart';
import 'common_widgets.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SidebarItem _current = SidebarItem.dashboard;
  bool _sidebarCollapsed = false;

  final _pageTitles = {
    SidebarItem.dashboard: 'Dashboard',
    SidebarItem.siswa: 'Manajemen Siswa',
    SidebarItem.database: 'Database Akademik',
    SidebarItem.absensi: 'Manajemen Absensi',
    SidebarItem.raport: 'Raport & Penilaian',
    SidebarItem.tagihan: 'Tagihan & Cicilan',
    SidebarItem.tabungan: 'Tabungan & Top-Up',
    SidebarItem.infaq: 'Donasi & Infaq',
    SidebarItem.pengumuman: 'Pengumuman',
    SidebarItem.pesan: 'Pesan Masuk',
    SidebarItem.pengaturan: 'Pengaturan',
  };

  int get _unreadMessages =>
      DummyData.pesanList.where((m) => m.status == MessageStatus.unread).length;

  int get _unreadNotifs =>
      DummyData.notifikasiList.where((n) => !n.dibaca).length;

  int get _pendingTopup =>
      DummyData.mutasiList.where((m) => m.status == TopupStatus.menunggu).length;

  Widget _currentPage() {
    switch (_current) {
      case SidebarItem.dashboard:
        return const DashboardPage();
      case SidebarItem.siswa:
        return const ManajemenSiswaPage();
      case SidebarItem.database:
        return const DatabasePage();
      case SidebarItem.absensi:
        return const AbsensiPage();
      case SidebarItem.raport:
        return const RaportPage();
      case SidebarItem.tagihan:
        return const KeuanganPage();
      case SidebarItem.tabungan:
        return const TabunganPage();
      case SidebarItem.infaq:
        return const InfaqPage();
      case SidebarItem.pengumuman:
        return const PengumumanPage();
      case SidebarItem.pesan:
        return const PesanPage();
      case SidebarItem.pengaturan:
        return const PengaturanPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          key: _scaffoldKey,
          drawer: isMobile
              ? AdminSidebar(
                  selected: _current,
                  onSelected: (item) {
                    setState(() => _current = item);
                    Navigator.of(context).pop();
                  },
                  onLogout: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  collapsed: false,
                )
              : null,
          body: isMobile
              ? Column(
                  children: [
                    AdminTopBar(
                      pageTitle: _pageTitles[_current] ?? '',
                      unreadMessages: _unreadMessages,
                      unreadNotifs: _unreadNotifs,
                      onToggleSidebar: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      onNotifTap: () => _showNotifPanel(context),
                      onMessageTap: () =>
                          setState(() => _current = SidebarItem.pesan),
                      onProfileTap: () =>
                          setState(() => _current = SidebarItem.pengaturan),
                      onLogout: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(_current),
                          child: _currentPage(),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    AdminSidebar(
                      selected: _current,
                      onSelected: (item) => setState(() => _current = item),
                      onLogout: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                      collapsed: _sidebarCollapsed,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AdminTopBar(
                            pageTitle: _pageTitles[_current] ?? '',
                            unreadMessages: _unreadMessages,
                            unreadNotifs: _unreadNotifs,
                            onToggleSidebar: () => setState(
                                () => _sidebarCollapsed = !_sidebarCollapsed),
                            onNotifTap: () => _showNotifPanel(context),
                            onMessageTap: () =>
                                setState(() => _current = SidebarItem.pesan),
                            onProfileTap: () =>
                                setState(() => _current = SidebarItem.pengaturan),
                            onLogout: () => Navigator.of(context)
                                .pushReplacementNamed('/login'),
                          ),
                          // Pending topup alert bar
                          if (_pendingTopup > 0)
                            _buildAlertBar(),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: KeyedSubtree(
                                key: ValueKey(_current),
                                child: _currentPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAlertBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: AppColors.warningSurface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$_pendingTopup permintaan Top-Up tabungan menunggu verifikasi Anda.',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _current = SidebarItem.tabungan),
            child: Text('Verifikasi Sekarang →',
                style: GoogleFonts.outfit(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _showNotifPanel(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 64, right: 16),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            child: Container(
              width: 340,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text('Notifikasi',
                            style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text('Tandai semua dibaca',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ...DummyData.notifikasiList.map((n) => _notifItem(n)),
                  const Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Tutup',
                          style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifItem(Notifikasi n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: n.dibaca ? null : n.warna.withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: n.warna.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(n.ikon, size: 18, color: n.warna),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.judul,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight:
                            n.dibaca ? FontWeight.w500 : FontWeight.w700)),
                Text(n.isi,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(n.waktu,
                    style: GoogleFonts.outfit(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (!n.dibaca)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration:
                  BoxDecoration(color: n.warna, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
