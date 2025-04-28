import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({super.key});

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController(); // Alamat baru
  final _beratController = TextEditingController();
  final _titikJemputController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedTPS;

  bool _loading = false;

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('orders').add({
            'nama': _namaController.text,
            'telepon': _teleponController.text,
            'alamat': _alamatController.text, // Tambahkan alamat ke Firestore
            'tps': _selectedTPS,
            'berat': _beratController.text,
            'titikjemput': _titikJemputController.text,
            'note': _noteController.text,
            'status': 'Pending',
            'createdAt': Timestamp.now(),
            'userId': user.uid,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order berhasil dibuat')),
          );

          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat order: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buat Pickup Order")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Nama", _namaController, Icons.person),
                    SizedBox(height: 12),
                    _buildTextField("Telepon", _teleponController, Icons.phone),
                    SizedBox(height: 12),
                    _buildTextField("Alamat Rumah", _alamatController, Icons.home), // Field Alamat
                    SizedBox(height: 12),
                    _buildDropdownTPS(),
                    SizedBox(height: 12),
                    _buildTextField("Berat Sampah (contoh: 5 kg)", _beratController, Icons.scale),
                    SizedBox(height: 12),
                    _buildTextField("Link Titik Jemput (Google Maps)", _titikJemputController, Icons.location_on),
                    SizedBox(height: 12),
                    _buildOptionalNoteField("Catatan (Opsional)", _noteController, Icons.note), // Note lebih tinggi
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitOrder,
                      child: Text("Buat Orderan"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purple,
                        minimumSize: Size(double.infinity, 50),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  Widget _buildOptionalNoteField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
        alignLabelWithHint: true, // Supaya label tetap di atas saat multiline
      ),
      maxLines: 4, // Membuat textbox lebih tinggi
    );
  }

  Widget _buildDropdownTPS() {
    List<String> tpsList = List.generate(10, (index) => 'TPS ${index + 1}');

    return DropdownButtonFormField<String>(
      value: _selectedTPS,
      decoration: InputDecoration(
        labelText: 'Pilih TPS',
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(),
      ),
      items: tpsList.map((tps) {
        return DropdownMenuItem(
          value: tps,
          child: Text(tps),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTPS = value;
        });
      },
      validator: (value) => value == null ? 'TPS harus dipilih' : null,
    );
  }
}
