import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AktivitasAdminPage extends StatefulWidget {
  const AktivitasAdminPage({super.key});

  @override
  State<AktivitasAdminPage> createState() => _AktivitasAdminPageState();
}

class _AktivitasAdminPageState extends State<AktivitasAdminPage> {
  Stream<QuerySnapshot> getOrders(String status) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateStatusToCompleted(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'Completed',
    });
  }

  // UPDATE: Fungsi hapus order
  Future<void> deleteOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
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
                _buildOrderList('Pending', showCompleteButton: true),
                _buildOrderList('Completed', showDeleteButton: true), // UPDATE
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status, {bool showCompleteButton = false, bool showDeleteButton = false}) {
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
                    _buildIconText(Icons.person, data['nama']?.toString() ?? '-', fontSize: 24),
                    _buildIconText(Icons.access_time, formatTimestamp(data['createdAt']), fontSize: 16),
                    _buildIconText(Icons.location_on, data['alamat']?.toString() ?? '-', fontSize: 18),

                    if (data['titikjemput'] != null && data['titikjemput'].toString().isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          final url = data['titikjemput'].toString();
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tidak dapat membuka link')),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.map, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Lihat Titik Jemput',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    _buildIconText(Icons.phone, data['telepon']?.toString() ?? '-', fontSize: 18),

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showCompleteButton)
                          ElevatedButton(
                            onPressed: () async {
                              await updateStatusToCompleted(order.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Selesai'),
                          ),
                        if (showDeleteButton)
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Orderan'),
                                  content: const Text('Yakin ingin menghapus orderan ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await deleteOrder(order.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Orderan berhasil dihapus')),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildIconText(IconData icon, String text, {double fontSize = 18}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[800], size: fontSize + 2),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
