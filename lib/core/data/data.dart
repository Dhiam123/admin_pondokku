import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';

// Dummy data provider
class DummyData {
  static final List<Siswa> siswaList = [
    const Siswa(id: '1', nama: 'Ahmad Fauzi', nis: '2024001', kelas: 'Kelas 1 Ula', kamar: 'Kamar A1', namaWali: 'Bapak Hasan', noHpWali: '08123456789', jenisKelamin: 'L', alamat: 'Jl. Mawar No.5, Surabaya', tanggalMasuk: '2024-07-01', fotoUrl: '', aktif: true),
    const Siswa(id: '2', nama: 'Muhammad Rizki', nis: '2024002', kelas: 'Kelas 2 Ula', kamar: 'Kamar A2', namaWali: 'Ibu Sari', noHpWali: '08198765432', jenisKelamin: 'L', alamat: 'Jl. Melati No.3, Malang', tanggalMasuk: '2024-07-01', fotoUrl: '', aktif: true),
    const Siswa(id: '3', nama: 'Fatimah Azzahra', nis: '2024003', kelas: 'Kelas 1 Ula', kamar: 'Kamar B1', namaWali: 'Bapak Ali', noHpWali: '08111222333', jenisKelamin: 'P', alamat: 'Jl. Anggrek No.7, Sidoarjo', tanggalMasuk: '2024-07-15', fotoUrl: '', aktif: true),
    const Siswa(id: '4', nama: 'Siti Khadijah', nis: '2024004', kelas: 'Kelas 3 Ula', kamar: 'Kamar B2', namaWali: 'Ibu Rina', noHpWali: '08155667788', jenisKelamin: 'P', alamat: 'Jl. Dahlia No.12, Gresik', tanggalMasuk: '2023-07-01', fotoUrl: '', aktif: true),
    const Siswa(id: '5', nama: 'Umar Al-Faruq', nis: '2024005', kelas: 'Kelas 2 Tsanawiyah', kamar: 'Kamar C1', namaWali: 'Bapak Ridwan', noHpWali: '08177889900', jenisKelamin: 'L', alamat: 'Jl. Kenanga No.9, Lamongan', tanggalMasuk: '2022-07-01', fotoUrl: '', aktif: true),
    const Siswa(id: '6', nama: 'Aisyah Nur', nis: '2024006', kelas: 'Kelas 1 Tsanawiyah', kamar: 'Kamar B3', namaWali: 'Ibu Dewi', noHpWali: '08199001122', jenisKelamin: 'P', alamat: 'Jl. Tulip No.2, Pasuruan', tanggalMasuk: '2023-07-01', fotoUrl: '', aktif: false),
    const Siswa(id: '7', nama: 'Ibrahim Al-Khayyat', nis: '2024007', kelas: 'Kelas 3 Tsanawiyah', kamar: 'Kamar C2', namaWali: 'Bapak Joko', noHpWali: '08133445566', jenisKelamin: 'L', alamat: 'Jl. Mawar No.15, Mojokerto', tanggalMasuk: '2021-07-01', fotoUrl: '', aktif: true),
    const Siswa(id: '8', nama: 'Zainab Hasanah', nis: '2024008', kelas: 'Kelas 2 Ula', kamar: 'Kamar B4', namaWali: 'Ibu Fatimah', noHpWali: '08166778899', jenisKelamin: 'P', alamat: 'Jl. Semeru No.4, Blitar', tanggalMasuk: '2024-01-15', fotoUrl: '', aktif: true),
  ];

