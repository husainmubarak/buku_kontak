import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'halaman_utama.dart';
import 'halaman_login.dart';

void main() {
  runApp(ApkikasiKontak());
}

class ApkikasiKontak extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GerbangMasuk(),
    );
  }
}

class GerbangMasuk extends StatefulWidget {
  @override
  _GerbangMasukState createState() => _GerbangMasukState();
}

class _GerbangMasukState extends State<GerbangMasuk> {
  
  @override
  void initState() {
    super.initState();
    cekApakahUdahLogin();
  }

  void cekApakahUdahLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Coba ambil token dari brankas
    String? tokenBawaan = prefs.getString('token_user');

    // Kasih jeda 1 detik biar ada efek loading (opsional)
    await Future.delayed(Duration(seconds: 1));

    if (tokenBawaan != null) {
      // Kalau Token ADA, tendang langsung ke Halaman Utama!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HalamanUtama()),
      );
    } else {
      // Kalau Token KOSONG (null), suruh dia Login dulu!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HalamanLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan layarnya cuma putih polos dengan muter-muter di tengah
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

