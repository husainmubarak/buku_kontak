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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              backgroundImage: NetworkImage(widget.kontak.avatar), 
            ),

            SizedBox(height: 20),
            
            Text(
              widget.kontak.namaDepan + " " + widget.kontak.namaBelakang,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // KOTAK INFORMASI DETAIL LU DI SINI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 3, // Bikin efek bayangan (3D)
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.blueAccent),
                      title: Text('Email'),
                      subtitle: Text(widget.kontak.email),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