  static final List<Tagihan> tagihanList = [
    const Tagihan(id: 't1', siswaId: '1', siswaNama: 'Ahmad Fauzi', jenis: 'Syahriyah', jumlah: 350000, bulan: 'April 2026', status: PaymentStatus.lunas, tanggalBayar: '2026-04-02', metodeBayar: 'Transfer Bank'),
    const Tagihan(id: 't2', siswaId: '2', siswaNama: 'Muhammad Rizki', jenis: 'Syahriyah', jumlah: 350000, bulan: 'April 2026', status: PaymentStatus.belumBayar),
    const Tagihan(id: 't3', siswaId: '3', siswaNama: 'Fatimah Azzahra', jenis: 'Syahriyah', jumlah: 350000, bulan: 'April 2026', status: PaymentStatus.lunas, tanggalBayar: '2026-04-05', metodeBayar: 'Cash'),
    const Tagihan(id: 't4', siswaId: '4', siswaNama: 'Siti Khadijah', jenis: 'Admin', jumlah: 150000, bulan: 'April 2026', status: PaymentStatus.terlambat),
    const Tagihan(id: 't5', siswaId: '5', siswaNama: 'Umar Al-Faruq', jenis: 'Syahriyah', jumlah: 350000, bulan: 'April 2026', status: PaymentStatus.lunas, tanggalBayar: '2026-04-10', metodeBayar: 'Transfer Bank'),
    const Tagihan(id: 't6', siswaId: '6', siswaNama: 'Aisyah Nur', jenis: 'Admin', jumlah: 150000, bulan: 'Maret 2026', status: PaymentStatus.terlambat),
    const Tagihan(id: 't7', siswaId: '7', siswaNama: 'Ibrahim Al-Khayyat', jenis: 'Syahriyah', jumlah: 350000, bulan: 'April 2026', status: PaymentStatus.cicilan),
    const Tagihan(id: 't8', siswaId: '8', siswaNama: 'Zainab Hasanah', jenis: 'Syahriyah', jumlah: 350000, bulan: 'April 2026', status: PaymentStatus.lunas, tanggalBayar: '2026-04-08', metodeBayar: 'Cash'),
  ];

  static final List<Pengumuman> pengumumanList = [
    const Pengumuman(id: 'p1', judul: 'Jadwal Ujian Tengah Semester', isi: 'Disampaikan kepada seluruh santri bahwa ujian tengah semester akan dilaksanakan pada tanggal 20–25 April 2026. Mohon mempersiapkan diri dengan baik dan menjaga ketertiban selama ujian berlangsung.', tipe: AnnouncementType.kegiatan, tanggal: '2026-04-12', penulis: 'Admin', published: true),
    const Pengumuman(id: 'p2', judul: 'Batas Akhir Pembayaran Syahriyah April', isi: 'Diberitahukan batas akhir pembayaran syahriyah bulan April adalah tanggal 15 April 2026. Bagi yang belum membayar harap segera melunasi agar tidak dikenakan denda.', tipe: AnnouncementType.keuangan, tanggal: '2026-04-10', penulis: 'Admin', published: true),
    const Pengumuman(id: 'p3', judul: 'Kegiatan Haul Akbar Pondok', isi: 'Seluruh santri wajib mengikuti kegiatan Haul Akbar yang akan dilaksanakan pada Senin, 20 April 2026 pukul 08.00 WIB di Aula Utama Pondok.', tipe: AnnouncementType.kegiatan, tanggal: '2026-04-08', penulis: 'Admin', published: true),
    const Pengumuman(id: 'p4', judul: 'Pemadaman Listrik Sementara', isi: 'Akan ada pemadaman listrik pada hari Sabtu, 18 April 2026 dari pukul 08.00–12.00 WIB untuk keperluan pemeliharaan instalasi. Mohon maaf atas ketidaknyamanan.', tipe: AnnouncementType.darurat, tanggal: '2026-04-07', penulis: 'Admin', published: false),
  ];

  static final List<Pesan> pesanList = [
    const Pesan(id: 'm1', dariNama: 'Bapak Hasan (Wali Ahmad Fauzi)', dariId: '1', subjek: 'Konfirmasi Pembayaran', isi: 'Assalamu\'alaikum, saya ingin mengkonfirmasi bahwa sudah mentransfer biaya syahriyah untuk Ahmad Fauzi. Mohon dicek ya Pak/Bu.', waktu: '10 menit lalu', status: MessageStatus.unread),
    const Pesan(id: 'm2', dariNama: 'Ibu Sari (Wali M. Rizki)', dariId: '2', subjek: 'Izin Pulang', isi: 'Mohon izin, Muhammad Rizki akan pulang tanggal 16-18 April 2026 untuk keperluan keluarga. Terima kasih.', waktu: '1 jam lalu', status: MessageStatus.unread),
    const Pesan(id: 'm3', dariNama: 'Bapak Ali (Wali Fatimah)', dariId: '3', subjek: 'Tanya Info Raport', isi: 'Assalamu\'alaikum, kapan pembagian raport semester ini? Dan apakah bisa diambil oleh wali? Terima kasih.', waktu: '3 jam lalu', status: MessageStatus.read),
    const Pesan(id: 'm4', dariNama: 'Ibu Rina (Wali Siti Khadijah)', dariId: '4', subjek: 'Keluhan Kamar', isi: 'Ada masalah dengan fasilitas kamar B2, kipas angin rusak sejak seminggu lalu. Mohon segera diperbaiki.', waktu: 'Kemarin', status: MessageStatus.read),
  ];

