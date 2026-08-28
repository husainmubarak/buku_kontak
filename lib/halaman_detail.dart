import 'package:flutter/material.dart';

import 'data_kontak.dart';

class DetailKontak extends StatefulWidget {
  final DataKontak kontak;

  DetailKontak({required this.kontak});

  @override
  _DetailKontakState createState() => _DetailKontakState();
}

class _DetailKontakState extends State<DetailKontak> {
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              backgroundImage: NetworkImage(widget.kontak.avatar),
              maxRadius: 60,
            ),

            SizedBox(height: 16),


            Text(
              "Nama Depan: ${widget.kontak.namaDepan}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Nama Belakang: ${widget.kontak.namaBelakang}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Email: ${widget.kontak.email}",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
