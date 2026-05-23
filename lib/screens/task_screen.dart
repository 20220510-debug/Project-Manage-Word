import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String selectedTab = "Tất cả";

  final List<String> tabs = ["Tất cả", "Tiếp nhận", "Đang thi công", "Đã nghiệm thu", "Hoàn thành"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            color: Colors.blue[700],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Công việc", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Quản lý tiến độ dự án", style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),

          // Tabs
          Container(
            height: 55,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = tab == selectedTab;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedTab = tab),
                    selectedColor: Colors.blue[700],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm công việc...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("Chưa có công việc nào"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final task = TaskModel.fromMap(data, docs[index].id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.assignment_turned_in, size: 40, color: Colors.blue),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Khách: ${task.customerName}"),
                            Text("Hạn: ${task.deadline.toString().substring(0, 10)}"),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(task.status.name),
                          backgroundColor: _getStatusColor(task.status),
                        ),
                        onTap: () => _showTaskForm(task: task),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.hoanThanh: return Colors.green[100]!;
      case TaskStatus.dangThiCong: return Colors.orange[100]!;
      default: return Colors.blue[100]!;
    }
  }

  void _showTaskForm({TaskModel? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(taskToEdit: task),
    );
  }
}

// ==================== FORM THÊM / SỬA CÔNG VIỆC ====================
class TaskFormDialog extends StatefulWidget {
  final TaskModel? taskToEdit;
  const TaskFormDialog({super.key, this.taskToEdit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _customerController = TextEditingController();
  final _revenueController = TextEditingController();

  TaskStatus _status = TaskStatus.tiepNhan;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _customerController.text = t.customerName;
      _revenueController.text = t.totalRevenue.toString();
      _status = t.status;
      _deadline = t.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.taskToEdit != null;

    return AlertDialog(
      title: Text(isEdit ? "Sửa Công Việc" : "Thêm Công Việc Mới"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Tên công việc *"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              TextFormField(controller: _customerController, decoration: const InputDecoration(labelText: "Tên khách hàng *"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              TextFormField(controller: _revenueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Doanh thu dự kiến")),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: "Trạng thái"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newTask = TaskModel(
                id: widget.taskToEdit?.id ?? '',
                title: _titleController.text,
                customerId: _customerController.text,
                customerName: _customerController.text,
                status: _status,
                deadline: _deadline,
                createdAt: DateTime.now(),
                totalRevenue: double.tryParse(_revenueController.text) ?? 0,
              );

              if (isEdit) {
                await FirebaseFirestore.instance.collection('tasks').doc(newTask.id).update(newTask.toMap());
              } else {
                await FirebaseFirestore.instance.collection('tasks').add(newTask.toMap());
              }

              if (mounted) Navigator.pop(context);
            }
          },
          child: Text(isEdit ? "Cập nhật" : "Thêm mới"),
        ),
      ],
    );
  }
}