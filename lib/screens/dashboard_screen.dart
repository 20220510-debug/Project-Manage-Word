import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/firebase_service.dart';
import 'customer_screen.dart';
import 'task_screen.dart';
import 'commission_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const CustomerScreen(),
    const TaskScreen(),
    const CommissionScreen(),
  ];

  final List<String> _titles = ['Dashboard', 'Khách hàng', 'Công việc', 'Hoa hồng'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Hoa hồng'),
        ],
      ),
    );
  }
}

// Nội dung Dashboard
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<FirebaseService>(context).currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xin chào, ${currentUser?.name ?? "test"}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: const [
              StatCard(value: "1.250", unit: "triệu", label: "Tổng Doanh Thu", icon: Icons.monetization_on, color: Colors.green),
              StatCard(value: "12", unit: "", label: "Công việc đang làm", icon: Icons.work, color: Colors.orange),
              StatCard(value: "5", unit: "", label: "Sắp đến hạn", icon: Icons.notifications, color: Colors.red, showNotification: true),
              StatCard(value: "8", unit: "", label: "Khách hàng mới", icon: Icons.person_add, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final IconData icon;
  final Color color;
  final bool showNotification;

  const StatCard({super.key, required this.value, required this.unit, required this.label, required this.icon, required this.color, this.showNotification = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, size: 28, color: color), if (showNotification) const CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text("!", style: TextStyle(fontSize: 10, color: Colors.white)))]),
          const Spacer(),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), if (unit.isNotEmpty) Text(" $unit", style: const TextStyle(fontSize: 13, color: Colors.grey))]),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}