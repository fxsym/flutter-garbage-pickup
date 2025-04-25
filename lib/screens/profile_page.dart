import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _teleponController = TextEditingController();

  String? _selectedGender;
  String? _currentPhoto;
  File? _newImage;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _namaController.text = data['nama'] ?? '';
          _selectedGender = data['gender'] ?? '';
          _emailController.text = data['email'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _teleponController.text = data['telepon'] ?? '';
          _currentPhoto = data['foto_profile'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _newImage = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? photoString = _currentPhoto;

        if (_newImage != null) {
          final bytes = await _newImage!.readAsBytes();
          photoString = base64Encode(bytes);
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'nama': _namaController.text,
          'gender': _selectedGender ?? '',
          'email': _emailController.text,
          'username': _usernameController.text,
          'telepon': _teleponController.text,
          'foto_profile': photoString ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profil berhasil diperbarui")),
        );
        setState(() {
          _newImage = null;
          _currentPhoto = photoString;
        });
      }

      setState(() => _loading = false);
    }
  }

  Widget _buildProfileImage() {
    if (_newImage != null) {
      return Image.file(_newImage!, width: 150, height: 150, fit: BoxFit.cover);
    } else if (_currentPhoto != null && _currentPhoto!.isNotEmpty) {
      return Image.memory(base64Decode(_currentPhoto!), width: 150, height: 150, fit: BoxFit.cover);
    } else {
      return Icon(Icons.person, size: 120, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildProfileImage(),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library),
                      label: Text("Ganti Foto"),
                    ),
                    SizedBox(height: 20),
                    _buildTextField("Nama", _namaController, Icons.person),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                      items: ['Laki-laki', 'Perempuan'].map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Jenis Kelamin tidak boleh kosong'
                          : null,
                    ),
                    SizedBox(height: 12),
                    _buildTextField("Email", _emailController, Icons.email),
                    SizedBox(height: 12),
                    _buildTextField("Username", _usernameController, Icons.account_circle),
                    SizedBox(height: 12),
                    _buildTextField("Telepon", _teleponController, Icons.phone),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text("Simpan Perubahan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    )
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
      validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }
}