  static final List<Notifikasi> notifikasiList = [
    const Notifikasi(id: 'n1', judul: 'Pembayaran Baru Masuk', isi: 'Ahmad Fauzi telah melakukan pembayaran syahriyah April', waktu: '10 menit lalu', dibaca: false, ikon: Icons.payment_rounded, warna: AppColors.success),
    const Notifikasi(id: 'n2', judul: 'Pesan Baru', isi: 'Ibu Sari mengirim pesan tentang izin pulang', waktu: '1 jam lalu', dibaca: false, ikon: Icons.message_rounded, warna: AppColors.info),
    const Notifikasi(id: 'n3', judul: 'Tagihan Jatuh Tempo', isi: '3 siswa memiliki tagihan yang belum dibayar', waktu: '2 jam lalu', dibaca: true, ikon: Icons.warning_rounded, warna: AppColors.warning),
    const Notifikasi(id: 'n4', judul: 'Pengumuman Dipublikasikan', isi: 'Pengumuman "Jadwal UTS" telah berhasil dipublikasikan', waktu: 'Kemarin', dibaca: true, ikon: Icons.campaign_rounded, warna: AppColors.primary),
  ];

  static final List<BiayaItem> biayaList = [
    const BiayaItem(id: 'b1', nama: 'Syahriyah', jumlah: 350000, kategori: 'Bulanan', aktif: true),
    const BiayaItem(id: 'b2', nama: 'Biaya Admin', jumlah: 150000, kategori: 'Bulanan', aktif: true),
    const BiayaItem(id: 'b3', nama: 'Biaya Masuk / Pendaftaran', jumlah: 500000, kategori: 'Sekali', aktif: true),
    const BiayaItem(id: 'b4', nama: 'Tabungan', jumlah: 50000, kategori: 'Bulanan', aktif: true),
    const BiayaItem(id: 'b5', nama: 'Denda Terlambat', jumlah: 25000, kategori: 'Per Hari', aktif: false),
  ];

  static const double saldoKeseluruhan = 12500000;
  static const double saldoInfaq = 3250000;
  static const double saldoOperasional = 6200000;

  static final List<Guru> guruList = [
    const Guru(id: 'g1', nama: 'Ustadz Fauzi', mataPelajaran: 'Bahasa Arab', email: 'fauzi@darussalam.ac.id', noHp: '081234567890'),
    const Guru(id: 'g2', nama: 'Ustadzah Siti', mataPelajaran: 'Matematika', email: 'siti@darussalam.ac.id', noHp: '08133112233'),
    const Guru(id: 'g3', nama: 'Ustadz Hadi', mataPelajaran: 'Sejarah Islam', email: 'hadi@darussalam.ac.id', noHp: '08144556677'),
    const Guru(id: 'g4', nama: 'Ustadzah Rina', mataPelajaran: 'Bahasa Indonesia', email: 'rina@darussalam.ac.id', noHp: '08199887766'),
  ];

  static final List<Nilai> nilaiList = [
    const Nilai(id: 'n1', siswaId: '1', siswaNama: 'Ahmad Fauzi', mataPelajaran: 'Al-Qur`an', nilai: 88, semester: 'Genap 2026'),
    const Nilai(id: 'n2', siswaId: '2', siswaNama: 'Muhammad Rizki', mataPelajaran: 'Matematika', nilai: 82, semester: 'Genap 2026'),
    const Nilai(id: 'n3', siswaId: '3', siswaNama: 'Fatimah Azzahra', mataPelajaran: 'Bahasa Indonesia', nilai: 91, semester: 'Genap 2026'),
    const Nilai(id: 'n4', siswaId: '4', siswaNama: 'Siti Khadijah', mataPelajaran: 'Sejarah Islam', nilai: 75, semester: 'Genap 2026'),
  ];

