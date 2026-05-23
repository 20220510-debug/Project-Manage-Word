import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<FirebaseService>(context).currentUser;
    final bool isAdmin = currentUser?.role == UserRole.admin;
    final bool isTruongPhong = currentUser?.role == UserRole.truongphong;
    final bool canEdit = isAdmin || isTruongPhong;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoa Hồng & Doanh Thu'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('status', isEqualTo: 'Hoàn thành')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Chưa có công việc nào hoàn thành', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                var tasks = snapshot.data!.docs
                    .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                // ==================== LỌC HOA HỒNG THEO NGƯỜI DÙNG ====================
                if (!isAdmin && currentUser != null) {
                  tasks = tasks.where((task) {
                    return task.participants.containsKey(currentUser.uid);
                  }).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  tasks = tasks.where((task) =>
                  task.title.toLowerCase().contains(_searchQuery) ||
                      task.customerName.toLowerCase().contains(_searchQuery)).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(child: Text('Bạn chưa có hoa hồng nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildCommissionCard(task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD HOA HỒNG ====================
  Widget _buildCommissionCard(TaskModel task) {
    final revenue = task.totalRevenue;
    final profit = revenue - task.mainMaterialCost - task.subMaterialCost;

    final nvkdCommission = revenue * 0.02;
    final marketingCommission = revenue * 0.02;
    final giamsatCommission = profit * 0.07;
    final totalCommission = nvkdCommission + marketingCommission + giamsatCommission;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Khách: ${task.customerName}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            _buildCommissionRow('Doanh thu', '${(revenue / 1000000).toStringAsFixed(1)} triệu', Colors.black87),
            _buildCommissionRow('NV Kinh Doanh (2%)', '${nvkdCommission.toStringAsFixed(0)}đ', Colors.green),
            _buildCommissionRow('Marketing (2%)', '${marketingCommission.toStringAsFixed(0)}đ', Colors.blue),
            _buildCommissionRow('Giám sát (7% lợi nhuận)', '${giamsatCommission.toStringAsFixed(0)}đ', Colors.purple),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TỔNG HOA HỒNG CỦA BẠN',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalCommission.toStringAsFixed(0)}đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}