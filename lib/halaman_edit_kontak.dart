import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_kontak.dart';

class HalamanEditKontak extends StatefulWidget {
  final DataKontak kontak; 

  HalamanEditKontak({required this.kontak});

  @override
  _HalamanEditKontakState createState() => _HalamanEditKontakState();
}

class _HalamanEditKontakState extends State<HalamanEditKontak> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.kontak.nama;
    _emailController.text = widget.kontak.email;
    _fotoController.text = widget.kontak.foto;
  }

  Future<void> updateKeSupabase() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama nggak boleh kosong!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.from('kontak').update({
        'nama': _namaController.text,
        'email': _emailController.text,
        'foto': _fotoController.text,
      }).eq('id', widget.kontak.id);

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ngedit: $e'), backgroundColor: Colors.red),
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
        title: Text("Edit Kontak"),
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
              decoration: InputDecoration(labelText: 'Link Foto', border: OutlineInputBorder()),
            ),
            SizedBox(height: 25),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: isLoading ? null : updateKeSupabase,
                child: isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}