import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class HalamanTambahKontak extends StatefulWidget {
  @override
  _HalamanTambahKontakState createState() => _HalamanTambahKontakState();
}

class _HalamanTambahKontakState extends State<HalamanTambahKontak> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _fileFoto; 
  bool isLoading = false;

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
          IOSUiSettings(
            title: 'Potong Foto Profil',
          ),
        ],
      );

      if (fotoDicrop != null) {
        setState(() {
          _fileFoto = File(fotoDicrop.path);
        });
      }
    }
  }

  Future<void> simpanKeSupabase() async {
    if (_namaController.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      String linkFoto = 'https://robohash.org/${_namaController.text}';

      if (_fileFoto != null) {
        final ekstensi = _fileFoto!.path.split('.').last;
        final namaFile = '${DateTime.now().millisecondsSinceEpoch}.$ekstensi'; 

        await Supabase.instance.client.storage
            .from('foto_kontak')
            .upload(namaFile, _fileFoto!);

        linkFoto = Supabase.instance.client.storage
            .from('foto_kontak')
            .getPublicUrl(namaFile);
      }

      await Supabase.instance.client.from('kontak').insert({
        'nama': _namaController.text,
        'email': _emailController.text,
        'foto': linkFoto,
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Kontak"),
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
                          width: 120, 
                          height: 120, 
                          fit: BoxFit.cover, 
                        ),
                      )
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[700]),
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: isLoading ? null : simpanKeSupabase,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("SIMPAN", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
