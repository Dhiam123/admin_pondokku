import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

// ─────────────────────────────────────
//  Reusable Stat Card
// ─────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? trend;
  final bool? trendUp;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (trend != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (trendUp ?? true)
                    ? AppColors.successSurface
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (trendUp ?? true)
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 12,
                    color: (trendUp ?? true)
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend!,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: (trendUp ?? true)
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
//  Section Header
// ─────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ─────────────────────────────────────
//  Status Badge
// ─────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────
//  Admin Top AppBar
// ─────────────────────────────────────

enum _TopBarMenuAction { profile, logout }

class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;
  final int unreadMessages;
  final int unreadNotifs;
  final VoidCallback onToggleSidebar;
  final VoidCallback? onNotifTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;

  const AdminTopBar({
    super.key,
    required this.pageTitle,
    this.unreadMessages = 0,
    this.unreadNotifs = 0,
    required this.onToggleSidebar,
    this.onNotifTap,
    this.onMessageTap,
    this.onProfileTap,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSearch = constraints.maxWidth > 760;

        return Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              IconButton(
                onPressed: onToggleSidebar,
                icon: const Icon(Icons.menu_rounded),
                color: AppColors.textSecondary,
                tooltip: 'Toggle sidebar',
              ),
              const SizedBox(width: 8),
              Text(
                pageTitle,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 24),
              if (showSearch) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Container(
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
                        Text('Cari...',
                            style: GoogleFonts.outfit(
                                fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              _buildIconBadge(Icons.notifications_rounded, unreadNotifs, onNotifTap),
              const SizedBox(width: 8),
              _buildIconBadge(Icons.message_rounded, unreadMessages, onMessageTap),
              const SizedBox(width: 16),
              PopupMenuButton<_TopBarMenuAction>(
                tooltip: 'Akun admin',
                onSelected: (action) {
                  switch (action) {
                    case _TopBarMenuAction.profile:
                      if (onProfileTap != null) onProfileTap!();
                      break;
                    case _TopBarMenuAction.logout:
                      if (onLogout != null) onLogout!();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _TopBarMenuAction.profile,
                    child: ListTile(
                      leading: Icon(Icons.person_rounded),
                      title: Text('Masuk ke profil'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: _TopBarMenuAction.logout,
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded),
                      title: Text('Logout'),
                    ),
                  ),
                ],
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Center(
                    child: Text('A',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconBadge(IconData icon, int count, VoidCallback? onTap) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: AppColors.textSecondary,
          iconSize: 22,
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────
//  Card Container
// ─────────────────────────────────────
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AdminCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────
//  Primary Button
// ─────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool small;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.add_rounded, size: small ? 16 : 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
            horizontal: small ? 14 : 18, vertical: small ? 8 : 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.outfit(
            fontSize: small ? 13 : 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────
//  Empty State
// ─────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.outfit(
                  fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
