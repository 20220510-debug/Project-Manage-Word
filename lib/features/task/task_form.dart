import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/task_model.dart';

class TaskForm extends StatefulWidget {
  final TaskModel? taskToEdit;
  const TaskForm({super.key, this.taskToEdit});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _revenueController = TextEditingController();

  late TaskStatus _selectedStatus;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _selectedStatus = task?.status ?? TaskStatus.tiepNhan;
    _deadline = task?.deadline ?? DateTime.now().add(const Duration(days: 7));

    if (task != null) {
      _titleController.text = task.title;
      _customerNameController.text = task.customerName;
      _revenueController.text = task.totalRevenue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Công Việc' : 'Tạo Công Việc Mới'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên công việc *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên công việc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Tên khách hàng *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên khách hàng' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _revenueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Doanh thu dự kiến (VND)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<TaskStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
                items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveTask,
                child: Text(isEditing ? 'CẬP NHẬT' : 'TẠO CÔNG VIỆC'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final newTask = TaskModel(
        id: widget.taskToEdit?.id ?? '',
        title: _titleController.text.trim(),
        customerId: _customerNameController.text.trim(),
        customerName: _customerNameController.text.trim(),
        status: _selectedStatus,
        deadline: _deadline,
        createdAt: DateTime.now(),
        totalRevenue: double.tryParse(_revenueController.text) ?? 0,
      );

      if (widget.taskToEdit != null) {
        await FirebaseFirestore.instance.collection('tasks').doc(newTask.id).update(newTask.toMap());
      } else {
        await FirebaseFirestore.instance.collection('tasks').add(newTask.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}