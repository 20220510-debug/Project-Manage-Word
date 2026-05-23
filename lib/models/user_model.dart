import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin("Quản trị viên"),
  staff("Nhân viên"),
  manager("Quản lý");

  final String name;
  const UserRole(this.name);
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? phong;
  final String? team;
  final DateTime? ngayVaoLam;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.phong,
    this.team,
    this.ngayVaoLam,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.name == map['role'],
        orElse: () => UserRole.staff,
      ),
      phone: map['phone'],
      phong: map['phong'],
      team: map['team'],
      ngayVaoLam: map['ngayVaoLam'] != null ? (map['ngayVaoLam'] as Timestamp).toDate() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'phong': phong,
      'team': team,
      'ngayVaoLam': ngayVaoLam != null ? Timestamp.fromDate(ngayVaoLam!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}