import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanTambahKontak extends StatefulWidget {
  @override
  _HalamanTambahKontakState createState() => _HalamanTambahKontakState();
}

class _HalamanTambahKontakState extends State<HalamanTambahKontak> {
  // Ini controller buat nangkep teks yang diketik user
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  
  bool isLoading = false;

  Future<void> simpanKeSupabase() async {
    // Validasi sederhana, nama nggak boleh kosong!
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama harus diisi bro!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // JURUS SAKTI INSERT DATA KE SUPABASE
      await Supabase.instance.client.from('kontak').insert({
        'nama': _namaController.text,
        'email': _emailController.text.isEmpty ? 'Tidak ada email' : _emailController.text,
        // Kalau link foto dikosongin, kita kasih gambar robot acak otomatis!
        'foto': _fotoController.text.isEmpty 
            ? 'https://robohash.org/${_namaController.text}' 
            : _fotoController.text,
      });

      // Kalau sukses, tutup halaman ini dan lapor ke Halaman Utama bawa kode "true"
      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal nyimpen: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Kontak Baru"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _fotoController,
              decoration: InputDecoration(labelText: 'Link Foto (Opsional)', border: OutlineInputBorder()),
            ),
            SizedBox(height: 25),
            
            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: isLoading ? null : simpanKeSupabase,
                child: isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SIMPAN KONTAK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}