import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka link Google Maps

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  Stream<QuerySnapshot> getOrders(String status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat menghapus order')),
      );
    }
  }

  Future<void> _launchGoogleMap(String mapUrl) async {
    if (await canLaunch(mapUrl)) {
      await launch(mapUrl);
    } else {
      throw 'Tidak dapat membuka link Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.purple[50],
            child: const TabBar(
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.purple,
              tabs: [
                Tab(text: 'Dalam Proses'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderList('Pending'), // Tab Dalam Proses
                _buildOrderList('Completed'), // Tab Selesai
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrders(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Center(child: Text('Terjadi kesalahan'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada data'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: Colors.purple[200],
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.purple.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRowWithIcon(
                      Icons.person,
                      data['nama']?.toString() ?? '-',
                      fontSize: 26,
                      vertical: 2,
                    ),
                    _buildSubHeading(
                      '${formatTimestamp(data['createdAt'])}',
                      fontSize: 14,
                    ),
                    _buildRowWithIcon(
                      Icons.location_on,
                      data['alamat']?.toString() ?? '-',
                      fontSize: 18,
                    ),
// Tombol untuk membuka Google Maps
                    if (data['titikjemput'] != null &&
                        data['titikjemput'].toString().isNotEmpty)
                      _buildRowWithIconButton(
                        icon: Icons.map,
                        text: data['titikjemput']?.toString() ?? '-',
                        onPressed: () => _launchGoogleMap(data['titikjemput']),
                      ),
                    _buildRowWithIcon(
                      Icons.phone,
                      data['telepon']?.toString() ?? '-',
                      fontSize: 18,
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubHeading(
                          data['tps']?.toString() ?? '-',
                          fontSize: 16,
                        ),
                        _buildSubHeading(
                          'Berat: ${data['berat'] ?? '-'} kg',
                          fontSize: 16,
                        ),
                      ],
                    ),
                    if (data['note'] != null &&
                        data['note'].toString().isNotEmpty)
                      _buildSubHeading(
                        'Note: ${data['note']?.toString()}',
                        fontSize: 16,
                      ),
                    _buildSubHeading(
                      'Status: ${data['status']?.toString() ?? '-'}',
                      fontSize: 16,
                    ),
                    // Tombol untuk menghapus order pada tab "Selesai"
                    if (status == 'Completed')
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(order.id),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubHeading(String text, {double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildRowWithIcon(IconData icon, String text,
      {double fontSize = 18, double vertical = 6}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Row(
        children: [
          Icon(icon, size: fontSize, color: Colors.black),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithIconButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    double fontSize = 18,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon, size: fontSize, color: Colors.black),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline, // biar keliatan klik-able
              ),
            ),
          ),
        ],
      ),
    );
  }
}
