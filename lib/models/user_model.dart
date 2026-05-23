import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  truongphong,
  teamlead,
  nvkd,
  marketing,
  giamsat,
  nguonkhach,
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String phong;
  final String team;
  final UserRole role;
  final double luongCoBan;
  final DateTime ngayVaoLam;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.phong,
    required this.team,
    required this.role,
    this.luongCoBan = 0.0,
    required this.ngayVaoLam,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    // Xử lý role an toàn (tránh lỗi "No enum value with that name")
    UserRole role;
    try {
      role = UserRole.values.byName(map['role'] ?? 'nvkd');
    } catch (e) {
      role = UserRole.nvkd; // Mặc định nếu role không hợp lệ
    }

    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      phong: map['phong'] ?? '',
      team: map['team'] ?? '',
      role: role,
      luongCoBan: (map['luongCoBan'] ?? 0.0).toDouble(),
      ngayVaoLam: (map['ngayVaoLam'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'phong': phong,
      'team': team,
      'role': role.name,
      'luongCoBan': luongCoBan,
      'ngayVaoLam': ngayVaoLam,
    };
  }
}