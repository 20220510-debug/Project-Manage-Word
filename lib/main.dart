import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'core/widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}

=======
import 'screens/dashboard_screen.dart';

void main() {
>>>>>>> c3c1a49ca754c2918e37ef0656da26878b7d140d
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
      ],
      child: MaterialApp(
        title: 'PMW - Quản Lý Công Việc & Hoa Hồng',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const MainLayout(),
        locale: const Locale('vi', 'VN'),
      ),
=======
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PMW App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      // 👇 QUAN TRỌNG NHẤT
      home: DashboardScreen(),
>>>>>>> c3c1a49ca754c2918e37ef0656da26878b7d140d
    );
  }
}