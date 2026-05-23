import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final currentUser = firebaseService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Xin chào, ', style: TextStyle(fontSize: 20)),
                Text(currentUser?.name ?? 'An', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // === 4 Ô THỐNG KÊ TRÊN 1 HÀNG NGANG ===
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
              builder: (context, taskSnapshot) {
                if (!taskSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                final tasks = taskSnapshot.data!.docs.map((doc) =>
                    TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                final totalRevenue = tasks.fold<double>(0, (sum, t) => sum + t.totalRevenue);
                final activeTasks = tasks.where((t) => t.status != TaskStatus.hoanThanh).length;
                final upcomingDeadline = tasks.where((t) =>
                t.deadline.isBefore(DateTime.now().add(const Duration(days: 7))) &&
                    t.status != TaskStatus.hoanThanh).length;

                return GridView.count(
                  crossAxisCount: 4,                    // 4 ô trên 1 hàng
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                  children: [
                    _buildStatCard('Tổng Doanh Thu', (totalRevenue / 1000000).toStringAsFixed(1), 'triệu', Icons.attach_money, Colors.green),
                    _buildStatCard('Đang làm', activeTasks.toString(), '', Icons.work, Colors.orange),
                    _buildStatCard('Sắp hạn', upcomingDeadline.toString(), '', Icons.timer, Colors.red),
                    _buildStatCard('Tổng việc', tasks.length.toString(), '', Icons.assignment, Colors.blue),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            const Text('Doanh thu 7 ngày qua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [FlSpot(0, 120), FlSpot(1, 180), FlSpot(2, 150), FlSpot(3, 220), FlSpot(4, 280), FlSpot(5, 190), FlSpot(6, 310)],
                      isCurved: true,
                      color: Colors.blue[800],
                      barWidth: 4,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(unit, style: const TextStyle(fontSize: 10)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}