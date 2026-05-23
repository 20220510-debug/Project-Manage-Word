import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import 'task_form.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<String> _tabs = ['Tất cả', 'Tiếp nhận', 'Đã gọi tư vấn', 'Gửi báo giá', 'Chốt hợp đồng', 'Đã chuyển hàng', 'Đang thi công', 'Đã nghiệm thu', 'Hoàn thành'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final currentUser = firebaseService.currentUser;
    final bool isAdmin = currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Công Việc'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((status) => _buildTaskList(status, isAdmin, currentUser?.uid)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  void _openForm({TaskModel? task}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TaskForm(taskToEdit: task)))
        .then((_) => setState(() {}));
  }

  Widget _buildTaskList(String status, bool isAdmin, String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Chưa có công việc nào'));
        }

        var tasks = snapshot.data!.docs
            .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // ==================== LỌC CÔNG VIỆC THEO NGƯỜI DÙNG ====================
        if (!isAdmin && userId != null) {
          tasks = tasks.where((task) {
            return task.participants.containsKey(userId);
          }).toList();
        }

        if (status != 'Tất cả') {
          tasks = tasks.where((t) => t.status.name == status).toList();
        }

        if (_searchQuery.isNotEmpty) {
          tasks = tasks.where((t) =>
          t.title.toLowerCase().contains(_searchQuery) ||
              t.customerName.toLowerCase().contains(_searchQuery)).toList();
        }

        if (tasks.isEmpty) {
          return const Center(child: Text('Không tìm thấy công việc'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (context, index) => _buildTaskCard(tasks[index], isAdmin),
        );
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, bool isAdmin) {
    final isCompleted = task.status == TaskStatus.hoanThanh;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            onTap: () => _openForm(task: task),
            onLongPress: isAdmin ? () => _deleteTask(task.id) : null,
            leading: const Icon(Icons.assignment, color: Colors.blue, size: 40),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${task.customerName} • ${task.deadline.toString().substring(0,10)}'),
            trailing: Chip(
              label: Text(task.status.name),
              backgroundColor: isCompleted ? Colors.green[100] : Colors.orange[100],
            ),
          ),
          if (!isCompleted && isAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: ElevatedButton.icon(
                onPressed: () => _completeTaskWithCommission(task.id),
                icon: const Icon(Icons.check_circle),
                label: const Text('HOÀN THÀNH & TÍNH HOA HỒNG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _completeTaskWithCommission(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hoàn thành'),
        content: const Text('Bạn có chắc muốn hoàn thành công việc này và tính hoa hồng không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final service = Provider.of<FirebaseService>(context, listen: false);
      await service.completeTaskAndCalculateCommissions(taskId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã hoàn thành và tính hoa hồng thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  void _deleteTask(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}