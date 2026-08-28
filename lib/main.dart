import 'package:flutter/material.dart';
import 'halaman_utama.dart';

void main() {
  runApp(ApkikasiKontak());
}

class ApkikasiKontak extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HalamanUtama(),
    );
  }
}