  static final List<Absensi> absensiList = [
    const Absensi(id: 'a1', siswaId: '1', siswaNama: 'Ahmad Fauzi', kelas: 'Kelas 1 Ula', tanggal: '2026-04-14', status: AbsensiStatus.hadir),
    const Absensi(id: 'a2', siswaId: '2', siswaNama: 'Muhammad Rizki', kelas: 'Kelas 2 Ula', tanggal: '2026-04-14', status: AbsensiStatus.izin, keterangan: 'Acara keluarga'),
    const Absensi(id: 'a3', siswaId: '3', siswaNama: 'Fatimah Azzahra', kelas: 'Kelas 1 Ula', tanggal: '2026-04-14', status: AbsensiStatus.hadir),
    const Absensi(id: 'a4', siswaId: '4', siswaNama: 'Siti Khadijah', kelas: 'Kelas 3 Ula', tanggal: '2026-04-14', status: AbsensiStatus.sakit, keterangan: 'Demam'),
    const Absensi(id: 'a5', siswaId: '5', siswaNama: 'Umar Al-Faruq', kelas: 'Kelas 2 Tsanawiyah', tanggal: '2026-04-14', status: AbsensiStatus.hadir),
    const Absensi(id: 'a6', siswaId: '6', siswaNama: 'Aisyah Nur', kelas: 'Kelas 1 Tsanawiyah', tanggal: '2026-04-14', status: AbsensiStatus.alpha),
    const Absensi(id: 'a7', siswaId: '7', siswaNama: 'Ibrahim Al-Khayyat', kelas: 'Kelas 3 Tsanawiyah', tanggal: '2026-04-14', status: AbsensiStatus.hadir),
    const Absensi(id: 'a8', siswaId: '8', siswaNama: 'Zainab Hasanah', kelas: 'Kelas 2 Ula', tanggal: '2026-04-14', status: AbsensiStatus.hadir),
  ];

  // ─── Raport dummy data ───
  static final List<Raport> raportList = [
    const Raport(
      id: 'r1', siswaId: '1', siswaNama: 'Ahmad Fauzi', kelas: 'Kelas 1 Ula',
      semester: 'Genap', tahunAjaran: '2025/2026', published: true,
      catatanWaliKelas: 'Santri aktif dan disiplin, perlu ditingkatkan kemampuan Bahasa Arab.',
      mapelList: [
        RaportMapel(mataPelajaran: 'Al-Qur\'an & Tajwid', nilaiHarian: 88, nilaiUTS: 85, nilaiUAS: 90),
        RaportMapel(mataPelajaran: 'Bahasa Arab', nilaiHarian: 75, nilaiUTS: 70, nilaiUAS: 78),
        RaportMapel(mataPelajaran: 'Fiqih', nilaiHarian: 82, nilaiUTS: 80, nilaiUAS: 85),
        RaportMapel(mataPelajaran: 'Akidah Akhlaq', nilaiHarian: 90, nilaiUTS: 88, nilaiUAS: 92),
        RaportMapel(mataPelajaran: 'Nahwu Shorof', nilaiHarian: 72, nilaiUTS: 68, nilaiUAS: 74),
      ],
    ),
    const Raport(
      id: 'r2', siswaId: '2', siswaNama: 'Muhammad Rizki', kelas: 'Kelas 2 Ula',
      semester: 'Genap', tahunAjaran: '2025/2026', published: true,
      catatanWaliKelas: 'Perkembangan baik, perlu konsistensi dalam hafalan.',
      mapelList: [
        RaportMapel(mataPelajaran: 'Al-Qur\'an & Tajwid', nilaiHarian: 80, nilaiUTS: 78, nilaiUAS: 82),
        RaportMapel(mataPelajaran: 'Bahasa Arab', nilaiHarian: 85, nilaiUTS: 83, nilaiUAS: 87),
        RaportMapel(mataPelajaran: 'Fiqih', nilaiHarian: 77, nilaiUTS: 75, nilaiUAS: 80),
        RaportMapel(mataPelajaran: 'Akidah Akhlaq', nilaiHarian: 85, nilaiUTS: 82, nilaiUAS: 88),
        RaportMapel(mataPelajaran: 'Nahwu Shorof', nilaiHarian: 78, nilaiUTS: 76, nilaiUAS: 80),
      ],
    ),
    const Raport(
      id: 'r3', siswaId: '3', siswaNama: 'Fatimah Azzahra', kelas: 'Kelas 1 Ula',
      semester: 'Genap', tahunAjaran: '2025/2026', published: false,
      mapelList: [
        RaportMapel(mataPelajaran: 'Al-Qur\'an & Tajwid', nilaiHarian: 92, nilaiUTS: 90, nilaiUAS: 95),
        RaportMapel(mataPelajaran: 'Bahasa Arab', nilaiHarian: 88, nilaiUTS: 85, nilaiUAS: 90),
        RaportMapel(mataPelajaran: 'Fiqih', nilaiHarian: 90, nilaiUTS: 87, nilaiUAS: 91),
        RaportMapel(mataPelajaran: 'Akidah Akhlaq', nilaiHarian: 94, nilaiUTS: 92, nilaiUAS: 96),
        RaportMapel(mataPelajaran: 'Nahwu Shorof', nilaiHarian: 85, nilaiUTS: 82, nilaiUAS: 87),
      ],
    ),
  ];

