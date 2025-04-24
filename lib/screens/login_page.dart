import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart'; // pastikan file ini ada

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

    String userInput = _userOrEmailController.text.trim();
    String password = _passwordController.text;

    String email = '';

    try {
      if (userInput.contains('@')) {
        email = userInput;
      } else {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: userInput)
            .get();

        if (snapshot.docs.isEmpty) {
          throw FirebaseAuthException(code: 'user-not-found');
        }

        email = snapshot.docs.first['email'];
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login berhasil")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan saat login.';

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
        // Menggunakan Center untuk memusatkan seluruh konten
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            // Scrollable jika konten lebih besar dari layar
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600), // Maksimal lebar form
              child: Form(
                key: _formKey,
                child: Column(
                  // Menggunakan Column agar widget berada di tengah secara vertikal
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
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
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
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
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
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white, // Text color
                              elevation: 2,
                              minimumSize:
                                  Size(double.infinity, 48), // Full width
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
