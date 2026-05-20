import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Khách Hàng'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khách hàng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('customers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Chưa có khách hàng nào'));
                }

                var customers = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  customers = customers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final data = customers[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'Đang tiếp nhận';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.person, size: 50, color: Colors.blue),
                        title: Text(data['name'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SĐT: ${data['phone'] ?? 'Chưa có'}'),
                            const SizedBox(height: 4),
                            Text('Nguồn: ${data['source'] ?? 'Không rõ'}'),
                          ],
                        ),
                        trailing: _buildStatusChip(status),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chi tiết khách: ${data['name']}')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form thêm khách hàng sẽ được làm sau')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status.contains('tiếp nhận') || status.contains('Tiếp')) color = Colors.blue;
    if (status.contains('chăm sóc') || status.contains('Đang')) color = Colors.orange;
    if (status.contains('thi công') || status.contains('Đang thi')) color = Colors.purple;
    if (status.contains('hoàn thành') || status.contains('Hoàn')) color = Colors.green;

    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}