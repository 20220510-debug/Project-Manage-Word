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

  final List<String> _tabs = [
    'Tất cả', 'Tiếp nhận', 'Đã gọi tư vấn', 'Gửi báo giá', 'Chốt hợp đồng',
    'Đã chuyển hàng', 'Đang thi công', 'Đã nghiệm thu', 'Hoàn thành'
  ];

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
      // Nút + luôn hiển thị
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
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

        // User thường chỉ thấy công việc của mình
        if (!isAdmin && userId != null) {
          tasks = tasks.where((task) => task.participants.containsValue(userId)).toList();
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _openForm(task: task),
        onLongPress: isAdmin ? () => _deleteTask(task.id) : null,
        leading: const Icon(Icons.assignment, color: Colors.blue, size: 40),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${task.customerName} • ${task.deadline.toString().substring(0,10)}'),
        trailing: Chip(label: Text(task.status.name)),
      ),
    );
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