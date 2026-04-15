import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

enum SidebarItem {
  dashboard,
  // Master Data
  siswa,
  database,
  // Akademik
  absensi,
  raport,
  // Keuangan
  tagihan,
  tabungan,
  infaq,
  // Komunikasi
  pengumuman,
  pesan,
  // Settings
  pengaturan,
}

class _NavGroup {
  final String label;
  final List<_NavItem> items;
  const _NavGroup(this.label, this.items);
}

class _NavItem {
  final IconData icon;
  final String label;
  final SidebarItem page;
  const _NavItem(this.icon, this.label, this.page);
}

class AdminSidebar extends StatefulWidget {
  final SidebarItem selected;
  final void Function(SidebarItem) onSelected;
  final VoidCallback? onLogout;
  final bool collapsed;

  const AdminSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.onLogout,
    this.collapsed = false,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static final _groups = [
    const _NavGroup('', [
      _NavItem(Icons.dashboard_rounded, 'Dashboard', SidebarItem.dashboard),
    ]),
    const _NavGroup('MASTER DATA', [
      _NavItem(Icons.people_alt_rounded, 'Data Siswa', SidebarItem.siswa),
      _NavItem(Icons.storage_rounded, 'Database', SidebarItem.database),
    ]),
    const _NavGroup('AKADEMIK', [
      _NavItem(Icons.fact_check_rounded, 'Absensi', SidebarItem.absensi),
      _NavItem(Icons.school_rounded, 'Raport & Penilaian', SidebarItem.raport),
    ]),
    const _NavGroup('KEUANGAN', [
      _NavItem(Icons.receipt_long_rounded, 'Tagihan & Cicilan', SidebarItem.tagihan),
      _NavItem(Icons.savings_rounded, 'Tabungan & Top-Up', SidebarItem.tabungan),
      _NavItem(Icons.volunteer_activism_rounded, 'Donasi & Infaq', SidebarItem.infaq),
    ]),
    const _NavGroup('KOMUNIKASI', [
      _NavItem(Icons.campaign_rounded, 'Pengumuman', SidebarItem.pengumuman),
      _NavItem(Icons.inbox_rounded, 'Pesan Masuk', SidebarItem.pesan),
    ]),
    const _NavGroup('SISTEM', [
      _NavItem(Icons.settings_rounded, 'Pengaturan', SidebarItem.pengaturan),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(AdminSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapsed != widget.collapsed) {
      if (!widget.collapsed) {
        _animCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.collapsed ? 68.0 : 242.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: w,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 14,
            offset: Offset(2, 0),
          )
        ],
      ),
      child: Column(
        children: [
          // ─── Logo ───
          _buildLogo(),

          // ─── Nav ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: _groups
                  .expand((group) => [
                        if (group.label.isNotEmpty && !widget.collapsed)
                          _buildSectionLabel(group.label),
                        ...group.items.map((item) => _buildNavTile(item)),
                      ])
                  .toList(),
            ),
          ),

          // ─── User + Logout ───
          _buildUserSection(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: const Center(
              child: Text('☪', style: TextStyle(fontSize: 20)),
            ),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN PONDOK',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Pesantren Darussalam',
                      style: GoogleFonts.outfit(
                        color: AppColors.sidebarText,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 8, 6),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: AppColors.sidebarText.withValues(alpha: 0.5),
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavTile(_NavItem item) {
    final isSelected = widget.selected == item.page;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.sidebarHover,
          splashColor: AppColors.primary.withValues(alpha: 0.3),
          onTap: () => widget.onSelected(item.page),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 10,
            ),
            child: widget.collapsed
                ? Tooltip(
                    message: item.label,
                    preferBelow: false,
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: isSelected ? Colors.white : AppColors.sidebarText,
                        size: 22,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: isSelected
                            ? BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Icon(
                          item.icon,
                          color: isSelected ? Colors.white : AppColors.sidebarText,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : AppColors.sidebarText,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                )
              ],
            ),
            child: const Center(
              child: Text('A',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                  Text('Super Admin',
                      style: GoogleFonts.outfit(
                        color: AppColors.sidebarText,
                        fontSize: 11,
                      )),
                ],
              ),
            ),
            if (widget.onLogout != null)
              InkWell(
                onTap: widget.onLogout,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppColors.sidebarText, size: 17),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
