import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_kontak.dart';
import 'halaman_detail.dart';
import 'halaman_tambah_kontak.dart';

class HalamanUtama extends StatefulWidget {
  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<DataKontak> daftarKontak = [];
  List<String> daftarIdFavorit = [];
  String kataKunci = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ambilDataDariInternet();
    bacaDaftarIdFavorit();
  }

  void urutkanKontak() {
    daftarKontak.sort((a, b) {
      bool aFavorit = daftarIdFavorit.contains(a.id.toString());
      bool bFavorit = daftarIdFavorit.contains(b.id.toString());

      if (aFavorit && !bFavorit) {
        return -1;
      } else if (!aFavorit && bFavorit) {
        return 1;
      } else {
        return a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
      }
    });
  }

  Future<void> ambilDataDariInternet() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await Supabase.instance.client.from('kontak').select();
      setState(() {
        daftarKontak = data.map((item) => DataKontak.fromJson(item)).toList();
      });
      urutkanKontak();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal narik data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void konfirmasiHapus(DataKontak kontak) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Kontak?'),
        content: Text('Lu yakin mau menghapus ${kontak.nama} dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              hapusKontakDariSupabase(kontak.id);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> hapusKontakDariSupabase(int id) async {
    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.from('kontak').delete().eq('id', id);

      ambilDataDariInternet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kontak berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void bacaDaftarIdFavorit() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      daftarIdFavorit = prefs.getStringList('data_favorit') ?? [];
    });
  }

  void simpanDaftarIdFavorit() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('data_favorit', daftarIdFavorit);
  }

  @override
  Widget build(BuildContext context) {
    final kontakYangDitampilkan = daftarKontak.where((kontak) {
      return kontak.nama.toLowerCase().contains(kataKunci.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Buku Kontak"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (nilaiTeks) {
                      setState(() {
                        kataKunci = nilaiTeks; 
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Cari Nama Kontak...',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey[210],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), 
                        borderSide: BorderSide.none, 
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: kontakYangDitampilkan.isEmpty
                      ? Center(
                          child: Text(
                            'Kontak tidak ditemukan', 
                            style: TextStyle(fontSize: 18, color: Colors.grey)
                          )
                        )
                      : ListView.builder(
                          itemCount: kontakYangDitampilkan.length, 
                          itemBuilder: (context, index) {
                            final kontak = kontakYangDitampilkan[index]; 
                            final isFavorit = daftarIdFavorit.contains(kontak.id.toString());

                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(kontak.foto),
                                ),
                                title: Text(
                                  kontak.nama,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                                subtitle: Text(kontak.email),

                                trailing: IconButton(
                                  icon: Icon(
                                    isFavorit ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorit ? Colors.red : null,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isFavorit) {
                                        daftarIdFavorit.remove(kontak.id.toString());
                                      } else {
                                        daftarIdFavorit.add(kontak.id.toString());
                                      }
                                      simpanDaftarIdFavorit();
                                      urutkanKontak(); 
                                    });
                                  },
                                ),

                                onTap: () async {
                                  final hasil = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailKontak(kontak: kontak),
                                    ),
                                  );

                                  if (hasil == true) {
                                    ambilDataDariInternet();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            
      // TOMBOL TAMBAH KONTAK
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HalamanTambahKontak()),
          );
          if (hasil == true) {
            ambilDataDariInternet();
          }
        },
      ),
    );
  }
}
