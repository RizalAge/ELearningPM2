import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PrefExample(),
    );
  }
}

class PrefExample extends StatefulWidget {
  const PrefExample({super.key});

  @override
  State<PrefExample> createState() => PrefExampleState();
}

class PrefExampleState extends State<PrefExample> {
  String _pesan = 'Belum ada data';

  Future<void> simpan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pesan', 'Halo SharedPreferences. ini adalah latihan dari pertemuan 11 untuk mencoba create read update delete data.');
  }

  Future<void> baca() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pesan = prefs.getString('pesan') ?? 'Data kosong';
    });
  }

  Future<void> hapus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pesan');
    setState(() {
      _pesan = 'Data dihapus';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences Sederhana'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _pesan,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: simpan,
              child: const Text('Simpan'),
            ),
            ElevatedButton(
              onPressed: baca,
              child: const Text('Baca'),
            ),
            ElevatedButton(
              onPressed: hapus,
              child: const Text('Hapus'),
            ),
          ],
        ), // Column
      ), // Center
    ); // Scaffold
  }
}
