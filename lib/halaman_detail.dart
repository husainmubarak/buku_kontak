import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_kontak.dart';
import 'halaman_edit_kontak.dart';

class DetailKontak extends StatefulWidget {
  final DataKontak kontak;

  DetailKontak({required this.kontak});

  @override
  _DetailKontakState createState() => _DetailKontakState();
}

class _DetailKontakState extends State<DetailKontak> {
  bool isLoading = false;

  void konfirmasiHapus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Kontak?'),
        content: Text('Yakin mau menghapus ${widget.kontak.nama} dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              hapusDariSupabase(); 
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> hapusDariSupabase() async {
    setState(() => isLoading = true);
    
    try {
      await Supabase.instance.client.from('kontak').delete().eq('id', widget.kontak.id);
      
      // JURUS KUNCI: Tutup halaman detail, dan kirim sinyal "true" ke halaman utama
      Navigator.pop(context, true); 
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Kontak"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final hasilEdit = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HalamanEditKontak(kontak: widget.kontak)),
              );

              if (hasilEdit == true) {
                Navigator.pop(context, true);
              }
            },
          ),

          IconButton(
            icon: Icon(Icons.delete),
            onPressed: konfirmasiHapus,
          ),
        ],
      ),
      
      body: isLoading 
          ? Center(child: CircularProgressIndicator()) 
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: NetworkImage(widget.kontak.foto),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.kontak.nama, 
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.kontak.email, 
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}