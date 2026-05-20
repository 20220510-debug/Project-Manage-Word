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
  Position? _currentPosition;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('vi_VN', null);
    setState(() => _isInitialized = true);
    _loadTodayCheckIn();
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
      setState(() {
        _isCheckedIn = true;
        _lastCheckInTime = doc['checkInTime'] ?? '';
      });
    }
  }

  Future<void> _checkIn() async {
    // ... (giữ nguyên phần check-in cũ)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Vui lòng bật GPS");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Không có quyền vị trí");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final user = Provider.of<FirebaseService>(context, listen: false).currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final time = DateFormat('HH:mm:ss').format(now);
    final today = DateFormat('yyyy-MM-dd').format(now);

    await FirebaseFirestore.instance.collection('checkins').doc('${user.uid}_$today').set({
      'userId': user.uid,
      'userName': user.name,
      'checkInTime': time,
      'date': today,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _isCheckedIn = true;
      _lastCheckInTime = time;
    });

    Fluttertoast.showToast(msg: "✅ Check-in thành công lúc $time", backgroundColor: Colors.green);
  }

  Future<void> _checkOut() async {
    final user = Provider.of<FirebaseService>(context, listen: false).currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final time = DateFormat('HH:mm:ss').format(DateTime.now());

    await FirebaseFirestore.instance.collection('checkins').doc('${user.uid}_$today').update({
      'checkOutTime': time,
      'timestampOut': Timestamp.now(),
    });

    setState(() => _isCheckedIn = false);
    Fluttertoast.showToast(msg: "✅ Check-out thành công lúc $time", backgroundColor: Colors.orange);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('dd/MM/yyyy - EEEE', 'vi_VN').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in / Check-out'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(dateStr, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(timeStr, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(
                      _isCheckedIn ? "✅ Đã Check-in" : "⏳ Chưa Check-in",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isCheckedIn ? Colors.green : Colors.orange,
                      ),
                    ),
                    if (_lastCheckInTime.isNotEmpty) Text("Lúc: $_lastCheckInTime"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isCheckedIn ? null : _checkIn,
              icon: const Icon(Icons.login),
              label: const Text('CHECK-IN', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isCheckedIn ? _checkOut : null,
              icon: const Icon(Icons.logout),
              label: const Text('CHECK-OUT', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}