import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/task_model.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Tất cả';

  final List<String> _statusFilters = ['Tất cả', 'Hoàn thành', 'Đang thi công', 'Chốt hợp đồng'];

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
              stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
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

                if (_searchQuery.isNotEmpty) {
                  tasks = tasks.where((t) =>
                  t.title.toLowerCase().contains(_searchQuery) ||
                      t.customerName.toLowerCase().contains(_searchQuery)).toList();
                }

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

    final nvkd = (revenue * 0.02).round();      // 2% NVKD
    final marketing = (revenue * 0.02).round(); // 2% Marketing
    final giamSat = (profit * 0.07).round();    // 7% Giám sát

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Chip(label: Text(task.status.name), backgroundColor: Colors.orange[100]),
              ],
            ),
            Text('Khách: ${task.customerName}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Doanh thu:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${(revenue / 1000000).toStringAsFixed(2)} triệu',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            _buildCommissionRow('NV Kinh Doanh', nvkd, Colors.green),
            _buildCommissionRow('Marketing', marketing, Colors.blue),
            _buildCommissionRow('Giám sát', giamSat, Colors.purple),

            if (profit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Lợi nhuận: ${(profit / 1000000).toStringAsFixed(2)} triệu',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionRow(String title, int amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text('${amount.toString()}đ', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}