import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/task_model.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoa Hồng & Doanh Thu'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Chưa có dữ liệu hoa hồng'));
                }

                var tasks = snapshot.data!.docs
                    .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                // Lọc theo search
                if (_searchQuery.isNotEmpty) {
                  tasks = tasks.where((t) =>
                  t.title.toLowerCase().contains(_searchQuery) ||
                      t.customerName.toLowerCase().contains(_searchQuery)).toList();
                }

                // Lọc theo trạng thái
                if (_filterStatus != 'Tất cả') {
                  tasks = tasks.where((t) => t.status.name == _filterStatus).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _buildCommissionCard(tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(TaskModel task) {
    final revenue = task.totalRevenue;
    final cost = task.mainMaterialCost + task.subMaterialCost;
    final profit = revenue - cost;

    final nvkd = (revenue * 0.02).round();      // 2% Nhân viên kinh doanh
    final marketing = (revenue * 0.02).round(); // 2% Marketing
    final giamSat = (profit > 0 ? profit * 0.07 : 0).round(); // 7% Giám sát

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Chip(label: Text(task.status.name), backgroundColor: Colors.orange[100]),
              ],
            ),
            const SizedBox(height: 4),
            Text('Khách hàng: ${task.customerName}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            _buildRow('Doanh thu', '${(revenue / 1000000).toStringAsFixed(2)} triệu', Colors.black),
            _buildRow('NV Kinh Doanh', '$nvkd đ', Colors.green),
            _buildRow('Marketing', '$marketing đ', Colors.blue),
            _buildRow('Giám sát', '$giamSat đ', Colors.purple),

            if (profit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildRow('Lợi nhuận', '${(profit / 1000000).toStringAsFixed(2)} triệu', Colors.orange),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}