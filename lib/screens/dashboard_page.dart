import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _nama;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNamaPengguna();
  }

  Future<void> _fetchNamaPengguna() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          // Pastikan widget masih mounted sebelum memanggil setState
          if (mounted) {
            setState(() {
              _nama = snapshot['nama'];
              _loading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Gagal mengambil nama: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Selamat Datang
          _loading
              ? Center(child: CircularProgressIndicator())
              : Text(
                  'Selamat Datang, $_nama!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
          SizedBox(height: 12),
          Text(
            'Terima kasih telah menjadi bagian dari solusi lingkungan 🌱',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 24),

          //Tambahkan gambar ditengah disini, dari folder assets/images/dashboard.jpg
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/dashboard.png',
                width:
                    MediaQuery.of(context).size.width * 0.8, // Sesuaikan ukuran
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 24), // Jarak setelah gambar

          // Card: Tukarkan Sampah
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.purple[200],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '♻ Tukarkan sampahmu sekarang!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Solusi untuk menyelesaikan masalah sosial tentang kebersihan lingkungan.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigasi ke halaman penukaran
                        Navigator.pushNamed(context, '/pickup');
                      },
                      label: Text('Mulai Tukar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
