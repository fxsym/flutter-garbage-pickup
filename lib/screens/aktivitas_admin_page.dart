import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AktivitasAdminPage extends StatefulWidget {
  const AktivitasAdminPage({super.key});

  @override
  State<AktivitasAdminPage> createState() => _AktivitasAdminPageState();
}

class _AktivitasAdminPageState extends State<AktivitasAdminPage> {
  Stream<QuerySnapshot> getOrders(String status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty(); // Handle case ketika belum login
    }
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateStatusToCompleted(String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': 'Completed'});
  }

  Future<void> deleteOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
  }

  Future<void> _launchGoogleMap(String mapUrl) async {
    final uri = Uri.parse(mapUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link')),
      );
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
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
                _buildOrderList('Pending', showCompleteButton: true),
                _buildOrderList('Completed', showDeleteButton: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status,
      {bool showCompleteButton = false, bool showDeleteButton = false}) {
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

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final order = docs[i];
            final data = order.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: Colors.purple[200],
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              shadowColor: Colors.purple.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRowWithIcon(
                        Icons.person, data['nama']?.toString() ?? '-',
                        fontSize: 26, vertical: 2),
                    _buildSubHeading(formatTimestamp(data['createdAt']),
                        fontSize: 14),
                    _buildRowWithIcon(
                        Icons.location_on, data['alamat']?.toString() ?? '-',
                        fontSize: 18),
                    if ((data['titikjemput'] as String?)?.isNotEmpty ?? false)
                      _buildRowWithIconButton(
                        icon: Icons.map,
                        text: 'Lihat Titik Jemput',
                        onPressed: () => _launchGoogleMap(data['titikjemput']),
                      ),
                    _buildRowWithIcon(
                        Icons.phone, data['telepon']?.toString() ?? '-',
                        fontSize: 18),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubHeading(data['tps']?.toString() ?? '-',
                            fontSize: 16),
                        _buildSubHeading('Berat: ${data['berat'] ?? '-'} kg',
                            fontSize: 16),
                      ],
                    ),
                    if ((data['note'] as String?)?.isNotEmpty ?? false)
                      _buildSubHeading('Note: ${data['note']}', fontSize: 16),
                    _buildSubHeading('Status: ${data['status']}', fontSize: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showCompleteButton)
                          ElevatedButton(
                            onPressed: () => updateStatusToCompleted(order.id),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white),
                            child: const Text('Selesai'),
                          ),
                        if (showDeleteButton)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Hapus Orderan'),
                                  content: const Text(
                                      'Yakin ingin menghapus orderan ini?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Hapus',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await deleteOrder(order.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Orderan berhasil dihapus')));
                              }
                            },
                          ),
                      ],
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
      child: Text(text,
          style: TextStyle(fontSize: fontSize, color: Colors.grey[800])),
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
            child: Text(text,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithIconButton(
          {required IconData icon,
          required String text,
          required VoidCallback onPressed,
          double fontSize = 18}) =>
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
        child: Row(
          children: [
            Icon(icon, size: fontSize, color: Colors.black),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline)),
          ],
        ),
      );
}
