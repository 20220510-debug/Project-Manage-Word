import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionModel {
  final String id;
  final String taskId;
  final String userId;
  final String role;           // nvkd, marketing, giamsat, nguon, truongphong, teamlead
  final double amount;
  final DateTime date;
  final String taskTitle;
  final bool isPaid;

  CommissionModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.role,
    required this.amount,
    required this.date,
    required this.taskTitle,
    this.isPaid = false,
  });

  factory CommissionModel.fromMap(Map<String, dynamic> map, String id) {
    return CommissionModel(
      id: id,
      taskId: map['taskId'] ?? '',
      userId: map['userId'] ?? '',
      role: map['role'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      taskTitle: map['taskTitle'] ?? '',
      isPaid: map['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'userId': userId,
      'role': role,
      'amount': amount,
      'date': date,
      'taskTitle': taskTitle,
      'isPaid': isPaid,
    };
  }
}