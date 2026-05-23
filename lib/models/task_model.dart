import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus {
  tiepNhan("Tiếp nhận"),
  daGoiTuVan("Đã gọi tư vấn"),
  guiBaoGia("Gửi báo giá"),
  chotHopDong("Chốt hợp đồng"),
  daChuyenHang("Đã chuyển hàng"),
  dangThiCong("Đang thi công"),
  daNghiemThu("Đã nghiệm thu"),
  hoanThanh("Hoàn thành");

  final String name;
  const TaskStatus(this.name);
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
  final Map<String, dynamic> participants;   // ai tham gia

  TaskModel({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.deadline,
    required this.createdAt,
    this.totalRevenue = 0,
    this.mainMaterialCost = 0,
    this.subMaterialCost = 0,
    this.participants = const {},
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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      mainMaterialCost: (map['mainMaterialCost'] ?? 0).toDouble(),
      subMaterialCost: (map['subMaterialCost'] ?? 0).toDouble(),
      participants: map['participants'] ?? {},
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
    };
  }
}