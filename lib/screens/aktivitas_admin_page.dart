import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class AktivitasAdminPage extends StatefulWidget {
  const AktivitasAdminPage({super.key});

  @override
  State<AktivitasAdminPage> createState() => _AktivitasAdminPageState();
}

class _AktivitasAdminPageState extends State<AktivitasAdminPage> {
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
              unselectedLabelColor: Colors.grey,
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
                    _buildHeading(data['nama']?.toString() ?? '-', fontSize: 24),
                    _buildSubHeading(formatTimestamp(data['createdAt']), fontSize: 16),
                    _buildHeading(data['alamat']?.toString() ?? '-', fontSize: 18),
                    _buildHeading(data['telepon']?.toString() ?? '-', fontSize: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubHeading(data['tps']?.toString() ?? '-', fontSize: 16),
                        _buildSubHeading('Berat: ${data['berat'] ?? '-'} kg', fontSize: 16),
                      ],
                    ),
                    if (data['note'] != null && data['note'].toString().isNotEmpty)
                      _buildSubHeading('Note: ${data['note']?.toString()}', fontSize: 16),
                    _buildSubHeading('Status: ${data['status']?.toString() ?? '-'}', fontSize: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeading(String text, {double fontSize = 18}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.purple[800],
        ),
      ),
    );
  }

  Widget _buildSubHeading(String text, {double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
