import 'package:flutter/material.dart';
import 'customer_screen.dart';
import 'task_screen.dart';
import 'commission_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final screens = [
    DashboardContent(),
    CustomerScreen(),
    TaskScreen(),
    CommissionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          // ===== SIDEBAR =====
          Container(
            width: 220,
            color: Colors.grey[200],
            child: Column(
              children: [
                SizedBox(height: 20),
                Text("PMW", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Divider(),

                _menuItem(Icons.dashboard, "Dashboard", 0),
                _menuItem(Icons.people, "Khách hàng", 1),
                _menuItem(Icons.work, "Công việc", 2),
                _menuItem(Icons.money, "Hoa hồng", 3),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: screens[selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }
}
class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("PMW Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _card("Tổng doanh thu", "500tr"),
              _card("Công việc", "12"),
              _card("Hợp đồng", "5"),
              _card("Khách MKT", "20"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}