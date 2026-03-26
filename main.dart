import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ProfilePage());
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: width > 600 ? 400 : width * 0.9, // responsive
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                CircleAvatar(
                  radius: width > 600 ? 70 : 50,
                  backgroundImage: NetworkImage(
                    'https://i.imgur.com/BoN9kdC.png',
                  ),
                ),

                SizedBox(height: 20),

                // Name
                Text(
                  'Quách Chân Chính',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width > 600 ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                // MSV
                Text(
                  'MSV: 20220489',
                  style: TextStyle(fontSize: width > 600 ? 20 : 16),
                ),

                SizedBox(height: 10),

                // Role
                Text(
                  'Chức vụ: Thành viên',
                  style: TextStyle(fontSize: width > 600 ? 20 : 16),
                ),

                SizedBox(height: 20),

                Divider(),

                SizedBox(height: 10),

                // Button demo
                ElevatedButton(onPressed: () {}, child: Text('Liên hệ')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
