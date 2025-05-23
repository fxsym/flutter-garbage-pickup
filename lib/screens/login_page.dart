import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Mengambil input textbox dari user
    String userInput = _userOrEmailController.text.trim();
    String password = _passwordController.text;

    String email = '';

    try {
      //jika user menggunakan @ dalam text box berarti gunakan email sebagai userInput
      if (userInput.contains('@')) {
        email = userInput;
      } else {
        // Cek data yang ada di firebase...
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: userInput)
            .get();

        // Jika data tidak ditemukan maka keluarkan kode user not found
        if (snapshot.docs.isEmpty) {
          throw FirebaseAuthException(code: 'user-not-found');
        }

        email = snapshot.docs.first['email'];
      }

      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Setelah login, ambil role user
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userSnapshot.exists) {
        throw Exception('Data pengguna tidak ditemukan');
      }

      String role =
          userSnapshot['role']; // Pastikan field 'role' ada di Firestore

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login berhasil")),
      );

      //Cek role user yang login
      if (role == 'pelanggan') {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } else if (role == 'petugas') {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/dashboard_admin', (route) => false);
      } else {
        throw Exception('Role tidak dikenali');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan saat login.';

      // Memberi eror pesan kepada pengguna
      switch (e.code) {
        case 'user-not-found':
          message = 'Pengguna tidak ditemukan';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = 'Login gagal (${e.code})';
      }


      //Menampilkan error di snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi error: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _userOrEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email atau Username',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Email/Username tidak boleh kosong'
                          : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Password tidak boleh kosong' : null,
                    ),
                    SizedBox(height: 20),
                    _loading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            child: Text('Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
