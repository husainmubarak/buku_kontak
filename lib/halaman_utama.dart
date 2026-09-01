import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_kontak.dart';
import 'halaman_detail.dart';
import 'halaman_login.dart';
import 'halaman_tambah_kontak.dart';
import 'halaman_edit_kontak.dart';

class HalamanUtama extends StatefulWidget {
  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<DataKontak> daftarKontak = [];
  List<String> daftarIdFavorit = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ambilDataDariInternet();
    bacaDaftarIdFavorit();
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
            child: Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        SnackBar(content: Text('Kontak berhasil dihapus!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Aplikasi Kontak",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HalamanLogin()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "Daftar Kontak",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),

            SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: daftarKontak.length,
                      itemBuilder: (context, index) {
                        DataKontak kontak = daftarKontak[index];
                        bool isFavorit = daftarIdFavorit.contains(
                          kontak.id.toString(),
                        );

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              backgroundImage: NetworkImage(kontak.foto),
                            ),
                            title: Text(
                              kontak.nama,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              ),
                            subtitle: Text(kontak.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                IconButton(
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
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () async {
                                    final hasil = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HalamanEditKontak(kontak: kontak),
                                      ),
                                    );

                                    if (hasil == true) {
                                      ambilDataDariInternet();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[400]),
                                  onPressed: () {
                                    konfirmasiHapus(kontak); 
                                  },
                                ),
                              ],
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailKontak(kontak: kontak),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

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
