class DataKontak {
  final int id;
  final String namaDepan;
  final String namaBelakang;
  final String email;
  final String avatar;

  DataKontak({
    required this.id,
    required this.namaDepan,
    required this.namaBelakang,
    required this.email,
    required this.avatar,
  });

  factory DataKontak.fromJson(Map<String, dynamic> json) {
    return DataKontak(
      id: json['id'],
      namaDepan: json['first_name'],
      namaBelakang: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}