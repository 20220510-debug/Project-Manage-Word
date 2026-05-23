import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/features/dashboard/dashboard_screen.dart';
import '/features/task/task_screen.dart';
import '/features/customer/customer_screen.dart';
import '/features/commission/commission_screen.dart';
import '/features/checkin/checkin_screen.dart';
import '/features/user/user_management_screen.dart';
import '/services/firebase_service.dart';
import '/models/user_model.dart';
import '/features/auth/login_screen.dart';

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
    final bool isGiamSat = currentUser?.role == UserRole.giamsat;
    final bool isNvkd = currentUser?.role == UserRole.nvkd;
    final bool isMarketing = currentUser?.role == UserRole.marketing;

    List<String> titles = [];
    List<Widget> screens = [];
    List<BottomNavigationBarItem> navItems = [];

    if (isAdmin) {
      titles = ['Dashboard', 'Khách hàng', 'Công việc', 'Hoa hồng', 'Check-in', 'Nhân viên'];
      screens = [
        const DashboardScreen(),
        const CustomerScreen(),
        const TaskScreen(),
        const CommissionScreen(),
        const CheckInScreen(),
        const UserManagementScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Hoa hồng'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Check-in'),
        BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle), label: 'Nhân viên'),
      ];
    } else if (isGiamSat) {
      titles = ['Dashboard', 'Công việc', 'Hoa hồng', 'Check-in'];
      screens = [
        const DashboardScreen(),
        const TaskScreen(),
        const CommissionScreen(),
        const CheckInScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Hoa hồng'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Check-in'),
      ];
    } else if (isNvkd) {
      titles = ['Dashboard', 'Công việc', 'Hoa hồng', 'Check-in'];
      screens = [
        const DashboardScreen(),
        const TaskScreen(),
        const CommissionScreen(),
        const CheckInScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Hoa hồng'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Check-in'),
      ];
    } else if (isMarketing) {
      titles = ['Dashboard', 'Khách hàng', 'Hoa hồng'];
      screens = [
        const DashboardScreen(),
        const CustomerScreen(),
        const CommissionScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Khách hàng'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Hoa hồng'),
      ];
    } else {
      titles = ['Dashboard', 'Công việc'];
      screens = [const DashboardScreen(), const TaskScreen()];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Công việc'),
      ];
    }

    // Đảm bảo không bị lỗi index
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await firebaseService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        items: navItems,
      ),
    );
  }
}