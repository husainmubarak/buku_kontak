import 'package:flutter/material.dart';
import 'halaman_login.dart';

void main() {
  runApp(ApkikasiKontak());
}

class ApkikasiKontak extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HalamanLogin(),
    );
  }
}

