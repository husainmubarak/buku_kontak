import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'halaman_utama.dart';
import 'halaman_login.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vjggpiurgcrskntslayg.supabase.co', 
    anonKey: 'sb_publishable_3uK6Kg3Wv_PbTvXrQZ7d0Q_pVJ4iR_x', 
  );

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
    final sesiAktif = Supabase.instance.client.auth.currentSession;
    
    if (sesiAktif != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HalamanUtama()),
      );

    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HalamanLogin()),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

