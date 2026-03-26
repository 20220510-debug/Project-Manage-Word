import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giới thiệu nhóm',
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {

  final List<Map<String, String>> members = [
    {
      "name": "Quách Văn An",
      "role": "Trưởng nhóm",
      "birth": "2004",
      "hometown": "Phú Thọ",
      "image": "https://i.postimg.cc/6530LGyf/deptrai.jpg"
    },
    {
      "name": "Quach Chân Chính",
      "role": "Thành viên",
      "birth": "2002",
      "hometown": "Phú Thọ",
      "image": "https://i.postimg.cc/1RLG6Y1y/stingg.jpg" // thêm link sau
    },
    {
      "name": "Nguyên Quốc Vương",
      "role": "Thành viên",
      "birth": "2004",
      "hometown": "Phú Thọ",
      "image": "https://i.postimg.cc/kGs3KRYB/vuon.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giới thiệu nhóm"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];

          return Card(
            margin: EdgeInsets.all(15),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: member["image"]!.isNotEmpty
                        ? NetworkImage(member["image"]!)
                        : null,
                    child: member["image"]!.isEmpty
                        ? Icon(Icons.person, size: 40)
                        : null,
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member["name"]!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Chức vụ: ${member["role"]}"),
                      Text("Năm sinh: ${member["birth"]}"),
                      Text("Quê quán: ${member["hometown"]}"),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}