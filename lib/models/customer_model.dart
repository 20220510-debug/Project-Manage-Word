import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus {
  tiepNhan,
  daGoiTuVan,
  guiBaoGia,
  chotHopDong,
  daChuyenHang,
  dangThiCong,
  daNghiemThu,
  hoanThanh;

  String get name {
    switch (this) {
      case TaskStatus.tiepNhan: return 'Tiếp nhận';
      case TaskStatus.daGoiTuVan: return 'Đã gọi tư vấn';
      case TaskStatus.guiBaoGia: return 'Gửi báo giá';
      case TaskStatus.chotHopDong: return 'Chốt hợp đồng';
      case TaskStatus.daChuyenHang: return 'Đã chuyển hàng';
      case TaskStatus.dangThiCong: return 'Đang thi công';
      case TaskStatus.daNghiemThu: return 'Đã nghiệm thu';
      case TaskStatus.hoanThanh: return 'Hoàn thành';
    }
  }
}

// Inner class cho lịch sử thanh toán
class PaymentHistory {
  final DateTime date;
  final double amount;
  final String note;

  PaymentHistory({
    required this.date,
    required this.amount,
    required this.note,
  });

  factory PaymentHistory.fromMap(Map<String, dynamic> map) {
    return PaymentHistory(
      date: (map['date'] as Timestamp).toDate(),
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'note': note,
    };
  }
}

class TaskModel {
  final String id;
  final String title;
  final String customerId;
  final String customerName;
  final TaskStatus status;
  final DateTime deadline;
  final DateTime createdAt;
  final double totalRevenue;
  final double mainMaterialCost;
  final double subMaterialCost;
  final Map<String, String> participants;
  final List<PaymentHistory> paymentHistory;

  TaskModel({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.totalRevenue,
    required this.mainMaterialCost,
    required this.subMaterialCost,
    required this.participants,
    this.paymentHistory = const [],
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      status: TaskStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TaskStatus.tiepNhan,
      ),
      deadline: (map['deadline'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      mainMaterialCost: (map['mainMaterialCost'] ?? 0).toDouble(),
      subMaterialCost: (map['subMaterialCost'] ?? 0).toDouble(),
      participants: Map<String, String>.from(map['participants'] ?? {}),
      paymentHistory: (map['paymentHistory'] as List<dynamic>? ?? [])
          .map((e) => PaymentHistory.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'customerId': customerId,
      'customerName': customerName,
      'status': status.name,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'totalRevenue': totalRevenue,
      'mainMaterialCost': mainMaterialCost,
      'subMaterialCost': subMaterialCost,
      'participants': participants,
      'paymentHistory': paymentHistory.map((p) => p.toMap()).toList(),
    };
  }
}