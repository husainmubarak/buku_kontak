class DataKontak {
  final int id;
  final String nama;
  final String email;
  final String foto;

  DataKontak({
    required this.id,
    required this.nama,
    required this.email,
    required this.foto,
  });

  factory DataKontak.fromJson(Map<String, dynamic> json) {
    return DataKontak(
      id: json['id'],
      nama: json['nama'] ?? 'Tanpa Nama', 
      email: json['email'] ?? 'Tidak ada email',
      foto: json['foto'] ?? 'https://robohash.org/0',
    );
  }
}