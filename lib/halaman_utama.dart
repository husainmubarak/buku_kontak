import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'data_kontak.dart';
import 'halaman_detail.dart';
import 'halaman_login.dart';

class HalamanUtama extends StatefulWidget {
  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<DataKontak> daftarKontak = [];
  List<String> daftarIdFavorit = [];
  bool isLoading = false;

   @override
  void initState() {
    super.initState();
    ambilDataDariInternet(); 
    bacaDaftarIdFavorit();
  }

  Future<void> ambilDataDariInternet() async {
    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse('https://reqres.in/api/users?page=1');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        List<dynamic> dataJsonMentah = jsonDecode(response.body)['data'];

        setState(() {
          daftarKontak = dataJsonMentah.map((item) => DataKontak.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void bacaDaftarIdFavorit() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      daftarIdFavorit = prefs.getStringList('data_favorit') ?? [];
    });
  }

  void simpanDaftarIdFavorit() async {
    final prefs = await SharedPreferences.getInstance();
   
    await prefs.setStringList('data_favorit', daftarIdFavorit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aplikasi Kontak", 
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),), 
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout), 
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              await prefs.remove('token_user'); 

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HalamanLogin()),
              );
            },
          ),
        ],
      ),
        

      body: Padding(
        padding: EdgeInsets.all(10),
        child:Column(
          children: [
            Text("Daftar Kontak", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
            
            SizedBox(height: 20),

            Expanded(
              child: isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
                itemCount: daftarKontak.length,
                itemBuilder: (context, index) {

                  DataKontak kontak = daftarKontak[index];
                  bool isFavorit = daftarIdFavorit.contains(kontak.id.toString());

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        backgroundImage: NetworkImage(kontak.avatar),
                      ),
                      title: Text(kontak.namaDepan),
                      subtitle: Text(kontak.email),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorit ? Icons.favorite : Icons.favorite_border,
                          color: isFavorit ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFavorit) {
                              daftarIdFavorit.remove(kontak.id.toString());
                            } else {
                              daftarIdFavorit.add(kontak.id.toString());
                            }

                            simpanDaftarIdFavorit();
                          });
                        },
                      ),
                      
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailKontak(kontak: kontak),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
