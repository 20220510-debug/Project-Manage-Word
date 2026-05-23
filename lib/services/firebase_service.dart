import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadCurrentUser(credential.user!.uid);
      return credential.user;
    } catch (e) { rethrow; }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _loadCurrentUser(credential.user!.uid);
      return credential.user;
    } catch (e) { rethrow; }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  Future<void> _loadCurrentUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) _currentUser = UserModel.fromMap(doc.data()!, uid);
    } catch (e) {}
  }

  Future<String> addTask(TaskModel task) async {
    DocumentReference doc = await _firestore.collection('tasks').add(task.toMap());
    return doc.id;
  }

  Future<void> updateTask(String taskId, TaskModel task) async {
    await _firestore.collection('tasks').doc(taskId).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> createDefaultAdmin() async {
    try {
      final adminDoc = await _firestore.collection('users').doc('admin_default').get();
      if (adminDoc.exists) return;

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: "admin@quanly.com", password: "12345678");

      final user = credential.user!;
      final adminUser = UserModel(
        uid: user.uid, name: "Administrator", email: "admin@quanly.com",
        phone: "0987654321", phong: "Ban Giám Đốc", team: "Admin",
        role: UserRole.admin, luongCoBan: 15000000, ngayVaoLam: DateTime.now(),
      );
      await createUser(adminUser);
    } catch (e) {}
  }

  Future<void> completeTaskAndCalculateCommissions(String taskId) async {
    try {
      final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
      if (!taskDoc.exists) return;

      final task = TaskModel.fromMap(taskDoc.data()!, taskId);
      if (task.status == TaskStatus.hoanThanh) return;

      await _firestore.collection('tasks').doc(taskId).update({'status': TaskStatus.hoanThanh.name});

      final revenue = task.totalRevenue;
      final profit = revenue - task.mainMaterialCost - task.subMaterialCost;

      final rates = {'nvkd': 0.02, 'marketing': 0.02, 'giamsat': 0.07, 'truongphong': 0.01, 'teamlead': 0.015};
      final batch = _firestore.batch();

      task.participants.forEach((role, userId) {
        double rate = rates[role] ?? 0.0;
        double amount = (role == 'giamsat') ? (profit * rate).roundToDouble() : (revenue * rate).roundToDouble();
        if (amount > 0) {
          batch.set(_firestore.collection('commissions').doc(), {
            'taskId': taskId, 'userId': userId, 'role': role, 'amount': amount,
            'date': Timestamp.now(), 'taskTitle': task.title, 'isPaid': false,
          });
        }
      });
      await batch.commit();
    } catch (e) {}
  }
}