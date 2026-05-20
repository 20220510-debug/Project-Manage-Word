import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // ====================== AUTH ======================
  Future<User?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      await _loadCurrentUser(credential.user!.uid);
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      await _loadCurrentUser(credential.user!.uid);
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  Future<void> _loadCurrentUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      print("Lỗi load user: $e");
    }
  }

  // ====================== TASK ======================
  Future<String> addTask(TaskModel task) async {
    try {
      DocumentReference doc = await _firestore.collection('tasks').add(task.toMap());
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update(task.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ====================== USER ======================
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> createDefaultAdmin() async {
    try {
      final adminDoc = await _firestore.collection('users').doc('admin_default').get();
      if (adminDoc.exists) return;

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: "admin@quanly.com",
        password: "12345678",
      );

      final user = credential.user!;
      final adminUser = UserModel(
        uid: user.uid,
        name: "Administrator",
        email: "admin@quanly.com",
        phone: "0987654321",
        phong: "Ban Giám Đốc",
        team: "Admin",
        role: UserRole.admin,
        luongCoBan: 15000000,
        ngayVaoLam: DateTime.now(),
      );

      await createUser(adminUser);
      print("✅ Admin created: admin@quanly.com / 12345678");
    } catch (e) {
      print("Admin exists: $e");
    }
  }
}