  // ─── Tabungan dummy data ───
  static final List<TabunganSiswa> tabunganSiswaList = [
    const TabunganSiswa(siswaId: '1', siswaNama: 'Ahmad Fauzi', kelas: 'Kelas 1 Ula', saldo: 250000, lastUpdate: '2026-04-10'),
    const TabunganSiswa(siswaId: '2', siswaNama: 'Muhammad Rizki', kelas: 'Kelas 2 Ula', saldo: 175000, lastUpdate: '2026-04-08'),
    const TabunganSiswa(siswaId: '3', siswaNama: 'Fatimah Azzahra', kelas: 'Kelas 1 Ula', saldo: 420000, lastUpdate: '2026-04-12'),
    const TabunganSiswa(siswaId: '4', siswaNama: 'Siti Khadijah', kelas: 'Kelas 3 Ula', saldo: 80000, lastUpdate: '2026-03-25'),
    const TabunganSiswa(siswaId: '5', siswaNama: 'Umar Al-Faruq', kelas: 'Kelas 2 Tsanawiyah', saldo: 550000, lastUpdate: '2026-04-11'),
  ];

  static final List<MutasiTabungan> mutasiList = [
    const MutasiTabungan(id: 'mt1', siswaId: '1', siswaNama: 'Ahmad Fauzi', tipe: 'topup', jumlah: 100000, status: TopupStatus.menunggu, tanggal: '2026-04-15', keterangan: 'Topup via transfer BCA'),
    const MutasiTabungan(id: 'mt2', siswaId: '3', siswaNama: 'Fatimah Azzahra', tipe: 'topup', jumlah: 200000, status: TopupStatus.menunggu, tanggal: '2026-04-14', keterangan: 'Transfer Mandiri'),
    const MutasiTabungan(id: 'mt3', siswaId: '5', siswaNama: 'Umar Al-Faruq', tipe: 'tarik', jumlah: 50000, status: TopupStatus.disetujui, tanggal: '2026-04-11', keterangan: 'Tarik tunai kebutuhan pribadi'),
    const MutasiTabungan(id: 'mt4', siswaId: '2', siswaNama: 'Muhammad Rizki', tipe: 'topup', jumlah: 75000, status: TopupStatus.ditolak, tanggal: '2026-04-09', keterangan: 'Bukti tidak valid'),
  ];

  // ─── Infaq dummy data ───
  static final List<Infaq> infaqList = [
    const Infaq(id: 'i1', dariNama: 'Bapak Hasan (Wali Ahmad Fauzi)', siswaId: '1', jenis: InfaqJenis.wajib, jumlah: 50000, tanggal: '2026-04-10', dicatatOleh: 'Admin', keterangan: 'Infaq Jum\'at rutin'),
    const Infaq(id: 'i2', dariNama: 'Ibu Dewi (Umum)', jenis: InfaqJenis.sukarela, jumlah: 200000, tanggal: '2026-04-07', dicatatOleh: 'Admin', keterangan: 'Donasi pembangunan masjid'),
    const Infaq(id: 'i3', dariNama: 'Bapak Ali (Wali Fatimah)', siswaId: '3', jenis: InfaqJenis.program, jumlah: 150000, tanggal: '2026-04-05', dicatatOleh: 'Admin', keterangan: 'Program beasiswa'),
    const Infaq(id: 'i4', dariNama: 'Ibu Sari (Wali M. Rizki)', siswaId: '2', jenis: InfaqJenis.wajib, jumlah: 50000, tanggal: '2026-04-03', dicatatOleh: 'Admin'),
    const Infaq(id: 'i5', dariNama: 'Bapak Ridwan (Wali Umar)', siswaId: '5', jenis: InfaqJenis.sukarela, jumlah: 500000, tanggal: '2026-03-28', dicatatOleh: 'Admin', keterangan: 'Wakaf Al-Qur\'an'),
  ];
}
