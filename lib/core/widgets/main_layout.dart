import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/features/dashboard/dashboard_screen.dart';
import '/features/task/task_screen.dart';
import '/features/customer/customer_screen.dart';
import '/features/commission/commission_screen.dart';
import '/features/checkin/checkin_screen.dart';
import '/services/firebase_service.dart';
import '/models/user_model.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final currentUser = firebaseService.currentUser;
    final bool isAdmin = currentUser?.role == UserRole.admin;

    final List<String> titles = ['Dashboard', 'Khách hàng', 'Công việc', 'Hoa hồng', 'Check-in'];

    final List<Widget> screens = [
      const DashboardScreen(),
      const CustomerScreen(),      // ← Khôi phục lại cho cả Admin và User
      const TaskScreen(),
      const CommissionScreen(),
      const CheckInScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        items: isAdmin
            ? const [  // Admin thấy đầy đủ 5 tab
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Hoa hồng'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Check-in'),
        ]
            : const [  // User thường thấy 5 tab (giữ Khách hàng)
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Hoa hồng'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Check-in'),
        ],
      ),
    );
  }
}