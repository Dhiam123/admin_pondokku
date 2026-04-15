import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final _namaCtrl = TextEditingController(text: 'Pondok Pesantren Darussalam');
  final _alamatCtrl = TextEditingController(text: 'Jl. Pondok Pesantren No.1, Surabaya');
  final _teleponCtrl = TextEditingController(text: '031-12345678');
  final _emailCtrl = TextEditingController(text: 'admin@darussalam.ac.id');
  final _websiteCtrl = TextEditingController(text: 'www.darussalam.ac.id');

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _notifTagihan = true;
  bool _notifPesan = true;
  bool _notifPengumuman = false;
  bool _autoReminder = true;

  final List<Map<String, String>> _roles = [
    {
      'id': 'r1',
      'nama': 'Admin',
      'level': 'Super Admin',
      'email': 'admin@darussalam.ac.id',
    },
    {
      'id': 'r2',
      'nama': 'Ustadz Fauzi',
      'level': 'Pengajar',
      'email': 'fauzi@darussalam.ac.id',
    },
  ];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Pengaturan Sistem',
            subtitle: 'Kelola profil pondok, akses admin, dan preferensi sistem',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return isMobile
                  ? Column(
                      children: [
                        _buildProfilPondok(),
                        const SizedBox(height: 20),
                        _buildNotifikasiSettings(),
                        const SizedBox(height: 20),
                        _buildProfilAdmin(),
                        const SizedBox(height: 20),
                        _buildGantiPassword(),
                        const SizedBox(height: 20),
                        _buildRoleManagement(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildProfilPondok(),
                              const SizedBox(height: 20),
                              _buildNotifikasiSettings(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildProfilAdmin(),
                              const SizedBox(height: 20),
                              _buildGantiPassword(),
                              const SizedBox(height: 20),
                              _buildRoleManagement(),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfilPondok() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mosque_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Profil Pondok',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          _formField('Nama Pondok', _namaCtrl, Icons.mosque_rounded),
          const SizedBox(height: 12),
          _formField('Alamat', _alamatCtrl, Icons.location_on_rounded,
              maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _formField('Telepon', _teleponCtrl, Icons.phone_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _formField('Email', _emailCtrl, Icons.email_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          _formField('Website', _websiteCtrl, Icons.language_rounded),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Simpan Perubahan',
              icon: Icons.save_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil pondok berhasil disimpan'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasiSettings() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Preferensi Notifikasi',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _switchRow(
            'Notifikasi Tagihan Baru',
            'Menerima notifikasi saat ada tagihan baru masuk',
            _notifTagihan,
            (v) => setState(() => _notifTagihan = v),
          ),
          const Divider(color: AppColors.border),
          _switchRow(
            'Notifikasi Pesan Masuk',
            'Menerima notifikasi saat ada pesan dari wali/santri',
            _notifPesan,
            (v) => setState(() => _notifPesan = v),
          ),
          const Divider(color: AppColors.border),
          _switchRow(
            'Notifikasi Pengumuman',
            'Menerima reminder saat pengumuman akan kadaluarsa',
            _notifPengumuman,
            (v) => setState(() => _notifPengumuman = v),
          ),
          const Divider(color: AppColors.border),
          _switchRow(
            'Auto-Reminder Tagihan',
            'Kirim otomatis reminder tagihan jatuh tempo ke wali',
            _autoReminder,
            (v) => setState(() => _autoReminder = v),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
      String label, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilAdmin() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.manage_accounts_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Profil Admin',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('A',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text('Admin',
                    style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text('Super Admin',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                const StatusBadge(
                  label: 'Super Admin',
                  color: AppColors.primary,
                  bgColor: AppColors.primarySurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          _detailRow(Icons.email_rounded, 'Email', 'admin@darussalam.ac.id'),
          _detailRow(Icons.access_time_rounded, 'Login Terakhir', '14 Apr 2026, 09:00'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label: ',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: AppColors.textSecondary)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildGantiPassword() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Ganti Password',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          _formField('Password Lama', _oldPassCtrl, Icons.lock_outline_rounded,
              obscure: true),
          const SizedBox(height: 10),
          _formField(
              'Password Baru', _newPassCtrl, Icons.lock_rounded, obscure: true),
          const SizedBox(height: 10),
          _formField('Konfirmasi Password', _confirmPassCtrl,
              Icons.lock_reset_rounded, obscure: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password berhasil diubah'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded, size: 16),
              label: Text('Simpan Password',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleManagement() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: AppColors.success, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Kelola Akses',
                        style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_rounded, size: 18),
                color: AppColors.primary,
                onPressed: () => _showRoleForm(),
                tooltip: 'Tambah Pengguna',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_roles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Belum ada pengguna terdaftar.',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary)),
              ),
            )
          else
            ..._roles.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          (r['nama'] as String)[0],
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['nama'] as String,
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(r['email'] as String,
                                style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: r['level'] as String,
                        color: AppColors.primary,
                        bgColor: AppColors.primarySurface,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        color: AppColors.primary,
                        onPressed: () => _showRoleForm(role: r),
                        tooltip: 'Edit akses',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        color: AppColors.error,
                        onPressed: () => _confirmDeleteRole(r),
                        tooltip: 'Hapus akses',
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _showRoleForm({Map<String, String>? role}) async {
    final isEditing = role != null;
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController(text: role?['nama'] ?? '');
    final emailCtrl = TextEditingController(text: role?['email'] ?? '');
    String selectedLevel = role?['level'] ?? 'Pengajar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEditing ? 'Edit Akses' : 'Tambah Pengguna Baru',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedLevel,
                decoration: InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Super Admin', child: Text('Super Admin')),
                  DropdownMenuItem(value: 'Pengajar', child: Text('Pengajar')),
                  DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                ],
                onChanged: (value) {
                  if (value != null) selectedLevel = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text('Simpan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      final roleId = role?['id'] ?? '';
      setState(() {
        if (isEditing) {
          final index = _roles.indexWhere((item) => item['id'] == roleId);
          if (index >= 0) {
            _roles[index] = {
              'id': roleId,
              'nama': namaCtrl.text.trim(),
              'email': emailCtrl.text.trim(),
              'level': selectedLevel,
            };
          }
        } else {
          _roles.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'nama': namaCtrl.text.trim(),
            'email': emailCtrl.text.trim(),
            'level': selectedLevel,
          });
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Akses berhasil diperbarui' : 'Pengguna baru berhasil ditambahkan'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDeleteRole(Map<String, String> role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Pengguna', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus akses ${role['nama']}?',
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Hapus', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      setState(() => _roles.removeWhere((item) => item['id'] == role['id']));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akses ${role['nama']} berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _formField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int maxLines = 1,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: obscure ? 1 : maxLines,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
          ),
          style: GoogleFonts.outfit(fontSize: 13),
        ),
      ],
    );
  }
}
