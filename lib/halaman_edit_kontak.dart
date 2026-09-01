import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
  
  File? _fileFoto; 
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.kontak.nama;
    _emailController.text = widget.kontak.email;
  }

  Future<void> ambilDariGaleri() async {
    final picker = ImagePicker();
    final fotoDipilih = await picker.pickImage(source: ImageSource.gallery);
    
    if (fotoDipilih != null) {
      final fotoDicrop = await ImageCropper().cropImage(
        sourcePath: fotoDipilih.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Potong Foto Profil',
              toolbarColor: Colors.blue, 
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          IOSUiSettings(title: 'Potong Foto Profil'),
        ],
      );

      if (fotoDicrop != null) {
        final fileBaru = File(fotoDicrop.path);
        await FileImage(fileBaru).evict(); 
        setState(() {
          _fileFoto = fileBaru;
        });
      }
    }
  }

  Future<void> updateKeSupabase() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama nggak boleh kosong!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String linkFotoFinal = widget.kontak.foto;

      if (_fileFoto != null) {
        final ekstensi = _fileFoto!.path.split('.').last;
        final namaFile = '${DateTime.now().millisecondsSinceEpoch}.$ekstensi';
        
        await Supabase.instance.client.storage
            .from('foto_kontak')
            .upload(namaFile, _fileFoto!);

        linkFotoFinal = Supabase.instance.client.storage
            .from('foto_kontak')
            .getPublicUrl(namaFile);
      }

      await Supabase.instance.client.from('kontak').update({
        'nama': _namaController.text,
        'email': _emailController.text,
        'foto': linkFotoFinal, 
      }).eq('id', widget.kontak.id);

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ngedit: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => isLoading = false);
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
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: ambilDariGaleri,
                child: _fileFoto != null
                    ? ClipOval(
                        child: Image.file(
                          _fileFoto!,
                          width: 120, height: 120, fit: BoxFit.cover,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          widget.kontak.foto,
                          width: 120, height: 120, fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            
            TextField(controller: _namaController, decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            SizedBox(height: 25),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
              onPressed: isLoading ? null : updateKeSupabase,
              child: isLoading 
                  ? CircularProgressIndicator(color: Colors.white) 
                  : Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}