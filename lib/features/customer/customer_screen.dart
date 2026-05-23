import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String _searchQuery = '';
  String _filterSource = 'Tất cả';
  String _filterStatus = 'Tất cả';

  final List<String> _sources = ['Tất cả', 'Facebook', 'Zalo', 'Giới thiệu', 'Google', 'Khác'];
  final List<String> _statuses = ['Tất cả', 'Tiếp nhận', 'Đang tư vấn', 'Đã chốt', 'Đã nghiệm thu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Khách Hàng'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // === THANH TÌM KIẾM + LỌC ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm khách hàng...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterSource,
                        decoration: const InputDecoration(labelText: 'Nguồn'),
                        items: _sources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) => setState(() => _filterSource = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(labelText: 'Trạng thái'),
                        items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) => setState(() => _filterStatus = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // === DANH SÁCH KHÁCH HÀNG ===
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

                // Lọc
                if (_searchQuery.isNotEmpty) {
                  customers = customers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final phone = (data['phone'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || phone.contains(_searchQuery);
                  }).toList();
                }

                if (_filterSource != 'Tất cả') {
                  customers = customers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['source'] == _filterSource;
                  }).toList();
                }

                if (_filterStatus != 'Tất cả') {
                  customers = customers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == _filterStatus;
                  }).toList();
                }

                if (customers.isEmpty) {
                  return const Center(child: Text('Không tìm thấy khách hàng'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final data = customers[index].data() as Map<String, dynamic>;
                    return _buildCustomerCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> data) {
    final status = data['status'] ?? 'Tiếp nhận';
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'] ?? 'Không tên', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('SĐT: ${data['phone'] ?? 'Chưa có'}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                  child: Text(data['source'] ?? 'Khác', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tiếp nhận': return Colors.blue;
      case 'Đang tư vấn': return Colors.orange;
      case 'Đã chốt': return Colors.green;
      case 'Đã nghiệm thu': return Colors.purple;
      default: return Colors.grey;
    }
  }
}