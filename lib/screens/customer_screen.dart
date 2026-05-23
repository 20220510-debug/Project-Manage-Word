// lib/screens/customer_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/customer_model.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CollectionReference customersRef = FirebaseFirestore.instance.collection('customers');

  void _showCustomerForm({CustomerModel? customer}) {
    showDialog(
      context: context,
      builder: (context) => CustomerFormDialog(customer: customer),
    );
  }

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
                Text("Khách hàng", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Quản lý thông tin khách hàng", style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm khách hàng...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() {}), // TODO: Thêm search logic
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: customersRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("Chưa có khách hàng nào"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final customer = CustomerModel.fromMap(data, docs[index].id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("☎ ${customer.phone}"),
                            if (customer.company != null) Text("🏢 ${customer.company}"),
                          ],
                        ),
                        trailing: Chip(label: Text(customer.status)),
                        onTap: () => _showCustomerForm(customer: customer),
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
        onPressed: () => _showCustomerForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== FORM THÊM / SỬA ====================
class CustomerFormDialog extends StatefulWidget {
  final CustomerModel? customer;
  const CustomerFormDialog({super.key, this.customer});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _phoneCtrl, _emailCtrl, _addressCtrl, _companyCtrl;

  String _status = "Khách mới";

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: c?.name);
    _phoneCtrl = TextEditingController(text: c?.phone);
    _emailCtrl = TextEditingController(text: c?.email);
    _addressCtrl = TextEditingController(text: c?.address);
    _companyCtrl = TextEditingController(text: c?.company);
    _status = c?.status ?? "Khách mới";
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return AlertDialog(
      title: Text(isEdit ? "Sửa khách hàng" : "Thêm khách hàng mới"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Họ tên *"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Số điện thoại *"), validator: (v) => v!.isEmpty ? "Bắt buộc" : null),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              TextFormField(controller: _companyCtrl, decoration: const InputDecoration(labelText: "Công ty")),
              TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: "Địa chỉ")),
              DropdownButtonFormField<String>(
                value: _status,
                items: ["Khách mới", "Khách VIP", "Tiềm năng", "Khách cũ"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
              final data = {
                'name': _nameCtrl.text.trim(),
                'phone': _phoneCtrl.text.trim(),
                'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
                'company': _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
                'address': _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
                'status': _status,
                'createdAt': widget.customer?.createdAt ?? Timestamp.now(),
              };

              if (isEdit) {
                await FirebaseFirestore.instance.collection('customers').doc(widget.customer!.id).update(data);
              } else {
                await FirebaseFirestore.instance.collection('customers').add(data);
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