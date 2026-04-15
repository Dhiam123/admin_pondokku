import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
//  Data Models – Admin Pondok
// ──────────────────────────────────────────────

enum PaymentStatus { lunas, belumBayar, terlambat, cicilan }
enum AnnouncementType { umum, keuangan, kegiatan, darurat }
enum MessageStatus { read, unread }
enum AbsensiStatus { hadir, izin, sakit, alpha }
enum TopupStatus { menunggu, disetujui, ditolak }
enum InfaqJenis { wajib, sukarela, program }

class Siswa {
  final String id;
  final String nama;
  final String nis;
  final String kelas;
  final String kamar;
  final String namaWali;
  final String noHpWali;
  final String jenisKelamin;
  final String alamat;
  final String tanggalMasuk;
  final String fotoUrl;
  final bool aktif;

  const Siswa({
    required this.id,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.kamar,
    required this.namaWali,
    required this.noHpWali,
    required this.jenisKelamin,
    required this.alamat,
    required this.tanggalMasuk,
    required this.fotoUrl,
    this.aktif = true,
  });
}

class Guru {
  final String id;
  final String nama;
  final String mataPelajaran;
  final String email;
  final String noHp;
  final bool aktif;

  const Guru({
    required this.id,
    required this.nama,
    required this.mataPelajaran,
    required this.email,
    required this.noHp,
    this.aktif = true,
  });
}

class Nilai {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String mataPelajaran;
  final int nilai;
  final String semester;
  final String? keterangan;

  const Nilai({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.mataPelajaran,
    required this.nilai,
    required this.semester,
    this.keterangan,
  });
}

class Tagihan {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String jenis;
  final double jumlah;
  final String bulan;
  final PaymentStatus status;
  final String? tanggalBayar;
  final String? metodeBayar;
  final String? buktiUrl;

  const Tagihan({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.jenis,
    required this.jumlah,
    required this.bulan,
    required this.status,
    this.tanggalBayar,
    this.metodeBayar,
    this.buktiUrl,
  });
}

class Pengumuman {
  final String id;
  final String judul;
  final String isi;
  final AnnouncementType tipe;
  final String tanggal;
  final String penulis;
  final bool published;

  const Pengumuman({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.tanggal,
    required this.penulis,
    required this.published,
  });
}

class Pesan {
  final String id;
  final String dariNama;
  final String dariId;
  final String subjek;
  final String isi;
  final String waktu;
  final MessageStatus status;

  const Pesan({
    required this.id,
    required this.dariNama,
    required this.dariId,
    required this.subjek,
    required this.isi,
    required this.waktu,
    required this.status,
  });
}

class Notifikasi {
  final String id;
  final String judul;
  final String isi;
  final String waktu;
  final bool dibaca;
  final IconData ikon;
  final Color warna;

  const Notifikasi({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.dibaca,
    required this.ikon,
    required this.warna,
  });
}

class BiayaItem {
  final String id;
  final String nama;
  final double jumlah;
  final String kategori;
  final bool aktif;

  const BiayaItem({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.aktif,
  });
}

class Absensi {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String kelas;
  final String tanggal;
  final AbsensiStatus status;
  final String? keterangan;

  const Absensi({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.kelas,
    required this.tanggal,
    required this.status,
    this.keterangan,
  });
}

// ─── Raport / Penilaian ───
class RaportMapel {
  final String mataPelajaran;
  final int nilaiHarian;
  final int nilaiUTS;
  final int nilaiUAS;

  const RaportMapel({
    required this.mataPelajaran,
    required this.nilaiHarian,
    required this.nilaiUTS,
    required this.nilaiUAS,
  });

  int get nilaiAkhir => ((nilaiHarian * 0.3) + (nilaiUTS * 0.3) + (nilaiUAS * 0.4)).round();
}

class Raport {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String kelas;
  final String semester;
  final String tahunAjaran;
  final List<RaportMapel> mapelList;
  final String? catatanWaliKelas;
  final bool published;

  const Raport({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.kelas,
    required this.semester,
    required this.tahunAjaran,
    required this.mapelList,
    this.catatanWaliKelas,
    this.published = false,
  });

  double get rataRata {
    if (mapelList.isEmpty) return 0;
    return mapelList.map((m) => m.nilaiAkhir).reduce((a, b) => a + b) / mapelList.length;
  }
}

// ─── Tabungan & Topup ───
class MutasiTabungan {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String tipe; // 'topup' | 'tarik'
  final double jumlah;
  final TopupStatus status;
  final String tanggal;
  final String? keterangan;
  final String? buktiUrl;

  const MutasiTabungan({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.tipe,
    required this.jumlah,
    required this.status,
    required this.tanggal,
    this.keterangan,
    this.buktiUrl,
  });
}

class TabunganSiswa {
  final String siswaId;
  final String siswaNama;
  final String kelas;
  final double saldo;
  final String lastUpdate;

  const TabunganSiswa({
    required this.siswaId,
    required this.siswaNama,
    required this.kelas,
    required this.saldo,
    required this.lastUpdate,
  });
}

// ─── Infaq ───
class Infaq {
  final String id;
  final String dariNama;
  final String? siswaId;
  final InfaqJenis jenis;
  final double jumlah;
  final String tanggal;
  final String? keterangan;
  final String dicatatOleh;

  const Infaq({
    required this.id,
    required this.dariNama,
    this.siswaId,
    required this.jenis,
    required this.jumlah,
    required this.tanggal,
    this.keterangan,
    required this.dicatatOleh,
  });
}
