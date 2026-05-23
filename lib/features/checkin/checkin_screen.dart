import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isCheckedIn = false;
  String _lastCheckInTime = "";
  String _workingDuration = "";
  int _totalWorkingDays = 0;
  double _totalSalary = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('vi_VN', null);
    _loadTodayCheckIn();
    _loadMonthlySummary();
  }

  Future<void> _loadTodayCheckIn() async {
    final user = Provider.of<FirebaseService>(context, listen: false).currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final doc = await FirebaseFirestore.instance
        .collection('checkins')
        .doc('${user.uid}_$today')
        .get();

    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _isCheckedIn = true;
        _lastCheckInTime = data['checkInTime'] ?? '';
        _calculateWorkingDuration(data['checkInTime']);
      });
    }
  }

  void _calculateWorkingDuration(String checkInTime) {
    if (checkInTime.isEmpty) return;
    try {
      final now = DateTime.now();
      final checkIn = DateFormat('HH:mm').parse(checkInTime);
      final checkInDateTime = DateTime(now.year, now.month, now.day, checkIn.hour, checkIn.minute);
      final duration = now.difference(checkInDateTime);
      setState(() {
        _workingDuration = "${duration.inHours}h ${duration.inMinutes % 60}m";
      });
    } catch (e) {}
  }

  // ==================== PHIÊN BẢN TẠM THỜI (KHÔNG CẦN INDEX) ====================
  Future<void> _loadMonthlySummary() async {
    final user = Provider.of<FirebaseService>(context, listen: false).currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('checkins')
        .where('userId', isEqualTo: user.uid)
        .get();

    int days = 0;
    double salary = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'finished' || data['checkOutTime'] != null) {
        days++;
        salary += 150000;
      }
    }

    setState(() {
      _totalWorkingDays = days;
      _totalSalary = salary;
    });
  }

  Future<void> _checkIn() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Vui lòng bật GPS");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();

      final user = Provider.of<FirebaseService>(context, listen: false).currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final time = DateFormat('HH:mm').format(now);
      final today = DateFormat('yyyy-MM-dd').format(now);

      await FirebaseFirestore.instance.collection('checkins').doc('${user.uid}_$today').set({
        'userId': user.uid,
        'userName': user.name,
        'checkInTime': time,
        'date': today,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
        'status': 'working',
      });

      setState(() {
        _isCheckedIn = true;
        _lastCheckInTime = time;
        _workingDuration = "0h 0m";
      });

      Fluttertoast.showToast(msg: "✅ Check-in thành công!", backgroundColor: Colors.green);
      _loadMonthlySummary();
    } catch (e) {
      Fluttertoast.showToast(msg: "Lỗi: $e", backgroundColor: Colors.red);
    }
  }

  Future<void> _checkOut() async {
    final user = Provider.of<FirebaseService>(context, listen: false).currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(now);

    await FirebaseFirestore.instance
        .collection('checkins')
        .doc('${user.uid}_$today')
        .update({
      'checkOutTime': time,
      'checkOutTimestamp': Timestamp.now(),
      'status': 'finished',
    });

    setState(() {
      _isCheckedIn = false;
      _workingDuration = "";
    });

    Fluttertoast.showToast(msg: "✅ Check-out thành công!", backgroundColor: Colors.orange);
    _loadMonthlySummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm Công'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === THÔNG TIN TỔNG HỢP ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tháng này', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('$_totalWorkingDays ngày', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng lương tạm tính', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('${(_totalSalary / 1000000).toStringAsFixed(1)} triệu',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // === TRẠNG THÁI HIỆN TẠI ===
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Icon(
                    _isCheckedIn ? Icons.work : Icons.access_time,
                    size: 70,
                    color: _isCheckedIn ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isCheckedIn ? 'ĐANG LÀM VIỆC' : 'CHƯA CHECK-IN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isCheckedIn ? Colors.green : Colors.grey[700],
                    ),
                  ),
                  if (_isCheckedIn && _lastCheckInTime.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Check-in lúc: $_lastCheckInTime', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  if (_isCheckedIn && _workingDuration.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Thời gian: $_workingDuration', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // === NÚT CHECK-IN / CHECK-OUT ===
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isCheckedIn ? _checkOut : _checkIn,
                icon: Icon(_isCheckedIn ? Icons.logout : Icons.login, size: 24),
                label: Text(
                  _isCheckedIn ? 'CHECK-OUT' : 'CHECK-IN',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCheckedIn ? Colors.orange : Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}